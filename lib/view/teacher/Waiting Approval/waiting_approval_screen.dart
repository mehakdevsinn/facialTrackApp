import 'dart:async';
import 'package:facialtrackapp/constants/color_pallet.dart';
import '../Teacher%20Login/login.dart';
import 'package:facialtrackapp/view/student/Student%20Login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class WaitingApprovalScreen extends StatefulWidget {
  final String userType; // 'Teacher' or 'Student'

  const WaitingApprovalScreen({super.key, this.userType = 'Teacher'});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
  bool isApproved = false;

  @override
  void initState() {
    super.initState();
    // Simulate admin approval delay
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          isApproved = true;
        });

        // Short delay to show approved state then navigate
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => widget.userType == 'Student'
                    ? const StudentLoginScreen()
                    : const TeacherLoginScreen(),
              ),
              (route) => false,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    isApproved
                        ? 'assets/animations/face-detect.json' // Replace with a success animation if you have one
                        : 'assets/animations/face-detect.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  isApproved ? "Approved!" : "Registration Successful!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isApproved
                        ? ColorPallet.softGreen
                        : ColorPallet.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  isApproved
                      ? "Your account has been approved. Redirecting to login..."
                      : "Your account is pending admin approval. Please wait for the administrator to approve your request.",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorPallet.lightGray,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isApproved
                          ? ColorPallet.softGreen.withOpacity(0.5)
                          : ColorPallet.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isApproved
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: isApproved
                            ? ColorPallet.softGreen
                            : ColorPallet.primaryBlue,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          isApproved
                              ? "Approval granted! You can now access your ${widget.userType.toLowerCase()} portal."
                              : "Once approved, you will be able to log in to your ${widget.userType.toLowerCase()} portal.",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!isApproved)
                  const CircularProgressIndicator(
                    color: ColorPallet.primaryBlue,
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
