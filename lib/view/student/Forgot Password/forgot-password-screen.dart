import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/auth_provider.dart';
import 'package:facialtrackapp/utils/widgets/textfield_login.dart';
import 'package:facialtrackapp/view/student/Otp%20Screen/otp-screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final Widget loginScreen;

  const ForgotPasswordScreen({Key? key, required this.loginScreen})
      : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FocusNode emailFocus = FocusNode();
  String email = '';

  bool get isButtonEnabled => email.isNotEmpty;

  @override
  void initState() {
    super.initState();
    emailFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailFocus.dispose();
    super.dispose();
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

  Future<void> _handleSendOtp() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(email: email);

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordOtpScreen(
            email: email,
            loginScreen: widget.loginScreen,
          ),
        ),
      );
    } else {
      _showError(
          auth.errorMessage ?? 'Something went wrong. Please try again.');
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
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 232, 241, 248),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.lock_outline,
                        size: 32, color: ColorPallet.primaryBlue),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Don't worry! Enter the email address linked to\nyour account and we'll send you a reset code.",
                    style: TextStyle(fontSize: 15, color: ColorPallet.grey),
                  ),
                  const SizedBox(height: 32),
                  buildTextField(
                    label: 'Email Address',
                    hint: 'Enter your registered email',
                    icon: Icons.email_outlined,
                    activeColor: ColorPallet.primaryBlue,
                    inactiveColor: Colors.grey,
                    focusNode: emailFocus,
                    onChange: (value) => setState(() => email = value.trim()),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (isButtonEnabled && !auth.isLoading)
                          ? _handleSendOtp
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
                          : const Text(
                              'Send Reset Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorPallet.white,
                              ),
                            ),
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
}
