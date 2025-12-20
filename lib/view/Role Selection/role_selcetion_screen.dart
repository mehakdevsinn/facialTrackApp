import 'package:facialtrackapp/view/Teacher/Dashborad/teacher_dashboard_screen.dart';
import 'package:facialtrackapp/view/Teacher/Root%20Screen/root_screen.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // Track which card is pressed
  bool _isTeacherPressed = false;
  bool _isStudentPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Facial Track',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose your role to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 50),

              // Teacher Card
              GestureDetector(
                onTapDown: (_) {
                  setState(() => _isTeacherPressed = true);
                },
                onTapUp: (_) {
                  setState(() => _isTeacherPressed = false);
                  // Navigate to Teacher Screen
                },
                onTapCancel: () {
                  setState(() => _isTeacherPressed = false);
                },
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RootScreen()));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    transform: _isTeacherPressed
                        ? Matrix4.translationValues(0, 5, 0)
                        : Matrix4.identity(),
                    width: double.infinity,
                    height: 140,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person, color: Colors.blue, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'Teacher',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Manage attendance and reports',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Student Card
              GestureDetector(
                onTapDown: (_) {
                  setState(() => _isStudentPressed = true);
                },
                onTapUp: (_) {
                  setState(() => _isStudentPressed = false);
                  // Navigate to Student Screen
                },
                onTapCancel: () {
                  setState(() => _isStudentPressed = false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: _isStudentPressed
                      ? Matrix4.translationValues(0, 5, 0)
                      : Matrix4.identity(),
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.school, color: Colors.green, size: 40),
                      SizedBox(height: 10),
                      Text(
                        'Student',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'View your attendance and subjects',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
              const Text(
                'You can change role later from settings',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black38,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
