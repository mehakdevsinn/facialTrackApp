import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/face_enrollment_controller.dart';
import 'package:facialtrackapp/view/student/Face%20Enrolment/enrollment-result-screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentFaceEnrollement extends StatelessWidget {
  const StudentFaceEnrollement({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FaceEnrollmentController(),
      child: const _EnrollmentBody(),
    );
  }
}

// ─── Body listens to controller ──────────────────────────────────────────────

class _EnrollmentBody extends StatefulWidget {
  const _EnrollmentBody();

  @override
  State<_EnrollmentBody> createState() => _EnrollmentBodyState();
}

class _EnrollmentBodyState extends State<_EnrollmentBody> {
  @override
  void initState() {
    super.initState();
    // Start after first frame so context + provider are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaceEnrollmentController>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FaceEnrollmentController>();

    // Navigate away on complete
    if (ctrl.phase == EnrollmentPhase.complete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => EnrollmentResultScreen(
                isSuccess: true,
                capturedImages:
                    ctrl.capturedImages.whereType<Uint8List>().toList(),
              ),
            ),
            (route) => false,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildForPhase(ctrl),
    );
  }

  Widget _buildForPhase(FaceEnrollmentController ctrl) {
    switch (ctrl.phase) {
      case EnrollmentPhase.loadingConfig:
      case EnrollmentPhase.startingCamera:
        return _buildLoading('Preparing camera…');
      case EnrollmentPhase.error:
        return _buildError(ctrl);
      case EnrollmentPhase.uploading:
        return _buildLoading('Saving your face data…');
      case EnrollmentPhase.complete:
        return _buildLoading('Done!');
      default:
        return _buildCamera(ctrl);
    }
  }

  // ─── Loading / uploading overlay ────────────────────────────────────────────

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: ColorPallet.primaryBlue),
          const SizedBox(height: 20),
          Text(message,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  // ─── Error screen ────────────────────────────────────────────────────────────

  Widget _buildError(FaceEnrollmentController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 20),
            const Text('Enrollment Failed',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              ctrl.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 15),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: ctrl.retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPallet.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Try Again',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main camera UI ──────────────────────────────────────────────────────────

  Widget _buildCamera(FaceEnrollmentController ctrl) {
    final camera = ctrl.camera;
    final stepCount = ctrl.captureSequence.length;
    final stepIndex = ctrl.currentStepIndex;
    final instruction = ctrl.currentStep?.instruction ?? '';

    // Map feedback color string → Flutter Color
    final Color borderColor = switch (ctrl.feedbackColor) {
      'green' => Colors.green,
      'yellow' => Colors.amber,
      _ => Colors.red,
    };

    return SafeArea(
      child: Column(
        children: [
          // ── App bar row
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Face Enrollment',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text('${stepIndex + 1}/$stepCount',
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Step indicator
          _StepIndicator(
            total: stepCount,
            current: stepIndex,
            captured: ctrl.capturedImages,
          ),
          const SizedBox(height: 18),

          // ── Instruction text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),

          // ── Camera frame (center piece)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera preview (mirrored for selfie UX — Rule 5: only display flip)
                    if (camera != null && camera.value.isInitialized)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CameraPreview(camera),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: ColorPallet.primaryBlue),
                        ),
                      ),

                    // Colored border overlay
                    _CameraFrameBorder(color: borderColor, phase: ctrl.phase),

                    // Hold progress ring (centered)
                    if (ctrl.phase == EnrollmentPhase.holding)
                      Center(
                        child: _HoldRing(
                          progress: ctrl.holdProgress,
                          isDraining: ctrl.isDraining,
                        ),
                      ),

                    // Score badge (top-right)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: _ScoreBadge(score: ctrl.overallScore),
                    ),

                    // Hold still / return to position label
                    if (ctrl.phase == EnrollmentPhase.holding)
                      Positioned(
                        bottom: 18,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: ctrl.isDraining
                                  ? Colors.orange.withOpacity(0.85)
                                  : Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              ctrl.isDraining
                                  ? '⚠️ Return to position…'
                                  : '✅ Hold still…',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Feedback message
          Text(
            ctrl.phase == EnrollmentPhase.captured
                ? '✅ Captured!'
                : ctrl.faceDetected
                    ? ctrl.feedbackMessage
                    : 'No face detected — position your face in frame',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ctrl.phase == EnrollmentPhase.captured
                  ? Colors.green
                  : _toColor(ctrl.feedbackColor),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          // ── Captured thumbnails row
          if (ctrl.capturedImages.any((b) => b != null))
            _ThumbnailRow(
                images: ctrl.capturedImages, sequence: ctrl.captureSequence),

          const SizedBox(height: 16),

          // ── Tip text
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Text(
              'Remove glasses • Ensure good lighting • Keep face centred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _toColor(String feedbackColor) => switch (feedbackColor) {
        'green' => Colors.green,
        'yellow' => Colors.amber,
        _ => Colors.red,
      };
}

// ─── Step Indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int total;
  final int current;
  final List<Uint8List?> captured;

  const _StepIndicator({
    required this.total,
    required this.current,
    required this.captured,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isDone = captured.length > i && captured[i] != null;
        final isActive = i == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 36 : 28,
            height: 6,
            decoration: BoxDecoration(
              color: isDone
                  ? Colors.green
                  : isActive
                      ? ColorPallet.primaryBlue
                      : Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Colored camera frame border ─────────────────────────────────────────────

class _CameraFrameBorder extends StatelessWidget {
  final Color color;
  final EnrollmentPhase phase;

  const _CameraFrameBorder({required this.color, required this.phase});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 3.5),
      ),
    );
  }
}

// ─── Hold progress ring ───────────────────────────────────────────────────────

class _HoldRing extends StatelessWidget {
  final double progress;
  final bool isDraining;

  const _HoldRing({required this.progress, this.isDraining = false});

  @override
  Widget build(BuildContext context) {
    final Color ringColor = isDraining ? Colors.orange : Colors.green;
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(ringColor),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ─── Score badge ──────────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final Color color = score >= 80
        ? Colors.green
        : score >= 50
            ? Colors.amber
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Text(
        '$score',
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

// ─── Captured thumbnails row ──────────────────────────────────────────────────

class _ThumbnailRow extends StatelessWidget {
  final List<Uint8List?> images;
  final List<dynamic> sequence;

  const _ThumbnailRow({required this.images, required this.sequence});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(images.length, (i) {
          final bytes = images[i];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white12,
                    border: Border.all(
                      color: bytes != null ? Colors.green : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: bytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(bytes, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.person_outline,
                          color: Colors.white38, size: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  sequence.length > i ? sequence[i].angle : '',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
