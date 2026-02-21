import 'dart:async';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/services/api_service.dart';
import 'package:facialtrackapp/view/student/Reset%20Password/reset-password-screen.dart';
import 'package:flutter/material.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;
  final Widget loginScreen;

  const ForgotPasswordOtpScreen({
    Key? key,
    required this.email,
    required this.loginScreen,
  }) : super(key: key);

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  bool isButtonEnabled = false;
  bool isLoading = false;

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
    focusNodes = List.generate(4, (_) => FocusNode());
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
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var n in focusNodes) {
      n.dispose();
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
    final otpCode = otpControllers.map((c) => c.text.trim()).join();
    setState(() => isLoading = true);

    try {
      // Validates OTP — does NOT consume it yet (backend design)
      await ApiService.instance.verifyResetOtp(
        email: widget.email,
        otpCode: otpCode,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
              otpCode: otpCode,
              loginScreen: widget.loginScreen,
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    try {
      await ApiService.instance.resendOtp(email: widget.email);
      _showSuccess('A new code has been sent to ${widget.email}.');
      _startResendCooldown();
      for (var ctrl in otpControllers) {
        ctrl.clear();
      }
      setState(() => isButtonEnabled = false);
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Failed to resend code. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Color.fromARGB(255, 77, 77, 77),
                ),
              ),
              const SizedBox(height: 36),

              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 232, 241, 248),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 32,
                  color: ColorPallet.primaryBlue,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Enter Reset Code',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'We sent a 4-digit code to\n${widget.email}',
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
                  onPressed:
                      (isButtonEnabled && !isLoading) ? _handleVerify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? ColorPallet.primaryBlue
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Verify Code',
                          style:
                              TextStyle(fontSize: 18, color: ColorPallet.white),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Resend button with 60-second cooldown
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

// Keep OtpScreen as an alias so existing imports don't break
// ignore: non_constant_identifier_names
Widget OtpScreen() => const SizedBox.shrink();
