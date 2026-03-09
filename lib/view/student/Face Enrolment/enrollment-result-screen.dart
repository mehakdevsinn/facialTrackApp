import 'dart:typed_data';

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/student/Student%20NavBar/student-root_screen.dart';
import 'package:flutter/material.dart';

/// Shown after all 3 face images are uploaded successfully.
/// Receives the actual captured thumbnails to display.
class EnrollmentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final List<Uint8List> capturedImages;

  const EnrollmentResultScreen({
    super.key,
    required this.isSuccess,
    this.capturedImages = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Icon
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color:
                      (isSuccess ? Colors.green : Colors.red).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 72,
                ),
              ),
              const SizedBox(height: 28),

              // ── Title
              Text(
                isSuccess
                    ? 'Face Enrollment\nComplete 🎉'
                    : 'Enrollment Failed',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // ── Subtitle
              Text(
                isSuccess
                    ? 'Your face data has been saved successfully. You can now use the attendance system.'
                    : 'Something went wrong during upload. Please try enrolling again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: Colors.grey[600], height: 1.5),
              ),

              // ── Captured thumbnails (success only)
              if (isSuccess && capturedImages.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'Captured photos',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(capturedImages.length, (i) {
                    final labels = ['Center', 'Left', 'Right'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.green.shade300, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                capturedImages[i],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            i < labels.length ? labels[i] : '',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],

              const Spacer(flex: 3),

              // ── CTA
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (isSuccess) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StudentRootScreen()),
                        (route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess
                        ? ColorPallet.primaryBlue
                        : Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isSuccess ? 'Go to Dashboard' : 'Try Again',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
