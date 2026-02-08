import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Student/Face%20Enrolment/student-face-enrolment.dart';
import 'package:flutter/material.dart';

class FaceVerificationPrompt extends StatelessWidget {
  final bool isDeadlineExpired;

  const FaceVerificationPrompt({
    super.key,
    this.isDeadlineExpired = false, // Mock default; pass true to test expired state
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = ColorPallet.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify Your Face"),
        backgroundColor: primaryBlue,
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              Icons.face_retouching_natural,
              size: 100,
              color: primaryBlue,
            ),
            const SizedBox(height: 30),
            Text(
              "Face Verification Required",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isDeadlineExpired) ...[
               Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Face verification window has expired. Please contact Admin.",
                        style: TextStyle(color: Colors.red[900], fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                "To use the attendance system, please complete face verification. We will capture 3–5 photos of your face from different angles.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
            const Spacer(),
            if (!isDeadlineExpired) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StudentFace()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Start Face Verification",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                   // Navigate to Dashboard or relevant screen
                   // For now, simple pop or placeholder
                   Navigator.pop(context); 
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                child: const Text("Not now"),
              ),
            ] else ...[
               ElevatedButton(
                onPressed: () {
                  // Contact admin action or just close
                   Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Go Back"),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
