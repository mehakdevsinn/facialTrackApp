import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Teacher_NavBar/teacher_root_screen.dart';
import 'package:facialtrackapp/widgets/textfield_login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
    canPop: false, // Prevents the system back button from working
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      // Optional: Show a "Exit App?" dialog here
    },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
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
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: Lottie.asset(
                            'assets/animations/face-detect.json',
                            repeat: true,
                            animate: true,
                          ),
                        ),
        
                        SizedBox(height: 15),
                        Text(
                          "Facial Track",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Teacher Portal",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
        
                  const SizedBox(height: 40),
        
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      label: "Teacher ID",
                      hint: "Enter your Teacher ID",
                      icon: Icons.person_outline,
                      color: ColorPallet.accentOrange,
                    ),
                  ),
        
                  const SizedBox(height: 20),
        
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: buildTextField(
                      label: "Password",
                      hint: "Enter your password",
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
                      color: ColorPallet.accentOrange,
                    ),
                  ),
        
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: ColorPallet.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 39),
        
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPallet.deepBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherRootScreen()));
                        },
                        child: const Text(
                          "Login",
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
                      Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: ColorPallet.softGreen,
                        ),
        
                        child: Icon(Icons.done, color: ColorPallet.white, size: 10),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Secure Login",
                        style: TextStyle(color: ColorPallet.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
