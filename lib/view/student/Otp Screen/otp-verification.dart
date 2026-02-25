import 'dart:async';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/auth_provider.dart';
import 'package:facialtrackapp/view/student/Student%20Waiting%20Approval/student_waiting_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool isButtonEnabled = false;

  late List<FocusNode> focusNodes;

  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  Timer? _resendTimer;
  int _resendCooldown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    focusNodes = List.generate(4, (index) => FocusNode());
    for (var controller in otpControllers) {
      controller.addListener(_checkIfAllFieldsFilled);
    }
    for (var node in focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  void _checkIfAllFieldsFilled() {
    bool allFilled =
        otpControllers.every((ctrl) => ctrl.text.trim().isNotEmpty);
    if (allFilled != isButtonEnabled) {
      setState(() => isButtonEnabled = allFilled);
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCooldown > 0) {
            _resendCooldown--;
          } else {
            _canResend = true;
            _resendTimer?.cancel();
          }
        });
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleVerify() async {
    final otp = otpControllers.map((c) => c.text.trim()).join();
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(email: widget.email, otpCode: otp);

    if (!mounted) return;

    if (success) {
      final user = auth.currentUser;
      if (user != null && user.isStudent && user.isPending) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const StudentWaitingApprovalScreen(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      _showError(
          auth.errorMessage ?? 'Something went wrong. Please try again.');
    }
  }

  Future<void> _handleResend() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.resendOtp(email: widget.email);

    if (!mounted) return;
    if (success) {
      _showSuccess('A new OTP has been sent to your email.');
      _startResendCooldown();
      for (var ctrl in otpControllers) {
        ctrl.clear();
      }
      setState(() => isButtonEnabled = false);
    } else {
      _showError(
          auth.errorMessage ?? 'Failed to resend OTP. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back,
                        size: 28, color: Color.fromARGB(255, 77, 77, 77)),
                  ),
                  const SizedBox(height: 36),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 232, 241, 248),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.shield_outlined,
                        size: 32, color: ColorPallet.primaryBlue),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'OTP Verification',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Enter the 4-digit code we sent to\n${widget.email}',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  // OTP Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      return _otpTextField(
                        otpControllers[index],
                        focusNodes[index],
                        index == 0,
                        index,
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (isButtonEnabled && !auth.isLoading)
                          ? _handleVerify
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled
                            ? ColorPallet.primaryBlue
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Verify',
                              style: TextStyle(
                                  fontSize: 18, color: ColorPallet.white)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: _canResend
                        ? TextButton.icon(
                            onPressed: _handleResend,
                            icon: const Icon(Icons.refresh,
                                size: 18, color: ColorPallet.primaryBlue),
                            label: const Text(
                              'Resend Email',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: ColorPallet.primaryBlue,
                              ),
                            ),
                          )
                        : Text(
                            'Resend email in ${_resendCooldown}s',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _otpTextField(
    TextEditingController controller,
    FocusNode focusNode,
    bool autoFocus,
    int index,
  ) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: focusNode.hasFocus
                ? const Color.fromARGB(255, 184, 173, 237).withOpacity(0.9)
                : Colors.white,
            spreadRadius: 2,
            blurRadius: focusNode.hasFocus ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color.fromARGB(255, 212, 211, 211),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                const BorderSide(color: ColorPallet.primaryBlue, width: 2.5),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        },
      ),
    );
  }
}
