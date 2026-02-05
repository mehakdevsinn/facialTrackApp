import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import '../Student%20Login/login.dart';
import 'package:facialtrackapp/widgets/textfield_login.dart';
import '../Student%20Waiting%20Approval/student_waiting_approval_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  State<StudentSignupScreen> createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

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

  bool _obscureText = true;
  String email = "";
  String password = "";
  String? selectedSemester;

  bool isLoading = false;
  bool get isButtonEnabled =>
      email.isNotEmpty && password.isNotEmpty && selectedSemester != null;

  final List<String> semesters = [
    "2nd Semester",
    "4th Semester",
    "6th Semester",
    "8th Semester",
  ];

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
                                builder: (context) =>
                                    const RoleSelectionScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 15),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.arrow_back,
                                  color: ColorPallet.white,
                                ),
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
                          "Student Registration",
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
                  // Semester Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorPallet.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedSemester != null
                              ? ColorPallet.primaryBlue
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 1,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Row(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Select Semester",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            value: selectedSemester,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: selectedSemester != null
                                  ? ColorPallet.primaryBlue
                                  : Colors.grey,
                            ),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            dropdownColor: Colors.white,
                            items: semesters.map((String semester) {
                              return DropdownMenuItem<String>(
                                value: semester,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Text(semester),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSemester = newValue;
                              });
                            },
                          ),
                        ),
                      ),
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
                                            const StudentWaitingApprovalScreen(),
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
                              builder: (context) => const StudentLoginScreen(),
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
      ),
    );
  }
}
