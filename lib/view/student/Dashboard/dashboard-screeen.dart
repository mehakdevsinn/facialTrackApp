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
        backgroundColor: const Color.fromARGB(255, 244, 243, 243),

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
                      right: 20,
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
                                // View Profile action
                              } else if (value == 2) {
                                // Logout action
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
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: ListTile(
                                  leading: Icon(Icons.person_outline),
                                  title: Text('View Profile'),
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         StudentProfileScreen(),
                                    //   ),
                                    // );
                                    widget.onTabChange(3);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RoleSelectionScreen(),
                                      ),
                                    );
                                  },
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
