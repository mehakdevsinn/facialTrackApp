import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import '../Teacher%20Login/login.dart';
import 'package:facialtrackapp/widgets/textfield_login.dart';
import '../Waiting%20Approval/waiting_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class TeacherSignupScreen extends StatefulWidget {
  const TeacherSignupScreen({super.key});

  @override
  State<TeacherSignupScreen> createState() => _TeacherSignupScreenState();
}

class _TeacherSignupScreenState extends State<TeacherSignupScreen> {
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode qualificationFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    emailFocus.addListener(() => setState(() {}));
    passwordFocus.addListener(() => setState(() {}));
    qualificationFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    qualificationFocus.dispose();
    super.dispose();
  }

  bool _obscureText = true;
  String email = "";
  String password = "";
  String qualification = "";

  bool isLoading = false;
  bool get isButtonEnabled =>
      email.isNotEmpty && password.isNotEmpty && qualification.isNotEmpty;

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 285,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPallet.primaryBlue,
                        Color.fromARGB(255, 123, 149, 233),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoleSelectionScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 15),
                          child: Row(
                            children: const [
                              Icon(Icons.arrow_back, color: ColorPallet.white),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Lottie.asset(
                          'assets/animations/face-detect.json',
                          repeat: true,
                          animate: true,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Facial Track",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Teacher Registration",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 11),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: buildTextField(
                    activeColor: ColorPallet.primaryBlue,
                    inactiveColor: Colors.grey,
                    focusNode: emailFocus,
                    onChange: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    label: "Email Address",
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: buildTextField(
                    activeColor: ColorPallet.primaryBlue,
                    inactiveColor: Colors.grey,
                    focusNode: passwordFocus,
                    onChange: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    label: "Password",
                    hint: "Create a password",
                    icon: Icons.lock_outline,
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: ColorPallet.grey,
                      ),
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: buildTextField(
                    activeColor: ColorPallet.primaryBlue,
                    inactiveColor: Colors.grey,
                    focusNode: qualificationFocus,
                    onChange: (value) {
                      setState(() {
                        qualification = value;
                      });
                    },
                    label: "Qualification",
                    hint: "Enter your qualification",
                    icon: Icons.school_outlined,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled
                            ? ColorPallet.deepBlue
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: isButtonEnabled && !isLoading
                          ? () {
                              setState(() {
                                isLoading = true;
                              });
                              // Simulate signup delay
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WaitingApprovalScreen(),
                                    ),
                                  );
                                }
                              });
                            }
                          : null,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: ColorPallet.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeacherLoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: ColorPallet.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
