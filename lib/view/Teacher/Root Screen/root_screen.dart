import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:facialtrackapp/constant/app_color.dart';
import 'package:facialtrackapp/view/Teacher/Dashborad/teacher_dashboard_screen.dart';
import 'package:facialtrackapp/view/Teacher/Profile/teacher_profile_screen.dart';
import 'package:facialtrackapp/view/Teacher/Report/report_screen.dart';
import 'package:facialtrackapp/view/Teacher/Start Screen/start_screen.dart';
import 'package:flutter/material.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int selectedPos = 0;
  late CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _navigationController =
        CircularBottomNavigationController(selectedPos);
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(selectedPos),
      bottomNavigationBar: Material(
        elevation: 10,
        child: _bottomNav(),
      ),
    );
  }

  /// ---------------- SCREEN SWITCH ----------------
  Widget _getBody(int pos) {
    switch (pos) {
      case 0:
        return const TeacherDashboardScreen();
      case 1:
        return const StartScreen();
      case 2:
        return const ReportScreen();
      case 3:
        return const TeacherProfileScreen();
      default:
        return const TeacherDashboardScreen();
    }
  }

  /// ---------------- BOTTOM NAV ----------------
  Widget _bottomNav() {
    return CircularBottomNavigation(
      tabItems,
      controller: _navigationController,
      selectedPos: selectedPos,
      barHeight: 65,
      iconsSize: 24,
      animationDuration: const Duration(milliseconds: 300),

      /// White background
      barBackgroundColor: Colors.white,

      /// Unselected ICON color
      normalIconColor: Colors.grey,

      selectedCallback: (int? pos) {
        setState(() {
          selectedPos = pos ?? 0;
        });
      },
    );
  }

  /// ---------------- TAB ITEMS (ICON + LABEL) ----------------
  final List<TabItem> tabItems = [
    TabItem(
      Icons.dashboard_rounded,
      "Dashboard",
      const Color.fromARGB(255, 73, 33, 252), // selected icon + text color
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.grey, // ✅ unselected text color
      ),
    ),
    TabItem(
      Icons.play_circle_fill,
      "Start Section",
      const Color.fromARGB(255, 73, 33, 252), // selected icon + text color
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    ),
    TabItem(
      Icons.bar_chart_rounded,
      "Reports",
      const Color.fromARGB(255, 73, 33, 252), // selected icon + text color
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    ),
    TabItem(
      Icons.person_rounded,
      "Profile",
      const Color.fromARGB(255, 73, 33, 252), // selected icon + text color
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    ),
  ];
}
