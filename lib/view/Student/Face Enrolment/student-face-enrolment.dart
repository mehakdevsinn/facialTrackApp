import 'dart:io';
import 'package:camera/camera.dart';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';
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
  bool _canProceed = false;
  bool _isSubmitting = false;
  int currentStep = 0;
  late AnimationController _scanController;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableTracking: true, enableLandmarks: true),
  );

  final List<Map<String, dynamic>> steps = [
    {'label': 'Straight', 'icon': Icons.face},
    {'label': 'Left', 'icon': Icons.turn_left},
    {'label': 'Right', 'icon': Icons.turn_right},
    {'label': 'Up', 'icon': Icons.arrow_upward},
    {'label': 'Down', 'icon': Icons.arrow_downward},
  ];

  // Store captured images for each step.
  // Map key will be the step index, value is the XFile (image).
  final Map<int, XFile?> _capturedImages = {};

  // Theme Colors based on your Login Screen image
  final Color primaryBlue = ColorPallet.primaryBlue;
  final Color scaffoldBg = Colors.grey[100]!;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    CameraDescription? front;
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
      _controller!.startImageStream(_processCameraImage);
      setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
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
        double headY = face.headEulerAngleY ?? 0; // Left/Right
        double headX = face.headEulerAngleX ?? 0; // Up/Down

        bool detected = false;

        // Detection Logic based on current step
        switch (currentStep) {
          case 0: // Straight
            if (headY.abs() < 10 && headX.abs() < 10) detected = true;
            break;
          case 1: // Left (User turns face left, Euler Y is positive)
            if (headY > 20) detected = true;
            break;
          case 2: // Right (User turns face right, Euler Y is negative)
            if (headY < -20) detected = true;
            break;
          case 3: // Up
            if (headX > 15) detected = true;
            break;
          case 4: // Down
            if (headX < -15) detected = true;
            break;
        }

        if (detected != _canProceed) {
          if (mounted) {
            setState(() {
              _canProceed = detected;
            });
          }
        }
      } else {
        if (_canProceed) {
          if (mounted) {
            setState(() {
              _canProceed = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    _isBusy = false;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;
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

  Future<void> _captureAndNextStep() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Pause stream to capture
      await _controller!.stopImageStream();

      // Capture the image
      XFile image = await _controller!.takePicture();

      if (mounted) {
        setState(() {
          _capturedImages[currentStep] = image;
        });
      }

      if (currentStep < steps.length - 1) {
        setState(() {
          currentStep++;
          _canProceed = false;
        });
        // Resume stream for next step
        await _controller!.startImageStream(_processCameraImage);
      } else {
        _showSuccess();
      }
    } catch (e) {
      debugPrint("Error capturing image: $e");
      // Attempt to restart stream if something failed
      try {
        await _controller!.startImageStream(_processCameraImage);
      } catch (_) {}
    }
  }

  void _showSuccess() async {
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

  @override
  void dispose() {
    _controller?.dispose();
    _scanController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: ColorPallet.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Student Enrollment",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryBlue),
                  const SizedBox(height: 20),
                  const Text(
                    "Verifying...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: Text(
                        "Face Enrollment",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: const Text(
                        "Position your face within the frame",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Camera Frame with Corner Brackets
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child:
                                  (_controller != null &&
                                      _controller!.value.isInitialized)
                                  ? CameraPreview(_controller!)
                                  : Container(
                                      color: Colors.grey[400],
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 50,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                            ),
                          ),

                          // Blue Scan Animation Line
                          AnimatedBuilder(
                            animation: _scanController,
                            builder: (context, child) => Positioned(
                              top: 40 + (_scanController.value * 200),
                              child: Container(
                                width: 220,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      primaryBlue,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Corner Brackets inside the Stack
                          SizedBox(
                            width: 310,
                            height: 310,
                            child: CustomPaint(
                              painter: LightCornerPainter(primaryBlue),
                            ),
                          ),

                          // Label for Current Step
                          Positioned(
                            bottom: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Look ${steps[currentStep]['label']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Step Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(steps.length, (index) {
                        bool isActive = index == currentStep;
                        bool hasImage = _capturedImages.containsKey(index);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: isActive ? primaryBlue : Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ), // Squared/rounded for image
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                  border: isActive
                                      ? Border.all(color: primaryBlue, width: 2)
                                      : null,
                                ),
                                child: hasImage
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_capturedImages[index]!.path),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          isActive
                                              ? steps[index]['icon']
                                              : steps[index]['icon'],
                                          color: isActive
                                              ? Colors.white
                                              : Colors.grey[400],
                                          size: 20,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                steps[index]['label'],
                                style: TextStyle(
                                  color: isActive
                                      ? primaryBlue
                                      : Colors.black54,
                                  fontSize: 10,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 11),

                    // Main Blue Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _captureAndNextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPallet.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Capture",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),

                    // Instruction Note
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                        left: 30,
                        right: 30,
                        top: 9,
                      ),
                      child: Center(
                        child: Text(
                          "For best result , student ensure background is clear, remove glasses and mask during scan",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class LightCornerPainter extends CustomPainter {
  final Color color;
  LightCornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    double l = 30;
    canvas.drawPath(
      Path()
        ..moveTo(0, l)
        ..lineTo(0, 0)
        ..lineTo(l, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - l, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, l),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - l)
        ..lineTo(0, size.height)
        ..lineTo(l, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - l, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
