import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/view/student/Approval%20Status/enrollment_closed_screen.dart';
import 'package:facialtrackapp/view/student/Face%20Enrolment/student-face-enrolment.dart';
import 'package:facialtrackapp/view/student/Student%20NavBar/student-root_screen.dart';
import 'package:flutter/material.dart';

/// Entry point shown after login when `user.faceVerified == false`.
///
/// Calls GET /students/face/enrollment-window and routes based on:
///
///   enrollment_open == true
///     → Face Enrollment Screen  (window open, student not yet enrolled)
///
///   enrollment_open == false + student_enrolled == true
///     → Student Dashboard       (already enrolled)
///
///   enrollment_open == false + student_enrolled == false + deadline set
///     → Enrollment Closed Screen (deadline passed, never enrolled)
///
///   enrollment_open == false + student_enrolled == false + no deadline
///     → Student Dashboard       (no deadline configured by admin)
class FaceVerificationPrompt extends StatefulWidget {
  const FaceVerificationPrompt({super.key});

  @override
  State<FaceVerificationPrompt> createState() => _FaceVerificationPromptState();
}

class _FaceVerificationPromptState extends State<FaceVerificationPrompt> {
  bool _checking = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkEnrollmentWindow();
  }

  Future<void> _checkEnrollmentWindow() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final window = await ApiManager.instance.getEnrollmentWindow();
      if (!mounted) return;

      if (window.enrollmentOpen) {
        // ── Case 2: window open → show enrollment prompt ──────────────────
        setState(() => _checking = false);
        return;
      }

      if (window.studentEnrolled) {
        // ── Case 1: already enrolled → go to dashboard ────────────────────
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StudentRootScreen()),
          (route) => false,
        );
        return;
      }

      // student NOT enrolled, window NOT open
      if (window.deadline != null) {
        // ── Case 3: deadline passed, never enrolled → blocked ─────────────
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EnrollmentClosedScreen()),
          (route) => false,
        );
      } else {
        // ── Case 4: No deadline configured → force them to enroll ──────────
        setState(() => _checking = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error = e.toString();
      });
    }
  }

  void _startEnrollment() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StudentFaceEnrollement()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _checking ? _buildChecking() : _buildPrompt(),
    );
  }

  Widget _buildChecking() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: ColorPallet.primaryBlue),
          SizedBox(height: 20),
          Text(
            'Checking enrollment status…',
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildPrompt() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Icon
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: ColorPallet.primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.face_retouching_natural_rounded,
                color: ColorPallet.primaryBlue,
                size: 58,
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Face Enrollment Required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'To use the attendance system, you need to complete a one-time face enrollment. '
              'We\'ll capture 3 photos from different angles — this takes less than a minute.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),

            _buildStepRow(Icons.filter_center_focus_rounded, 'Center',
                'Look straight at the camera'),
            const SizedBox(height: 10),
            _buildStepRow(Icons.turn_right_rounded, 'Left angle',
                'Turn head slightly right'),
            const SizedBox(height: 10),
            _buildStepRow(Icons.turn_left_rounded, 'Right angle',
                'Turn head slightly left'),

            const Spacer(flex: 3),

            // Error
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style:
                            TextStyle(color: Colors.red.shade900, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: _checkEnrollmentWindow,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // CTA
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _startEnrollment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPallet.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Start Face Enrollment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorPallet.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: ColorPallet.primaryBlue, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1E293B))),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }
}
