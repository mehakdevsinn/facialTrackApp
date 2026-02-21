import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/models/user_model.dart';
import 'package:facialtrackapp/services/api_service.dart';
import 'package:facialtrackapp/utils/widgets/textfield_login.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/student/Face%20Enrolment/student-face-enrolment.dart';
import 'package:facialtrackapp/view/student/Forgot%20Password/forgot-password-screen.dart';
import 'package:facialtrackapp/view/student/Student%20NavBar/student-root_screen.dart';
import 'package:facialtrackapp/view/student/Student%20Signup/student_signup.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool _obscureText = true;
  bool isLoading = false;
  String email = '';
  String password = '';

  bool get isButtonEnabled => email.isNotEmpty && password.isNotEmpty;

  @override
  void initState() {
    super.initState();
    emailFocus.addListener(() => setState(() {}));
    passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
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

  Future<void> _handleLogin() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.instance.login(
        email: email,
        password: password,
      );

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      if (!mounted) return;

      // Route based on role
      if (user.isStudent) {
        // For students: check face_verified to decide where to go
        // If face not enrolled yet → go to face enrolment
        // If face enrolled → go to dashboard
        if (!user.faceVerified) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => StudentFaceEnrolements()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const StudentRootScreen()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
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
                            builder: (context) => RoleSelectionScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 20, top: 15),
                        child: Row(
                          children: [
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
                      'Facial Track',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Student Attendance Portal',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 11),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: buildTextField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  activeColor: ColorPallet.primaryBlue,
                  inactiveColor: Colors.grey,
                  focusNode: emailFocus,
                  onChange: (value) => setState(() => email = value),
                ),
              ),

              const SizedBox(height: 20),

              // Password Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: buildTextField(
                  activeColor: ColorPallet.primaryBlue,
                  inactiveColor: Colors.grey,
                  focusNode: passwordFocus,
                  onChange: (value) => setState(() => password = value),
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: ColorPallet.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),

              // Forgot Password
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(
                            loginScreen: const StudentLoginScreen(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: ColorPallet.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? ColorPallet.primaryBlue
                          : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed:
                        (isButtonEnabled && !isLoading) ? _handleLogin : null,
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
                            'Login',
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
                    "Don't have an account? ",
                    style: TextStyle(color: ColorPallet.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentSignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
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
    );
  }
}
