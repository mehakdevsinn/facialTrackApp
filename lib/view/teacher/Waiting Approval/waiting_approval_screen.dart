import 'dart:async';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/view/teacher/Teacher%20Login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TeacherWaitingApprovalScreen extends StatefulWidget {
  const TeacherWaitingApprovalScreen({super.key});

  @override
  State<TeacherWaitingApprovalScreen> createState() =>
      _TeacherWaitingApprovalScreenState();
}

class _TeacherWaitingApprovalScreenState
    extends State<TeacherWaitingApprovalScreen> {
  bool isApproved = false;
  bool isRejected = false;
  bool isPolling = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _checkApprovalStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkApprovalStatus();
    });
  }

  Future<void> _checkApprovalStatus() async {
    final teacher = context.read<TeacherProvider>();
    final user = await teacher.checkApprovalStatus();

    if (!mounted) return;

    if (user == null) {
      // Token expired — stop polling silently
      _pollingTimer?.cancel();
      return;
    }

    if (user.isApproved) {
      _pollingTimer?.cancel();
      setState(() {
        isApproved = true;
        isPolling = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TeacherLoginScreen()),
          (route) => false,
        );
      }
    } else if (user.isRejected) {
      _pollingTimer?.cancel();
      setState(() {
        isRejected = true;
        isPolling = false;
      });
    }
    // If still pending, timer fires again in 5 s
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'assets/animations/face-detect.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  isRejected
                      ? 'Account Rejected'
                      : isApproved
                          ? 'Approved!'
                          : 'Registration Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isRejected
                        ? Colors.red
                        : isApproved
                            ? ColorPallet.softGreen
                            : ColorPallet.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  isRejected
                      ? 'Your account has been rejected by the administrator. Please contact support for more information.'
                      : isApproved
                          ? 'Your account has been approved. Redirecting to login...'
                          : 'Your account is pending admin approval. We\'ll notify you automatically when it\'s approved.',
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
                      color: isRejected
                          ? Colors.red.withOpacity(0.5)
                          : isApproved
                              ? ColorPallet.softGreen.withOpacity(0.5)
                              : ColorPallet.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isRejected
                            ? Icons.cancel_outlined
                            : isApproved
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                        color: isRejected
                            ? Colors.red
                            : isApproved
                                ? ColorPallet.softGreen
                                : ColorPallet.primaryBlue,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          isRejected
                              ? 'Your registration was not approved. Please contact the administrator.'
                              : isApproved
                                  ? 'Approval granted! You can now access your teacher portal.'
                                  : 'Checking approval status every 5 seconds...',
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
                if (isPolling && !isApproved && !isRejected) ...[
                  const CircularProgressIndicator(
                      color: ColorPallet.primaryBlue),
                  const SizedBox(height: 12),
                  Text(
                    'Checking every 5 seconds...',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
