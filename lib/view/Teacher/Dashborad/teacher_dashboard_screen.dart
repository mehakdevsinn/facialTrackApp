
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/Teacher/Start%20Screen/live_session_screen.dart';
import 'package:facialtrackapp/view/teacher/Dashborad/subject_screen.dart';
import 'package:facialtrackapp/view/teacher/Profile/teacher_profile_screen.dart';
import 'package:facialtrackapp/view/teacher/Report/report_screen.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/start_screen.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/view_log_screen.dart';
import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Yeh back button ko fully disable kar deta hai
      onPopInvokedWithResult: (didPop, result) {
        // Agar back button dabaya jaye toh yahan kuch na likhen
        // Isse screen pop nahi hogi aur na hi koi dialog aayega
        if (didPop) return;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffF6F8FB),
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: ColorPallet.primaryBlue,
            foregroundColor: Colors.white,
            title: const Text(
              'Facial Track',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            actions: [
              PopupMenuButton<int>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onSelected: (value) {
                  if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Yahan showBackButton true bhejain
                        builder: (context) =>
                            TeacherProfileScreen(showBackButton: true),
                      ),
                    );
                  } else if (value == 2) {
                    _showLogoutDialog(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/logo.png'),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Dr. Saima Kamran',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('View Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics:
                  const ClampingScrollPhysics(), // padding: const EdgeInsets.all(16),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    // children:[
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // padding: EdgeInsets.zero,
                    children: [
                      const Text(
                        'Welcome, Dr Saima Kamran',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Monday, October 28, 2024',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),

                      // ---------------- GRID CARDS ----------------
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // TeacherDashboardScreen ke andar
                          _AnimatedDashboardCard(
                            color: Colors.green,
                            icon: Icons.play_arrow,
                            title: 'Start Attendance',
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Yahan showBackButton true bhejain
                                  builder: (context) =>
                                      StartSessionScreen(showBackButton: true),
                                ),
                              );
                            },
                          ),
                          _AnimatedDashboardCard(
                            color: Colors.orange,
                            icon: Icons.stop,
                            title: 'End Attendance',
                            // Dashboard Screen
                            ontap: () {
                              if (SessionManager.isLive) {
                                // Agar session chal raha hai, seedha Live screen par le jao
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LiveSessionScreen(
                                      autoStart:
                                          false, // Dobara start nahi karna, sirf view karna hai
                                      isResume:
                                          true, // Naya parameter taake purana time uthaye
                                    ),
                                  ),
                                );
                              } else {
                                // Agar koi session nahi chal raha toh error ya message dikhaein
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("No active session to end!"),
                                  ),
                                );
                              }
                            },
                          ),
                          _AnimatedDashboardCard(
                            color: Colors.blue,
                            icon: Icons.calendar_today,
                            title: "Today's Logs",
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AttendanceLogsScreen(),
                                ),
                              );
                            },
                          ),
                          _AnimatedDashboardCard(
                            color: Colors.purple,
                            icon: Icons.bar_chart,
                            title: 'Monthly Report',
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Yahan showBackButton true bhejain
                                  builder: (context) =>
                                      AttendanceReport(showBackButton: true),
                                ),
                              );
                            },
                          ),
                          _AnimatedDashboardCard(
                            color: Colors.teal,
                            icon: Icons.menu_book,
                            title: 'Subjects',
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SubjectListScreen(),
                                ),
                              );
                            },
                          ),
                          _AnimatedDashboardCard(
                            color: Colors.indigo,
                            icon: Icons.person,
                            title: 'Profile',
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Yahan showBackButton true bhejain
                                  builder: (context) => TeacherProfileScreen(
                                    showBackButton: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // const SizedBox(height: 16),
                      // ---------------- LOGOUT CARD ----------------
                      // AnimatedLogoutCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- ANIMATED DASHBOARD CARD ----------------
class _AnimatedDashboardCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String title;
  final ontap;

  const _AnimatedDashboardCard({
    required this.color,
    required this.icon,
    required this.title,
    this.ontap,
  });

  @override
  State<_AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}

class _AnimatedDashboardCardState extends State<_AnimatedDashboardCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color shadowColor = Colors.black.withOpacity(0.1); // uniform shadow

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: InkWell(
        onTap: widget.ontap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.95))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _isPressed ? widget.color.withOpacity(0.2) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 3,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [widget.color.withOpacity(0.5), widget.color],
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

// ---------------- ANIMATED LOGOUT CARD ----------------
class AnimatedLogoutCard extends StatefulWidget {
  const AnimatedLogoutCard({super.key});

  @override
  State<AnimatedLogoutCard> createState() => _AnimatedLogoutCardState();
}

class _AnimatedLogoutCardState extends State<AnimatedLogoutCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color shadowColor = Colors.black.withOpacity(0.1); // same uniform shadow

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        // Logout logic
      },
      child: InkWell(
        onTap: () {
          _showLogoutDialog(context); // Alert dialog open hoga
        },
        child: AnimatedContainer(
          height: 120,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.97))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _isPressed ? Colors.red.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xffFDECEA),
                child: Icon(Icons.logout, color: Colors.red),
              ),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 300), // Animation ki speed
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox.shrink(); // pageBuilder lazmi hota hai par hum transitionsBuilder use karenge
    },
    transitionBuilder: (context, anim1, anim2, child) {
      // Scale and Opacity Animation
      return Transform.scale(
        scale: anim1.value, // 0 se 1 tak scale hoga
        child: Opacity(
          opacity: anim1.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 24,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xffFDECEA),
                  child: Icon(Icons.logout, color: Colors.red, size: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // Sab kuch clear karke RoleSelectionScreen par jump
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoleSelectionScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
