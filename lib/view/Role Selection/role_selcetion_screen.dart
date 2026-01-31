// import 'package:facialtrackapp/view/student/Student%20NavBar/student-root_screen.dart';
// import 'package:facialtrackapp/view/student/Student%20Login/login.dart';
// import 'package:facialtrackapp/view/teacher/Teacher%20Login/login.dart';
// import 'package:flutter/material.dart';

// class RoleSelectionScreen extends StatefulWidget {
//   const RoleSelectionScreen({super.key});

//   @override
//   State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
// }

// class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
//   // Track which card is pressed
//   bool _isTeacherPressed = false;
//   bool _isStudentPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//     canPop: false, // Prevents the system back button from working
//     onPopInvokedWithResult: (didPop, result) {
//       if (didPop) return;
//       // Optional: Show a "Exit App?" dialog here
//     },
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 40),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 60),
//                   // Logo
//                   Center(
//                     child: Container(
//                       height: 80,
//                       width: 80,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         image: DecorationImage(
//                           image: AssetImage('assets/logo.png'),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Facial Track',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Choose your role to continue',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black45,
//                     ),
//                   ),
//                   const SizedBox(height: 50),

//                   // Teacher Card
//                   GestureDetector(
//                     onTapDown: (_) {
//                       setState(() => _isTeacherPressed = true);
//                     },
//                     onTapUp: (_) {
//                       setState(() => _isTeacherPressed = false);
//                       // Navigate to Teacher Screen
//                     },
//                     onTapCancel: () {
//                       setState(() => _isTeacherPressed = false);
//                     },
//                     child: InkWell(
//                      onTap: () {
//           Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const TeacherLoginScreen()),
//         (route) => false,
//           );
//         },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 100),
//                         transform: _isTeacherPressed
//                             ? Matrix4.translationValues(0, 5, 0)
//                             : Matrix4.identity(),
//                         width: double.infinity,
//                         height: 140,
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.blue, width: 2),
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.blue.withOpacity(0.2),
//                               blurRadius: 12,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(Icons.person, color: Colors.blue, size: 40),
//                             SizedBox(height: 10),
//                             Text(
//                               'Teacher',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             SizedBox(height: 5),
//                             Text(
//                               'Manage attendance and reports',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.black54,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Student Card
//                   GestureDetector(
//                     onTapDown: (_) {
//                       setState(() => _isStudentPressed = true);
//                     },
//                     onTapUp: (_) {
//                       setState(() => _isStudentPressed = false);
//                       // Navigate to Student Screen
//                     },
//                     onTapCancel: () {
//                       setState(() => _isStudentPressed = false);
//                     },
//                     child: InkWell(
//                       onTap: () {
//           Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const StudentLoginScreen()),
//         (route) => false,
//           );
//         },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 100),
//                         transform: _isStudentPressed
//                             ? Matrix4.translationValues(0, 5, 0)
//                             : Matrix4.identity(),
//                         width: double.infinity,
//                         height: 140,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.green, width: 2),
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.green.withOpacity(0.2),
//                               blurRadius: 12,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(Icons.school, color: Colors.green, size: 40),
//                             SizedBox(height: 10),
//                             Text(
//                               'Student',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green,
//                               ),
//                             ),
//                             SizedBox(height: 5),
//                             Text(
//                               'View your attendance and subjects',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.black54,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const Spacer(),
//                   const Text(
//                     'You can change role later from settings',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.black38,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:facialtrackapp/view/Admin/Admin%20Login/admin-login.dart';
import 'package:facialtrackapp/view/Student/Student%20NavBar/student-root_screen.dart';
import 'package:facialtrackapp/view/Student/Student%20Login/login.dart';
import 'package:facialtrackapp/view/teacher/Teacher%20Login/login.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}
// ... existing imports
// Import admin login screen here (e.g., import 'package:facialtrackapp/view/admin/Admin%20Login/login.dart';)

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isTeacherPressed = false;
  bool _isStudentPressed = false;
  bool _isAdminPressed = false; // Add this line

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo Section (Same as before)
                    Center(
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Facial Track',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Choose your role to continue',
                      style: TextStyle(fontSize: 14, color: Colors.black45),
                    ),
                    const SizedBox(height: 40),

                    // 1. Teacher Card
                    _buildRoleCard(
                      title: 'Teacher',
                      subtitle: 'Manage attendance and reports',
                      icon: Icons.person,
                      color: Colors.blue,
                      isPressed: _isTeacherPressed,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeacherLoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      onPressState: (val) =>
                          setState(() => _isTeacherPressed = val),
                    ),

                    // 2. Student Card
                    _buildRoleCard(
                      title: 'Student',
                      subtitle: 'View your attendance and subjects',
                      icon: Icons.school,
                      color: Colors.green,
                      isPressed: _isStudentPressed,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentLoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      onPressState: (val) =>
                          setState(() => _isStudentPressed = val),
                    ),

                    // 3. ADMIN CARD (New Section)
                    _buildRoleCard(
                      title: 'Admin',
                      subtitle: 'System management and control',
                      icon: Icons.admin_panel_settings,
                      color: Colors.deepPurple,
                      isPressed: _isAdminPressed,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      onPressState: (val) =>
                          setState(() => _isAdminPressed = val),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'You can change role later from settings',
                      style: TextStyle(fontSize: 12, color: Colors.black38),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method taake code clean rahe
  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isPressed,
    required VoidCallback onTap,
    required Function(bool) onPressState,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressState(true),
      onTapUp: (_) => onPressState(false),
      onTapCancel: () => onPressState(false),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: isPressed
              ? Matrix4.translationValues(0, 5, 0)
              : Matrix4.identity(),
          width: double.infinity,
          height:
              120, // Height thori kam ki taake 3 cards screen par poore aa jayein
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 35),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
