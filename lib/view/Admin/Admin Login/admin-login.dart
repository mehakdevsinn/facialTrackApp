import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/models/user_model.dart';
import 'package:facialtrackapp/services/api_service.dart';
import 'package:facialtrackapp/utils/widgets/textfield_login.dart';
import 'package:facialtrackapp/view/Admin/admin_root_screen.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
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

      if (user.isAdmin) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminRootScreen()),
          (route) => false,
        );
      } else {
        _showError('This account is not registered as an Admin.');
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
                          builder: (context) => const RoleSelectionScreen(),
                        ),
                      ),
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
                      'Admin Portal',
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
                  label: 'Admin Email',
                  hint: 'Enter your Admin Email',
                  icon: Icons.person_outline,
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

              const SizedBox(height: 39),

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

              // ─── Secure Login badge ───
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 18,
                    width: 18,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: ColorPallet.softGreen,
                    ),
                    child: const Icon(
                      Icons.done,
                      color: ColorPallet.white,
                      size: 10,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Secure Login',
                    style: TextStyle(color: ColorPallet.grey),
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
