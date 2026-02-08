// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class FaceEnrollmentScreen extends StatefulWidget {
//   const FaceEnrollmentScreen({super.key});

//   @override
//   State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
// }

// class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen>
//     with SingleTickerProviderStateMixin {
//   CameraController? _controller;
//   int currentStep = 1; // 0: Straight, 1: Left, 2: Right, 3: Up, 4: Bottom
//   late AnimationController _scanController;

//   final List<Map<String, dynamic>> steps = [
//     {'label': 'Straight', 'icon': Icons.face},
//     {'label': 'Left', 'icon': Icons.turn_left},
//     {'label': 'Right', 'icon': Icons.turn_right},
//     {'label': 'Up', 'icon': Icons.arrow_upward},
//     {'label': 'Bottom', 'icon': Icons.arrow_downward},
//   ];

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
//     _controller = CameraController(front, ResolutionPreset.medium);
//     await _controller!.initialize();
//     if (mounted) setState(() {});
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _scanController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0D0F),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const Icon(
//           Icons.arrow_back_ios,
//           color: Colors.white,
//           size: 18,
//         ),
//         title: const Text(
//           "Student Enrollment",
//           style: TextStyle(color: Colors.white, fontSize: 16),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           const Text(
//             "Face Enrollment",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             "Angle: ${steps[currentStep]['label']}",
//             style: const TextStyle(color: Colors.purpleAccent, fontSize: 14),
//           ),

//           const SizedBox(height: 30),

//           // Camera Frame with Scanning Animation
//           Center(
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Camera Preview
//                 Container(
//                   width: 280,
//                   height: 280,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(
//                       color: Colors.purpleAccent.withOpacity(0.5),
//                       width: 2,
//                     ),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(28),
//                     child:
//                         (_controller != null &&
//                             _controller!.value.isInitialized)
//                         ? CameraPreview(_controller!)
//                         : const Center(child: CircularProgressIndicator()),
//                   ),
//                 ),

//                 // Animated Scanning Line
//                 AnimatedBuilder(
//                   animation: _scanController,
//                   builder: (context, child) {
//                     return Positioned(
//                       top: 40 + (_scanController.value * 200),
//                       child: Container(
//                         width: 240,
//                         height: 2,
//                         decoration: BoxDecoration(
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.purpleAccent.withOpacity(0.8),
//                               blurRadius: 10,
//                               spreadRadius: 2,
//                             ),
//                           ],
//                           gradient: const LinearGradient(
//                             colors: [
//                               Colors.transparent,
//                               Colors.purpleAccent,
//                               Colors.transparent,
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//                 // Corner Borders (Styling)
//                 SizedBox(
//                   width: 300,
//                   height: 300,
//                   child: CustomPaint(painter: FramePainter()),
//                 ),

//                 // Instruction Text on Camera
//                 Positioned(
//                   bottom: 40,
//                   child: Text(
//                     "Turn your head slowly to the ${steps[currentStep]['label'].toLowerCase()}",
//                     style: const TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 40),

//           // Steps Progress Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(steps.length, (index) {
//               bool isDone = index < currentStep;
//               bool isActive = index == currentStep;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 20,
//                       backgroundColor: isDone
//                           ? Colors.green
//                           : (isActive
//                                 ? Colors.purple
//                                 : Colors.grey.withOpacity(0.2)),
//                       child: Icon(
//                         isDone ? Icons.check : steps[index]['icon'],
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       steps[index]['label'],
//                       style: TextStyle(
//                         color: isActive ? Colors.purpleAccent : Colors.grey,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),

//           const Spacer(),

//           // Capture Button
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 55),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//               ),
//               onPressed: () {
//                 if (currentStep < steps.length - 1) {
//                   setState(() => currentStep++);
//                 }
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.camera_alt_outlined, color: Colors.black),
//                   const SizedBox(width: 10),
//                   Text(
//                     "Capture ${steps[currentStep]['label']} Angle",
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Bottom Warning Note
//           Container(
//             margin: const EdgeInsets.all(20),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.purple.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Row(
//               children: [
//                 Icon(Icons.info_outline, color: Colors.purpleAccent, size: 16),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     "For best results, ensure the student is in a well-lit area.",
//                     style: TextStyle(color: Colors.white60, fontSize: 11),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Custom Painter for the Purple Corners
// class FramePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.purpleAccent
//       ..strokeWidth = 4
//       ..style = PaintingStyle.stroke;
//     final path = Path();
//     double len = 30;

//     // Top Left
//     path.moveTo(0, len);
//     path.lineTo(0, 0);
//     path.lineTo(len, 0);
//     // Top Right
//     path.moveTo(size.width - len, 0);
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, len);
//     // Bottom Left
//     path.moveTo(0, size.height - len);
//     path.lineTo(0, size.height);
//     path.lineTo(len, size.height);
//     // Bottom Right
//     path.moveTo(size.width - len, size.height);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, size.height - len);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;

// }

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isBusy = false;
  bool _canProceed = false;
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
    {'label': 'Bottom', 'icon': Icons.arrow_downward},
  ];

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
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    _controller!.startImageStream(_processCameraImage);
    if (mounted) setState(() {});
  }

  // void _processCameraImage(CameraImage image) async {
  //   if (_isBusy) return;
  //   _isBusy = true;

  //   final inputImage = _inputImageFromCameraImage(image);
  //   if (inputImage == null) {
  //     _isBusy = false;
  //     return;
  //   }

  //   final faces = await _faceDetector.processImage(inputImage);

  //   if (faces.isNotEmpty) {
  //     final face = faces.first;
  //     double headY = face.headEulerAngleY ?? 0;
  //     double headX = face.headEulerAngleX ?? 0;

  //     bool detected = false;
  //     switch (currentStep) {
  //       case 0:
  //         if (headY.abs() < 8 && headX.abs() < 8) detected = true;
  //         break;
  //       case 1:
  //         if (headY > 18) detected = true;
  //         break;
  //       case 2:
  //         if (headY < -18) detected = true;
  //         break;
  //       case 3:
  //         if (headX > 12) detected = true;
  //         break;
  //       case 4:
  //         if (headX < -12) detected = true;
  //         break;
  //     }

  //     if (detected != _canProceed) {
  //       setState(() => _canProceed = detected);
  //     }
  //   } else {
  //     if (_canProceed) setState(() => _canProceed = false);
  //   }
  //   _isBusy = false;
  // }

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

        // Sirf tab update karein jab status change ho
        if (detected != _canProceed) {
          setState(() {
            _canProceed = detected;
          });
        }
      } else {
        // Agar koi face nahi hai toh button disable rakhein
        if (_canProceed) {
          setState(() {
            _canProceed = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    _isBusy = false;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
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

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
        _canProceed = false;
      });
    } else {
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Success", style: TextStyle(color: primaryBlue)),
        content: const Text("Face Enrollment Completed Successfully!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Done", style: TextStyle(color: primaryBlue)),
          ),
        ],
      ),
    );
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
          style: TextStyle(
            color: Colors.white,
            // fontSize: 18,
            // fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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

                    // Corner Brackets
                    // SizedBox(
                    //   width: 310,
                    //   height: 310,
                    //   child: CustomPaint(
                    //     painter: LightCornerPainter(primaryBlue),
                    //   ),
                    // ),
                    // Corner Brackets inside the Stack
                    SizedBox(
                      width: 310,
                      height: 310,
                      child: CustomPaint(
                        painter: LightCornerPainter(
                          _canProceed
                              ? Colors.green
                              : primaryBlue, // Color badal jayega
                        ),
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
                  bool isDone = index < currentStep;
                  bool isActive = index == currentStep;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green
                                : (isActive ? primaryBlue : Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),

                          child: Icon(
                            isDone ? Icons.check : steps[index]['icon'],
                            color: isDone || isActive
                                ? Colors.white
                                : Colors.black,
                            size: 18,
                          ),
                        ),

                        // CircleAvatar(
                        //   radius: 20,
                        //   backgroundColor: isDone
                        //       ? Colors.green
                        //       : (isActive ? primaryBlue : Colors.white),
                        //   child: Icon(
                        //     isDone ? Icons.check : steps[index]['icon'],
                        //     color: isDone || isActive
                        //         ? Colors.white
                        //         : Colors.black26,
                        //     size: 18,
                        //   ),
                        // ),
                        const SizedBox(height: 4),
                        Text(
                          steps[index]['label'],
                          style: TextStyle(
                            color: isActive ? primaryBlue : Colors.black,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // const Spacer(),
              SizedBox(height: 11),

              // Main Blue Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  // child: ElevatedButton(
                  //   onPressed: _canProceed ? _nextStep : SizedBox.shrink,
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: _canProceed
                  //         ? ColorPallet.primaryBlue
                  //         : Colors.grey.shade400,
                  //     disabledBackgroundColor: Colors.grey[300],
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     elevation: 2,
                  //   ),
                  //   child: Text(
                  //     "Capture ${steps[currentStep]['label']} Angle",
                  //     style: TextStyle(
                  //       color: _canProceed
                  //           ? Colors.white
                  //           : const Color.fromARGB(66, 21, 21, 21),
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 16,
                  //     ),
                  //   ),
                  // ),
                  child: // Button code inside build method
                  ElevatedButton(
                    onPressed: _canProceed
                        ? _nextStep
                        : null, // null dene se button automatically disable ho jata hai
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canProceed
                          ? ColorPallet.primaryBlue
                          : Colors.grey.shade400,
                      // ... baki styling
                    ),
                    child: Text(
                      _canProceed
                          ? "Next Step"
                          : "Position Your Face", // Text change karein feedback ke liye
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // // Instruction Note
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                  left: 30,
                  right: 30,
                  top: 9,
                ),
                child: Center(
                  child: Text(
                    // "Secure Facial Enrollment",
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

// import 'package:facialtrackapp/constants/color_pallet.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// class FaceEnrollmentScreen extends StatefulWidget {
//   const FaceEnrollmentScreen({super.key});

//   @override
//   State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
// }

// class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen>
//     with SingleTickerProviderStateMixin {
//   CameraController? _controller;
//   bool _isBusy = false;
//   bool _canProceed = false; // Button enable/disable control
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
//           if (headY > 20) detected = true;
//           break;
//         case 2:
//           if (headY < -20) detected = true;
//           break;
//         case 3:
//           if (headX > 15) detected = true;
//           break;
//         case 4:
//           if (headX < -15) detected = true;
//           break;
//       }

//       if (detected != _canProceed) {
//         setState(() => _canProceed = detected);
//       }
//     } else {
//       if (_canProceed) setState(() => _canProceed = false);
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

//   void _nextStep() {
//     if (currentStep < steps.length - 1) {
//       setState(() {
//         currentStep++;
//         _canProceed = false; // Reset for next angle
//       });
//     } else {
//       _showSuccess();
//     }
//   }

//   void _showSuccess() {
//     showDialog(
//       context: context,
//       builder: (context) => const AlertDialog(
//         title: Text("Success"),
//         content: Text("Enrollment Complete!"),
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
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const Icon(
//           Icons.arrow_back_ios,
//           color: Colors.white,
//           size: 18,
//         ),
//         title: const Text(
//           "Student Enrollment",
//           style: TextStyle(color: Colors.black, fontSize: 16),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           const Text(
//             "Face Enrollment",
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             "Angle: ${steps[currentStep]['label']}",
//             style: TextStyle(color: ColorPallet.primaryBlue, fontSize: 14),
//           ),

//           const SizedBox(height: 30),

//           // Camera Design from Image
//           Center(
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 280,
//                   height: 280,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(40),
//                     border: Border.all(color: Colors.white10, width: 1),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(38),
//                     child:
//                         (_controller != null &&
//                             _controller!.value.isInitialized)
//                         ? CameraPreview(_controller!)
//                         : Container(color: Colors.black26),
//                   ),
//                 ),
//                 // Scanning Line
//                 AnimatedBuilder(
//                   animation: _scanController,
//                   builder: (context, child) => Positioned(
//                     top: 60 + (_scanController.value * 160),
//                     child: Container(
//                       width: 220,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         boxShadow: [
//                           BoxShadow(
//                             color: ColorPallet.primaryBlue.withOpacity(0.5),
//                             blurRadius: 10,
//                           ),
//                         ],
//                         gradient: const LinearGradient(
//                           colors: [
//                             Colors.transparent,
//                             ColorPallet.primaryBlue,
//                             Colors.transparent,
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Corners
//                 SizedBox(
//                   width: 300,
//                   height: 300,
//                   child: CustomPaint(painter: CornerPainter()),
//                 ),
//                 // Instruction on Camera
//                 Positioned(
//                   bottom: 50,
//                   child: Text(
//                     "Turn your head slowly to the ${steps[currentStep]['label'].toLowerCase()}",
//                     style: const TextStyle(
//                       color: Color.fromARGB(153, 122, 122, 122),
//                       fontSize: 11,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 40),

//           // Steps Progress (Circles)
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(steps.length, (index) {
//               bool isDone = index < currentStep;
//               bool isActive = index == currentStep;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 22,
//                       backgroundColor: isDone
//                           ? const Color(0xFF2ECC71)
//                           : (isActive
//                                 ? const Color(0xFF8E44AD)
//                                 : Colors.white10),
//                       child: Icon(
//                         isDone ? Icons.check : steps[index]['icon'],
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       steps[index]['label'],
//                       style: TextStyle(
//                         color: isActive
//                             ? ColorPallet.primaryBlue
//                             : Colors.white38,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),

//           const Spacer(),

//           // Capture Button - Enabled only when angle is detected
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: _canProceed ? _nextStep : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.white10,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.camera_alt_outlined,
//                       color: _canProceed ? Colors.black : Colors.white24,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       "Capture ${steps[currentStep]['label']} Angle",
//                       style: TextStyle(
//                         color: _canProceed ? Colors.black : Colors.white24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Bottom Info Box
//           Container(
//             margin: const EdgeInsets.all(20),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Row(
//               children: [
//                 Icon(
//                   Icons.info_outline,
//                   color: ColorPallet.primaryBlue,
//                   size: 18,
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     "For best results, ensure the student is in a well-lit area and removes glasses during the scan.",
//                     style: TextStyle(
//                       color: Color.fromARGB(153, 134, 134, 134),
//                       fontSize: 11,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CornerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.purpleAccent
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke;
//     double l = 25;
//     canvas.drawPath(
//       Path()
//         ..moveTo(0, l)
//         ..lineTo(0, 0)
//         ..lineTo(l, 0),
//       paint,
//     );
//     canvas.drawPath(
//       Path()
//         ..moveTo(size.width - l, 0)
//         ..lineTo(size.width, 0)
//         ..lineTo(size.width, l),
//       paint,
//     );
//     canvas.drawPath(
//       Path()
//         ..moveTo(0, size.height - l)
//         ..lineTo(0, size.height)
//         ..lineTo(l, size.height),
//       paint,
//     );
//     canvas.drawPath(
//       Path()
//         ..moveTo(size.width - l, size.height)
//         ..lineTo(size.width, size.height)
//         ..lineTo(size.width, size.height - l),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// class FaceEnrollmentScreen extends StatefulWidget {
//   const FaceEnrollmentScreen({super.key});

//   @override
//   State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
// }

// class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen>
//     with SingleTickerProviderStateMixin {
//   CameraController? _controller;
//   bool _isBusy = false;
//   int currentStep = 0; // 0: Straight, 1: Left, 2: Right, 3: Up, 4: Bottom
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

//     // Start Streaming frames for detection
//     _controller!.startImageStream(_processCameraImage);

//     if (mounted) setState(() {});
//   }

//   // Real-time Face Detection Logic
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

//       // Detection Rules based on Head Euler Angles
//       bool isCorrectAngle = false;
//       double headY = face.headEulerAngleY ?? 0; // Turn Left/Right
//       double headX = face.headEulerAngleX ?? 0; // Tilt Up/Down

//       switch (currentStep) {
//         case 0: // Straight
//           if (headY.abs() < 10 && headX.abs() < 10) isCorrectAngle = true;
//           break;
//         case 1: // Left (Face turns left, Y is positive)
//           if (headY > 20) isCorrectAngle = true;
//           break;
//         case 2: // Right (Face turns right, Y is negative)
//           if (headY < -20) isCorrectAngle = true;
//           break;
//         case 3: // Up
//           if (headX > 15) isCorrectAngle = true;
//           break;
//         case 4: // Bottom
//           if (headX < -15) isCorrectAngle = true;
//           break;
//       }

//       if (isCorrectAngle) {
//         _moveToNextStep();
//       }
//     }

//     _isBusy = false;
//   }

//   void _moveToNextStep() {
//     if (currentStep < steps.length - 1) {
//       setState(() {
//         currentStep++;
//       });
//       // Short delay to let user stabilize
//       Future.delayed(const Duration(seconds: 1));
//     } else {
//       // All steps done!
//       _controller?.stopImageStream();
//       _showSuccessDialog();
//     }
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Success"),
//         content: const Text("Face Enrollment Completed!"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Convert CameraImage to InputImage for ML Kit
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

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _scanController.dispose();
//     _faceDetector.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // UI remains same as previous but button is removed or disabled
//     // because logic is now automatic
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0D0F),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text("Student Enrollment"),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           const Text(
//             "Face Enrollment",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             "Instruction: Turn your head to the ${steps[currentStep]['label']}",
//             style: const TextStyle(color: Colors.purpleAccent, fontSize: 14),
//           ),

//           const SizedBox(height: 30),

//           // Camera Frame
//           Center(
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 280,
//                   height: 280,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(
//                       color: Colors.purpleAccent.withOpacity(0.5),
//                     ),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(28),
//                     child:
//                         (_controller != null &&
//                             _controller!.value.isInitialized)
//                         ? CameraPreview(_controller!)
//                         : const Center(child: CircularProgressIndicator()),
//                   ),
//                 ),
//                 // Scanning Line Animation
//                 AnimatedBuilder(
//                   animation: _scanController,
//                   builder: (context, child) => Positioned(
//                     top: 40 + (_scanController.value * 200),
//                     child: Container(
//                       width: 240,
//                       height: 2,
//                       color: Colors.purpleAccent,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 40),

//           // Steps Row (Turns Green Automatically)
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(steps.length, (index) {
//               bool isDone = index < currentStep;
//               bool isActive = index == currentStep;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: CircleAvatar(
//                   radius: 20,
//                   backgroundColor: isDone
//                       ? Colors.green
//                       : (isActive
//                             ? Colors.purple
//                             : Colors.grey.withOpacity(0.2)),
//                   child: Icon(
//                     isDone ? Icons.check : steps[index]['icon'],
//                     color: Colors.white,
//                     size: 18,
//                   ),
//                 ),
//               );
//             }),
//           ),
//           const Spacer(),
//           const Padding(
//             padding: EdgeInsets.all(20.0),
//             child: Text(
//               "Detection is automatic. Please follow instructions.",
//               style: TextStyle(color: Colors.white54),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
