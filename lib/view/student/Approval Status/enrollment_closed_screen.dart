import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/auth_provider.dart';
import 'package:facialtrackapp/view/student/Student%20Login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Shown when the face enrollment deadline has passed and the student
/// has NOT completed face enrollment. They cannot access the dashboard.
class EnrollmentClosedScreen extends StatelessWidget {
  const EnrollmentClosedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false, // Block back navigation
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Icon ─────────────────────────────────────────────
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_clock_rounded,
                        size: 65,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Title ─────────────────────────────────────────────
                    const Text(
                      'Enrollment Window Closed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Body ──────────────────────────────────────────────
                    Text(
                      'The face enrollment deadline has passed and your '
                      'face has not been registered in the system.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Contact admin hint ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.support_agent_rounded,
                              color: Colors.orange.shade700, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please contact your administrator to request '
                              'a deadline extension or manual enrollment.',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // ── Back to Login ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPallet.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const StudentLoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
