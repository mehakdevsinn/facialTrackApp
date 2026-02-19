import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/student/Student%20NavBar/student-root_screen.dart';
import 'package:flutter/material.dart';

class EnrollmentResultScreen extends StatelessWidget {
  final bool isSuccess;

  const EnrollmentResultScreen({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 80,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              isSuccess
                  ? "Face Verification\nCompleted"
                  : "Verification Failed",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorPallet.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              isSuccess
                  ? "Face verification completed successfully. You can now use the attendance system."
                  : "Face verification failed. Please try again or contact Admin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Spacer(),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (isSuccess) {
                    // Navigate to Dashboard - Replace with your dashboard route
                    //  Navigator.of(context).pushNamedAndRemoveUntil('/studentData', (route) => false);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentRootScreen(),
                      ),
                    );
                  } else {
                    // Retry: Pop back to enrollment
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPallet.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isSuccess ? "Go to Dashboard" : "Retry",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!isSuccess) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // TODO: Implement contact admin logic
                },
                child: const Text(
                  "Contact Admin",
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorPallet.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
