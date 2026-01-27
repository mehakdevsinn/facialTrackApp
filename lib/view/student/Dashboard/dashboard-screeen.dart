import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/student/Profile/student-profile-screen.dart';
import 'package:facialtrackapp/widgets/dashboard-widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const DashboardScreen({super.key, required this.onTabChange});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color.fromARGB(255, 244, 243, 243),
        backgroundColor: Colors.grey[100],

        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -220,
                      left: -120,
                      right: -120,
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: ColorPallet.primaryBlue,
                          borderRadius: BorderRadius.circular(400),
                        ),
                      ),
                    ),

                    const Positioned(
                      top: 20,
                      left: 20,
                      child: Text(
                        "Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 20,
                      right: 5,
                      child: Row(
                        children: [
                          // Icon(
                          //   Icons.notifications_none,
                          //   color: ColorPallet.white,
                          // ),
                          // SizedBox(width: 16),

                          // CircleAvatar(radius: 17),
                          PopupMenuButton<int>(
                            offset: const Offset(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            onSelected: (value) {
                              if (value == 1) {
                                widget.onTabChange(
                                  3,
                                ); // Navigate to Profile Tab
                              } else if (value == 2) {
                                _showLogoutDialog(
                                  context,
                                ); // Triggers your custom Alert Box
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
                                    backgroundImage: AssetImage(
                                      'assets/logo.png',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Mr. Anderson',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
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
                                  leading: Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                  ),
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
                    ),

                    Positioned(
                      top: 90,
                      left: 20,
                      right: 20,
                      child: todayAttendanceCard(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Transform.translate(
                offset: const Offset(0, -60),
                child: overallAttendanceCard(),
              ),

              const SizedBox(height: 16),

              Transform.translate(
                offset: const Offset(0, -60),
                child: subjectsSection(context),
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
