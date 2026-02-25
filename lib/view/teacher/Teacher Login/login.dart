import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/auth_provider.dart';
import 'package:facialtrackapp/utils/widgets/textfield_login.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/student/Forgot%20Password/forgot-password-screen.dart';
import 'package:facialtrackapp/view/teacher/Teacher_NavBar/teacher_root_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool _obscureText = true;
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
    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      final user = auth.currentUser!;
      if (user.isTeacher) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TeacherRootScreen()),
          (route) => false,
        );
      } else {
        await auth.logout();
        _showError('This account is not registered as a Teacher.');
      }
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
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // ─── Header ───
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RoleSelectionScreen()),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 20, top: 15),
                            child: Row(children: [
                              Icon(Icons.arrow_back, color: ColorPallet.white),
                            ]),
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
                          'Teacher Portal',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 11),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ─── Email Field ───
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

                  // ─── Password Field ───
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
                    padding: const EdgeInsets.only(right: 15, top: 4),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordScreen(
                              loginScreen: const TeacherLoginScreen(),
                            ),
                          ),
                        ),
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

                  const SizedBox(height: 16),

                  // ─── Login Button ───
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
                        onPressed: (isButtonEnabled && !auth.isLoading)
                            ? _handleLogin
                            : null,
                        child: auth.isLoading
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

                  const SizedBox(height: 24),

                  // ─── Info Banner ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ColorPallet.primaryBlue.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColorPallet.primaryBlue.withOpacity(0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: ColorPallet.primaryBlue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Teacher accounts are created by the Admin. Contact your administrator if you do not have an account.',
                              style: TextStyle(
                                  fontSize: 12, color: ColorPallet.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
