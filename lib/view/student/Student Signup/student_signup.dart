import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/utils/widgets/textfield_login.dart';

import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/Student/Otp%20Screen/otp-verification.dart';
import '../Student%20Login/login.dart';
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
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final FocusNode rollNoFocus = FocusNode();
  final FocusNode departmentFocus = FocusNode();
  final FocusNode sectionFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    fullNameFocus.addListener(() => setState(() {}));
    emailFocus.addListener(() => setState(() {}));
    passwordFocus.addListener(() => setState(() {}));
    confirmPasswordFocus.addListener(() => setState(() {}));
    rollNoFocus.addListener(() => setState(() {}));
    departmentFocus.addListener(() => setState(() {}));
    sectionFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    fullNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    rollNoFocus.dispose();
    departmentFocus.dispose();
    sectionFocus.dispose();
    super.dispose();
  }

  bool _obscureText = true;
  bool _obscureConfirmText = true;

  String fullName = "";
  String email = "";
  String password = "";
  String confirmPassword = "";
  String rollNo = "";
  String department = "";
  String section = ""; // Optional
  String? selectedSemester;

  bool isLoading = false;

  bool get isButtonEnabled =>
      fullName.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      rollNo.isNotEmpty &&
      department.isNotEmpty &&
      selectedSemester != null;

  final List<String> semesters = [
    "1st Semester",
    "2nd Semester",
    "3rd Semester",
    "4th Semester",
    "5th Semester",
    "6th Semester",
    "7th Semester",
    "8th Semester",
  ];

  void _handleSignup() async {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Call Mock AuthService

    if (mounted) {
      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OtpVerificationScreen()),
      );
    }
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
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 289, // Reduced height to save space
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
                        // Reduced lottie for space
                        SizedBox(
                          height: 140,
                          width: 140,
                          child: Lottie.asset(
                            'assets/animations/face-detect.json',
                            repeat: true,
                            animate: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Facial Track",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 11),
                        const Text(
                          "Student Registration",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      activeColor: ColorPallet.primaryBlue,
                      inactiveColor: Colors.grey,
                      focusNode: fullNameFocus,
                      onChange: (value) => setState(() => fullName = value),
                      label: "Full Name",
                      hint: "Enter your full name",
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      activeColor: ColorPallet.primaryBlue,
                      inactiveColor: Colors.grey,
                      focusNode: emailFocus,
                      onChange: (value) => setState(() => email = value),
                      label: "Email Address",
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Roll No
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      activeColor: ColorPallet.primaryBlue,
                      inactiveColor: Colors.grey,
                      focusNode: rollNoFocus,
                      onChange: (value) => setState(() => rollNo = value),
                      label: "Roll No ",
                      hint: "e.g. 2021-CS-123",
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Department
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      activeColor: ColorPallet.primaryBlue,
                      inactiveColor: Colors.grey,
                      focusNode: departmentFocus,
                      onChange: (value) => setState(() => department = value),
                      label: "Department",
                      hint: "e.g. Computer Science",
                      icon: Icons.apartment_outlined,
                    ),
                  ),
                  const SizedBox(height: 15),

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
                            items: semesters.map((String semester) {
                              return DropdownMenuItem<String>(
                                value: semester,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Text(semester),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => selectedSemester = val),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Section (Optional)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      activeColor: ColorPallet.primaryBlue,
                      inactiveColor: Colors.grey,
                      focusNode: sectionFocus,
                      onChange: (value) => setState(() => section = value),
                      label: "Section (Optional)",
                      hint: "e.g. A",
                      icon: Icons.class_outlined,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      activeColor: ColorPallet.primaryBlue,
                      inactiveColor: Colors.grey,
                      focusNode: passwordFocus,
                      onChange: (value) => setState(() => password = value),
                      label: "Password",
                      hint: "Create password",
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
                  const SizedBox(height: 15),

                  // Confirm Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      activeColor: ColorPallet.primaryBlue,
                      inactiveColor: Colors.grey,
                      focusNode: confirmPasswordFocus,
                      onChange: (value) =>
                          setState(() => confirmPassword = value),
                      label: "Confirm Password",
                      hint: "Repeat password",
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: ColorPallet.grey,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmText = !_obscureConfirmText,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Sign Up Button
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
                            ? _handleSignup
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
