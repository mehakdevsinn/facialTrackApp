import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Teacher/Otp%20Screen/otp-screen.dart';
import 'package:facialtrackapp/widgets/textfield_login.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  final FocusNode passwordFocus = FocusNode();
  String password = "";

  bool get isButtonEnabled => password.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
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
              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 232, 241, 248),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: ColorPallet.primaryBlue,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Don’t worry! It happens. Please enter the email\naddress linked to your account.",
                style: TextStyle(fontSize: 16, color: ColorPallet.grey),
              ),

              const SizedBox(height: 32),

              buildTextField(
                label: "Email",
                hint: "Enter your Email ",
                icon: Icons.email_outlined,
                activeColor: ColorPallet.primaryBlue,
                inactiveColor: Colors.grey,
                focusNode: passwordFocus,
                onChange: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpVerificationScreen(),
                            ),
                          );
                        }
                      : SizedBox.shrink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? ColorPallet.primaryBlue
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Send Code",
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
  }
}
