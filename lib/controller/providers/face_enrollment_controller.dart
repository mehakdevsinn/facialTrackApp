import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/enrollment_config_model.dart';
import 'package:facialtrackapp/core/models/frame_analysis_result.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

// ─── Enums ────────────────────────────────────────────────────────────────────

enum EnrollmentPhase {
  loadingConfig,
  startingCamera,
  analyzing,
  holding,
  captured,
  uploading,
  complete,
  error,
}

// ─── Controller ───────────────────────────────────────────────────────────────

/// Owns the entire face enrollment state machine.
/// The UI observes this ChangeNotifier and never contains business logic.
class FaceEnrollmentController extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  // ── Camera ────────────────────────────────────────────────────────────────
  CameraController? _camera;
  CameraController? get camera => _camera;

  // ── State machine ─────────────────────────────────────────────────────────
  EnrollmentPhase _phase = EnrollmentPhase.loadingConfig;
  EnrollmentPhase get phase => _phase;

  // ── Capture sequence (from server) ────────────────────────────────────────
  List<CaptureStep> _captureSequence = [];
  List<CaptureStep> get captureSequence => _captureSequence;

  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;

  CaptureStep? get currentStep =>
      _captureSequence.isEmpty ? null : _captureSequence[_currentStepIndex];

  String get currentAngle => currentStep?.angle ?? 'center';

  // ── Per-frame feedback ────────────────────────────────────────────────────
  FrameAnalysisResult _lastResult = FrameAnalysisResult.notReady;
  DateTime _lastResultTimestamp = DateTime(2000);

  String get feedbackMessage => _lastResult.feedbackMessage;
  String get feedbackColor => _lastResult.feedbackColor;
  int get overallScore => _lastResult.overallScore;
  bool get faceDetected => _lastResult.faceDetected;

  /// Rule 3 — result is only trusted if it arrived within the last 500ms.
  /// HTML uses 200ms because browser canvas frames arrive at 10fps concurrently.
  /// Our takePicture() + compress = ~300ms → effective 3fps sequential, so we
  /// use 500ms to give a comfortable buffer between consecutive results.
  bool get _isResultFresh =>
      DateTime.now().difference(_lastResultTimestamp).inMilliseconds < 500;

  bool get isReady => _lastResult.readyToCapture && _isResultFresh;

  /// True when the hold ring is visible but draining (face moved away).
  bool get isDraining => _phase == EnrollmentPhase.holding && !isReady;

  // ── Hold timer ────────────────────────────────────────────────────────────
  double _holdProgress = 0.0;
  double get holdProgress => _holdProgress;

  int _consecutiveReadyCount = 0;
  static const int _requiredConsecutive = 3;

  // ── Captured images ───────────────────────────────────────────────────────
  final List<Uint8List?> _capturedImages = [null, null, null];
  List<Uint8List?> get capturedImages => List.unmodifiable(_capturedImages);

  // ── Analysis loop ─────────────────────────────────────────────────────────
  Timer? _analysisTimer;
  Timer? _holdTimer;
  bool _frameBusy = false; // prevents concurrent takePicture() calls

  /// Stores the most-recent JPEG frame from the analysis loop.
  /// Used directly for capture — no extra takePicture() call needed
  /// (mirrors the HTML frontend which reuses the live video frame).
  Uint8List? _lastAnalyzedJpeg;

  // ── Error ─────────────────────────────────────────────────────────────────
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Public lifecycle ───────────────────────────────────────────────────────

  /// Call from the screen's initState after creating a CameraController.
  Future<void> initialize() async {
    _setPhase(EnrollmentPhase.loadingConfig);

    // 1. Fetch enrollment config
    EnrollmentConfig config;
    try {
      config = await _api.getEnrollmentConfig();
    } catch (e) {
      _errorMessage = e.toString();
      _setPhase(EnrollmentPhase.error);
      return;
    }

    _captureSequence = config.captureSequence;
    if (_captureSequence.isEmpty) {
      // Fallback if backend returns empty sequence
      _captureSequence = [
        const CaptureStep(
            angle: 'center', instruction: 'Look straight at the camera 😊'),
        const CaptureStep(
            angle: 'left',
            instruction: 'Turn your head slightly to the right 👉'),
        const CaptureStep(
            angle: 'right',
            instruction: 'Turn your head slightly to the left 👈'),
      ];
    }
    _capturedImages
      ..clear()
      ..addAll(List.filled(_captureSequence.length, null));

    // 2. Start camera
    _setPhase(EnrollmentPhase.startingCamera);
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _camera = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _camera!.initialize();
    } catch (e) {
      _errorMessage = 'Camera initialisation failed: $e';
      _setPhase(EnrollmentPhase.error);
      return;
    }

    // 3. Start analysis loop (10 FPS = every 100ms)
    _setPhase(EnrollmentPhase.analyzing);
    _startAnalysisLoop();
  }

  // ─── Analysis loop ──────────────────────────────────────────────────────────

  void _startAnalysisLoop() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_phase == EnrollmentPhase.analyzing ||
          _phase == EnrollmentPhase.holding) {
        _sendFrame();
      }
    });
  }

  void _stopAnalysisLoop() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
  }

  Future<void> _sendFrame() async {
    if (_frameBusy || _camera == null || !_camera!.value.isInitialized) return;

    _frameBusy = true;

    // Snapshot angle BEFORE any async gap — Rule 1
    final String angleAtSendTime = currentAngle;

    Uint8List jpegBytes;
    try {
      final XFile xfile = await _camera!.takePicture();
      final Uint8List rawBytes = await xfile.readAsBytes();
      jpegBytes = await _compressToJpeg(rawBytes);
    } catch (_) {
      _frameBusy = false;
      return;
    }

    // Store the latest JPEG so the capture step can reuse it
    // without an extra takePicture() call (matches HTML frontend approach).
    _lastAnalyzedJpeg = jpegBytes;

    // Release camera lock immediately after takePicture (fire-and-forget API).
    _frameBusy = false;

    _api.analyzeFrame(jpegBytes, angleAtSendTime).then((result) {
      // Rule 1 — discard stale response if step advanced
      if (angleAtSendTime != currentAngle) return;
      _onAnalysisResult(result);
    }).catchError((_) {});
  }

  /// Compresses raw JPEG bytes to quality 80. Does NOT flip pixels (Rule 5).
  Future<Uint8List> _compressToJpeg(Uint8List rawBytes) async {
    return await compute(_compressIsolate, rawBytes);
  }

  static Uint8List _compressIsolate(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    return img.encodeJpg(decoded, quality: 80) as Uint8List;
  }

  // ─── Analysis result handler ────────────────────────────────────────────────

  void _onAnalysisResult(FrameAnalysisResult result) {
    _lastResult = result;
    _lastResultTimestamp = DateTime.now();

    if (_phase == EnrollmentPhase.analyzing) {
      if (isReady) {
        _consecutiveReadyCount++;
        if (_consecutiveReadyCount >= _requiredConsecutive) {
          _setPhase(EnrollmentPhase.holding);
          _startHoldTimer();
        }
      } else {
        _consecutiveReadyCount = 0;
      }
    } else if (_phase == EnrollmentPhase.holding) {
      if (result.readyToCapture) {
        // ── API-result-based fill: +20% per confirmed ready result ────────
        // 5 consecutive ready results = 100% = capture.
        // Naturally adapts to network speed:
        //   fast  (~400ms/result): ~2 s
        //   slow (~1000ms/result): ~5 s
        //   very  (~2000ms/result): ~10 s
        _holdProgress = (_holdProgress + 0.20).clamp(0.0, 1.0);
        if (_holdProgress >= 1.0) {
          _holdTimer?.cancel();
          _holdTimer = null;
          _captureCurrentStep();
          notifyListeners();
          return;
        }
      }
      // Drain is handled by the hold timer on fresh not-ready results.
    }
    notifyListeners();
  }

  // ─── Hold timer ──────────────────────────────────────────────────────────────

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdProgress = 0.0;

    // Timer is drain-only. Fill is driven by API results in _onAnalysisResult.
    // Drain fires when the backend freshly says not-ready (user moved face).
    const tickDuration = Duration(milliseconds: 50);
    const double drainDecrement = 0.10; // drain ~500ms from 100%

    _holdTimer = Timer.periodic(tickDuration, (timer) {
      final bool fresh = _isResultFresh;
      final bool backendReady = _lastResult.readyToCapture;

      if (fresh && !backendReady) {
        // ── DRAIN: backend freshly said not-ready (user moved) ──────────────
        _holdProgress = (_holdProgress - drainDecrement).clamp(0.0, 1.0);
        notifyListeners();

        if (_holdProgress <= 0.0) {
          timer.cancel();
          _holdTimer = null;
          _consecutiveReadyCount = 0;
          _setPhase(EnrollmentPhase.analyzing);
          notifyListeners();
        }
      }
      // fresh && backendReady  → fill handled in _onAnalysisResult (not here)
      // !fresh                 → PAUSE (stale result), do nothing
    });
  }

  // ─── Capture ─────────────────────────────────────────────────────────────────

  Future<void> _captureCurrentStep() async {
    // Stop analysis so no new takePicture() overlaps with our capture.
    _stopAnalysisLoop();

    // Reuse the latest frame from the analysis loop — no extra camera call.
    // This is exactly what the HTML frontend does: ctx.drawImage(video, ...).
    final Uint8List? jpegBytes = _lastAnalyzedJpeg;
    if (jpegBytes == null) {
      // Fallback: if somehow no frame is stored yet, take one explicitly.
      try {
        // Wait for any in-progress takePicture to finish first.
        int waited = 0;
        while (_frameBusy && waited < 600) {
          await Future.delayed(const Duration(milliseconds: 50));
          waited += 50;
        }
        final XFile xfile = await _camera!.takePicture();
        final Uint8List rawBytes = await xfile.readAsBytes();
        final Uint8List compressed = await _compressToJpeg(rawBytes);
        _capturedImages[_currentStepIndex] = compressed;
      } catch (e) {
        _errorMessage = 'Capture failed: $e';
        _setPhase(EnrollmentPhase.error);
        return;
      }
    } else {
      _capturedImages[_currentStepIndex] = jpegBytes;
    }

    _setPhase(EnrollmentPhase.captured);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    if (_currentStepIndex < _captureSequence.length - 1) {
      // Advance to next step
      _currentStepIndex++;
      _consecutiveReadyCount = 0;
      _holdProgress = 0.0;
      _lastResult = FrameAnalysisResult.notReady;
      _lastAnalyzedJpeg = null;
      _setPhase(EnrollmentPhase.analyzing);
      notifyListeners();
      // Restart analysis for next step
      _startAnalysisLoop();
    } else {
      // All steps done — upload (Rule 4: loop already stopped above)
      await _uploadAll();
    }
  }

  // ─── Upload ───────────────────────────────────────────────────────────────────

  Future<void> _uploadAll() async {
    _setPhase(EnrollmentPhase.uploading);
    notifyListeners();

    try {
      for (int i = 0; i < _captureSequence.length; i++) {
        final bytes = _capturedImages[i];
        if (bytes == null) throw Exception('Missing image for step $i');
        // Sequential: wait for each before sending next (per guide)
        await _api.uploadFaceImage(bytes, _captureSequence[i].angle);
      }
      _setPhase(EnrollmentPhase.complete);
    } catch (e) {
      _errorMessage = e.toString();
      _setPhase(EnrollmentPhase.error);
    }
    notifyListeners();
  }

  /// Allow the user to retry after an error — resets and restarts.
  Future<void> retry() async {
    _stopAnalysisLoop();
    _holdTimer?.cancel();
    await _camera?.dispose();
    _camera = null;
    _currentStepIndex = 0;
    _consecutiveReadyCount = 0;
    _holdProgress = 0.0;
    _frameBusy = false;
    _errorMessage = null;
    _lastResult = FrameAnalysisResult.notReady;
    _lastAnalyzedJpeg = null;
    _capturedImages.fillRange(0, _capturedImages.length, null);
    notifyListeners();
    await initialize();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  void _setPhase(EnrollmentPhase p) {
    _phase = p;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAnalysisLoop();
    _holdTimer?.cancel();
    _camera?.dispose();
    super.dispose();
  }
}
