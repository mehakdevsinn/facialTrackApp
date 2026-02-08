import 'dart:async';
import 'dart:io';

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class StudentFace extends StatefulWidget {
  const StudentFace({super.key});

  @override
  State<StudentFace> createState() => _StudentFaceState();
}

class _StudentFaceState extends State<StudentFace>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isBusy = false;
  bool _isCaptured = false;

  XFile? _capturedImage;
  int currentStep = 0;

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

  final Color primaryBlue = ColorPallet.primaryBlue;
  final Color scaffoldBg = Colors.grey[100]!;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    await _controller!.startImageStream(_processCameraImage);

    if (mounted) setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (_isBusy || _isCaptured) return; // Stop processing if already captured
    _isBusy = true;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isBusy = false;
      return;
    }

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty && !_isCaptured) {
      final face = faces.first;
      double headY = face.headEulerAngleY ?? 0;
      double headX = face.headEulerAngleX ?? 0;

      bool poseOk = false;

      switch (currentStep) {
        case 0: // straight
          if (headY.abs() < 8 && headX.abs() < 8) poseOk = true;
          break;
        case 1: // left
          if (headY > 18) poseOk = true;
          break;
        case 2: // right
          if (headY < -18) poseOk = true;
          break;
        case 3: // up
          if (headX > 12) poseOk = true;
          break;
        case 4: // down
          if (headX < -12) poseOk = true;
          break;
      }

      if (poseOk) {
        print("Pose matched for step $currentStep -> Capturing");
        _isBusy = false; // Ensure busy flag is cleared before capture logic
        await _capturePhoto();
        return; // Exit to avoid race conditions
      }
    }

    _isBusy = false;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // Check if controller is initialized to avoid null access
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
    if (_isCaptured) return; // Prevent double capture

    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      // Stop stream before taking picture
      await _controller!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 150));

      final photo = await _controller!.takePicture();

      if (mounted) {
        setState(() {
          _capturedImage = photo;
          _isCaptured = true;
        });
      }

      // Removed dialog show
    } catch (e) {
      print("Capture Error: $e");
      // If error, try to restart stream
      if (!_controller!.value.isStreamingImages) {
        await _controller!.startImageStream(_processCameraImage);
      }
    }
  }

  Future<void> _goNext() async {
    if (currentStep < steps.length - 1) {
      setState(() {
        _isCaptured = false;
        _capturedImage = null;
        currentStep++;
      });
      // Restart camera stream for next step
      await _controller!.startImageStream(_processCameraImage);
    } else {
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Success", style: TextStyle(color: primaryBlue)),
        content: const Text("Face Enrollment Completed Successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: Text("Done", style: TextStyle(color: primaryBlue)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text("Student Enrollment"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            "Step ${currentStep + 1}/${steps.length}: Look ${steps[currentStep]['label']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryBlue, width: 2),
                color: Colors.black,
              ),
              clipBehavior: Clip.hardEdge,
              child: _controller?.value.isInitialized == true
                  ? (_isCaptured && _capturedImage != null
                        ? Image.file(
                            File(_capturedImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : CameraPreview(_controller!))
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCaptured
                    ? _goNext
                    : null, // Enabled only if captured
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  disabledBackgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  currentStep == steps.length - 1 ? "Finish" : "Next",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:io';

// import 'package:facialtrackapp/constants/color_pallet.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// class StudentFace extends StatefulWidget {
//   const StudentFace({super.key});

//   @override
//   State<StudentFace> createState() => _StudentFaceState();
// }

// class _StudentFaceState extends State<StudentFace>
//     with SingleTickerProviderStateMixin {
//   CameraController? _controller;
//   bool _isBusy = false;
//   bool _canProceed = false;
//   bool _isCaptured = false;

//   XFile? _capturedImage;

//   int currentStep = 0;
//   late AnimationController _scanController;

//   final FaceDetector _faceDetector = FaceDetector(
//     options: FaceDetectorOptions(enableTracking: true, enableLandmarks: true),
//   );

//   final List<Map<String, dynamic>> steps = [
//     {'label': 'Straight', 'icon': Icons.face},
//     {'label': 'Left', 'icon': Icons.turn_left},
//     {'label': 'Right', 'icon': Icons.turn_right},
//     {'label': 'Up', 'icon': Icons.arrow_upward},
//     {'label': 'Bottom', 'icon': Icons.arrow_downward},
//   ];

//   final Color primaryBlue = ColorPallet.primaryBlue;
//   final Color scaffoldBg = Colors.grey[100]!;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _scanController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final front = cameras.firstWhere(
//       (c) => c.lensDirection == CameraLensDirection.front,
//     );
//     _controller = CameraController(
//       front,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );
//     await _controller!.initialize();
//     _controller!.startImageStream(_processCameraImage);

//     if (mounted) setState(() {});
//   }

//   void _processCameraImage(CameraImage image) async {
//     if (_isBusy) return;
//     _isBusy = true;

//     final inputImage = _inputImageFromCameraImage(image);
//     if (inputImage == null) {
//       _isBusy = false;
//       return;
//     }

//     final faces = await _faceDetector.processImage(inputImage);

//     if (faces.isNotEmpty) {
//       final face = faces.first;
//       double headY = face.headEulerAngleY ?? 0;
//       double headX = face.headEulerAngleX ?? 0;

//       bool detected = false;
//       switch (currentStep) {
//         case 0:
//           if (headY.abs() < 8 && headX.abs() < 8) detected = true;
//           break;
//         case 1:
//           if (headY > 18) detected = true;
//           break;
//         case 2:
//           if (headY < -18) detected = true;
//           break;
//         case 3:
//           if (headX > 12) detected = true;
//           break;
//         case 4:
//           if (headX < -12) detected = true;
//           break;
//       }

//       if (detected) {
//         if (!_canProceed) {
//           setState(() => _canProceed = true);
//         }
//         if (!_isCaptured) {
//           _isCaptured = true;
//           _capturePhoto();
//         }
//       } else {
//         if (_canProceed) setState(() => _canProceed = false);
//         _isCaptured = false;
//       }
//     } else {
//       if (_canProceed) setState(() => _canProceed = false);
//       _isCaptured = false;
//     }

//     _isBusy = false;
//   }

//   InputImage? _inputImageFromCameraImage(CameraImage image) {
//     final sensorOrientation = _controller!.description.sensorOrientation;
//     final inputImageFormat = InputImageFormatValue.fromRawValue(
//       image.format.raw,
//     );
//     if (inputImageFormat == null) return null;
//     final plane = image.planes.first;
//     return InputImage.fromBytes(
//       bytes: plane.bytes,
//       metadata: InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation:
//             InputImageRotationValue.fromRawValue(sensorOrientation) ??
//             InputImageRotation.rotation0deg,
//         format: inputImageFormat,
//         bytesPerRow: plane.bytesPerRow,
//       ),
//     );
//   }

//   Future<void> _capturePhoto() async {
//     try {
//       if (_controller == null || !_controller!.value.isInitialized) return;

//       final photo = await _controller!.takePicture();
//       _capturedImage = photo;

//       if (mounted) setState(() {});

//       _showPhotoCaptured(photo.path);
//     } catch (e) {
//       print("Capture Error: $e");
//     }
//   }

//   void _showPhotoCaptured(String path) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text("Captured!", style: TextStyle(color: primaryBlue)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.file(File(path)),
//             const SizedBox(height: 8),
//             const Text("Face captured successfully."),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("OK", style: TextStyle(color: primaryBlue)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _nextStep() {
//     if (currentStep < steps.length - 1) {
//       setState(() {
//         currentStep++;
//         _canProceed = false;
//         _isCaptured = false;
//       });
//     } else {
//       _showSuccess();
//     }
//   }

//   void _showSuccess() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text("Success", style: TextStyle(color: primaryBlue)),
//         content: const Text("Face Enrollment Completed Successfully!"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Done", style: TextStyle(color: primaryBlue)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _scanController.dispose();
//     _faceDetector.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: scaffoldBg,
//       appBar: AppBar(
//         backgroundColor: primaryBlue,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Student Enrollment",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 12),
//               Text(
//                 "Look ${steps[currentStep]['label']}",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               Center(
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       width: 280,
//                       height: 280,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(25),
//                         boxShadow: [
//                           BoxShadow(color: Colors.black26, blurRadius: 12),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(25),
//                         child:
//                             (_controller != null &&
//                                 _controller!.value.isInitialized)
//                             ? CameraPreview(_controller!)
//                             : Container(color: Colors.grey[400]),
//                       ),
//                     ),

//                     AnimatedBuilder(
//                       animation: _scanController,
//                       builder: (context, child) => Positioned(
//                         top: 40 + (_scanController.value * 200),
//                         child: Container(
//                           width: 220,
//                           height: 2,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.transparent,
//                                 primaryBlue,
//                                 Colors.transparent,
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 30),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(steps.length, (index) {
//                   bool isDone = index < currentStep;
//                   bool isActive = index == currentStep;
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 6),
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 20,
//                           backgroundColor: isDone
//                               ? Colors.green
//                               : (isActive ? primaryBlue : Colors.white),
//                           child: Icon(
//                             isDone ? Icons.check : steps[index]['icon'],
//                             color: isDone || isActive
//                                 ? Colors.white
//                                 : Colors.black26,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           steps[index]['label'],
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: isActive ? primaryBlue : Colors.black54,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ),

//               const SizedBox(height: 20),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: ElevatedButton(
//                   onPressed: _canProceed ? _nextStep : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _canProceed ? primaryBlue : Colors.grey,
//                     minimumSize: const Size(double.infinity, 55),
//                   ),
//                   child: Text(
//                     _canProceed ? "Next" : "Hold Still to Capture",
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 14),
//               const Text(
//                 "Ensure clear background, no glasses/mask during scan",
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
