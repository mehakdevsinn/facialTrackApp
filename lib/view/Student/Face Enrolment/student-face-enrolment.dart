import 'dart:async';
import 'dart:io';

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:facialtrackapp/view/Student/Face Enrolment/enrollment-result-screen.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class StudentFaceEnrolements extends StatefulWidget {
  const StudentFaceEnrolements({super.key});

  @override
  State<StudentFaceEnrolements> createState() => _StudentFaceEnrolementsState();
}

class _StudentFaceEnrolementsState extends State<StudentFaceEnrolements>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isBusy = false;
  bool _isCaptured = false; // Current step captured state
  bool _isSubmitting = false;
  bool _isPoseMatching = false; // To show green guide
  String _feedbackMessage = ""; // Corrective instruction for the user

  XFile? _currentCapturedImage;
  List<XFile> _capturedImages = [];

  // Steps configuration
  final List<Map<String, dynamic>> steps = [
    {'label': 'Straight', 'instruction': 'Look straight at the camera'},
    {'label': 'Left', 'instruction': 'Turn head left'},
    {'label': 'Right', 'instruction': 'Turn head right'},
    {'label': 'Up', 'instruction': 'Tilt head up'},
    {'label': 'Down', 'instruction': 'Tilt head down'},
  ];

  int currentStep = 0;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableTracking: true, enableLandmarks: true),
  );

  final Color primaryBlue = ColorPallet.primaryBlue;
  final Color scaffoldBg = Colors.grey[50]!;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    CameraDescription? front;

    // Find front camera
    try {
      front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      if (cameras.isNotEmpty) front = cameras[0];
    }

    if (front == null) return;

    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() {});
      await _controller!.startImageStream(_processCameraImage);
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isBusy || _isCaptured || _isSubmitting) return;
    _isBusy = true;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isBusy = false;
      return;
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        _checkPoseAndAutoCapture(face);
      } else {
        if (_isPoseMatching && mounted) {
          setState(() => _isPoseMatching = false);
        }
      }
    } catch (e) {
      print("Face detection error: $e");
    } finally {
      if (mounted) _isBusy = false;
    }
  }

  void _checkPoseAndAutoCapture(Face face) async {
    double headY = face.headEulerAngleY ?? 0; // Left/Right (Yaw)
    double headX = face.headEulerAngleX ?? 0; // Up/Down (Pitch)

    // Debugging: Print angles to console to help troubleshooting
    print(
      "Head Angles -> Yaw: ${headY.toStringAsFixed(2)}, Pitch: ${headX.toStringAsFixed(2)}",
    );

    bool poseOk = false;

    // Adjusted Thresholds for easier/smoother detection
    // Note: Android ML Kit Euler Y: negative is Right, positive is Left (usually).
    // Let's assume standard: Y+ = Left, Y- = Right. X+ = Up, X- = Down.
    // Verify with testing, but usually:
    // Head turns Left -> Y increases (> 10)
    // Head turns Right -> Y decreases (< -10)
    // Head tilts Up -> X increases (> 10)
    // Head tilts Down -> X decreases (< -10)

    String message = "";

    switch (currentStep) {
      case 0: // Straight
        if (headY.abs() < 15 && headX.abs() < 15) {
          poseOk = true;
          message = "Perfect! Hold still...";
        } else {
          if (headY > 15)
            message = "Turn Head Right";
          else if (headY < -15)
            message = "Turn Head Left";
          else if (headX > 15)
            message = "Look Down";
          else if (headX < -15)
            message = "Look Up";
          else
            message = "Look Straight";
        }
        break;
      case 1: // Left (User turns head Left -> Y increases positive)
        if (headY > 25) {
          poseOk = true;
          message = "Perfect! Hold still...";
        } else {
          message = "Turn Head Left";
        }
        break;
      case 2: // Right (User turns head Right -> Y decreases negative)
        if (headY < -25) {
          poseOk = true;
          message = "Perfect! Hold still...";
        } else {
          message = "Turn Head Right";
        }
        break;
      case 3: // Up (User looks Up -> X increases positive)
        if (headX > 15) {
          poseOk = true;
          message = "Perfect! Hold still...";
        } else {
          message = "Look Up";
        }
        break;
      case 4: // Down (User looks Down -> X decreases negative)
        if (headX < -15) {
          poseOk = true;
          message = "Perfect! Hold still...";
        } else {
          message = "Look Down";
        }
        break;
    }

    // Update UI state with feedback
    if (mounted) {
      setState(() {
        _isPoseMatching = poseOk;
        _feedbackMessage = message;
      });
    }

    if (poseOk) {
      // Optional: Add a small delay/stability check here if needed
      // For now, capture immediately
      await _capturePhoto();
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null || _controller!.description == null) return null;

    final sensorOrientation = _controller!.description.sensorOrientation;
    final inputImageFormat = InputImageFormatValue.fromRawValue(
      image.format.raw,
    );
    if (inputImageFormat == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation:
            InputImageRotationValue.fromRawValue(sensorOrientation) ??
            InputImageRotation.rotation0deg,
        format: inputImageFormat,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_isCaptured ||
        _isSubmitting ||
        _controller == null ||
        !_controller!.value.isInitialized)
      return;

    _isCaptured = true;

    try {
      await _controller!.stopImageStream();
      final xFile = await _controller!.takePicture();

      if (mounted) {
        setState(() {
          _currentCapturedImage = xFile;
          // Reset pose matching so guide goes back to neutral/white for review
          _isPoseMatching = false;
        });
      }
    } catch (e) {
      print("Capture failed: $e");
      if (mounted) {
        setState(() {
          _isCaptured = false;
        });
        await _controller!.startImageStream(_processCameraImage);
      }
    }
  }

  Future<void> _confirmAndNext() async {
    if (_currentCapturedImage == null) return;

    setState(() {
      _capturedImages.add(_currentCapturedImage!);
      _isCaptured = false;
      _currentCapturedImage = null;
      _isPoseMatching = false;
    });

    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
      await _controller!.startImageStream(_processCameraImage);
    } else {
      _finalizeEnrollment();
    }
  }

  Future<void> _finalizeEnrollment() async {
    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (mounted) {
        // Navigate to Success Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const EnrollmentResultScreen(isSuccess: true),
          ),
        );
      }
    }
  }

  void _manualCapture() {
    // Optional: Warn if pose is not matching?
    // For now, allow fallback capture.
    _capturePhoto();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalSteps = steps.length;
    double progress = (currentStep + (_isCaptured ? 1 : 0)) / totalSteps;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text("Student Enrollment"),
        backgroundColor: primaryBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryBlue),
                  const SizedBox(height: 20),
                  const Text(
                    "Submitting...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 1. Progress Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Image ${currentStep + 1} of $totalSteps",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        color: primaryBlue,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),

                // 2. Camera Preview with Face Guide
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_controller?.value.isInitialized == true)
                          _isCaptured && _currentCapturedImage != null
                              ? Image.file(
                                  File(_currentCapturedImage!.path),
                                  fit: BoxFit.cover,
                                )
                              : CameraPreview(_controller!)
                        else
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),

                        // Face Guide Overlay
                        if (!_isCaptured)
                          CustomPaint(
                            painter: FaceGuidePainter(
                              isPoseMatching: _isPoseMatching,
                              borderColor: _isPoseMatching
                                  ? Colors.greenAccent
                                  : Colors.white,
                            ),
                          ),

                        // Feedback Text Overlay (Top Center of Camera)
                        if (!_isCaptured && _isPoseMatching)
                          Positioned(
                            top: 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Perfect!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Control Board
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        steps[currentStep]['instruction'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Step ${currentStep + 1}: ${steps[currentStep]['label']}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 20),

                      if (_capturedImages.isNotEmpty)
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _capturedImages.length,
                            separatorBuilder: (c, i) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return Container(
                                width: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryBlue,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(_capturedImages[index].path),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),

                      if (_capturedImages.isNotEmpty)
                        const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: _isCaptured
                            ? ElevatedButton(
                                onPressed: _confirmAndNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  currentStep == steps.length - 1
                                      ? "Submit"
                                      : "Next",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _manualCapture,
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Capture",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class FaceGuidePainter extends CustomPainter {
  final bool isPoseMatching;
  final Color borderColor;

  FaceGuidePainter({
    this.isPoseMatching = false,
    this.borderColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPoseMatching ? 5.0 : 3.0; // Thicker if matching

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.75, // Slightly wider
      height: size.height * 0.55,
    );

    canvas.drawOval(rect, paint);

    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(rect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(bgPath, Paint()..color = Colors.black.withOpacity(0.4));
  }

  @override
  bool shouldRepaint(covariant FaceGuidePainter oldDelegate) {
    return oldDelegate.isPoseMatching != isPoseMatching ||
        oldDelegate.borderColor != borderColor;
  }
}
