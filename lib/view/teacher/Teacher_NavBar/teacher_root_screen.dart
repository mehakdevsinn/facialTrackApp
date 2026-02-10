import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Report/montly_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:facialtrackapp/view/teacher/Dashborad/teacher_dashboard_screen.dart';
import 'package:facialtrackapp/view/teacher/Profile/teacher_profile_screen.dart';
import 'package:facialtrackapp/view/teacher/Start Screen/start_screen.dart';

class TeacherRootScreen extends StatefulWidget {
  const TeacherRootScreen({super.key});

  @override
  State<TeacherRootScreen> createState() => _TeacherRootScreenState();
}

class _TeacherRootScreenState extends State<TeacherRootScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Widget> _screens = [
    const TeacherDashboardScreen(),
    const StartSessionScreen(),
    MonthlyAttendanceReport(),
    const TeacherProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.play_circle_fill,
    Icons.bar_chart_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    "Dashboard",
    "Start Session",
    "Reports",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            bool isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 35, 4, 170).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      _icons[index],
                      color: isSelected ? ColorPallet.primaryBlue : Colors.grey,
                      size: isSelected ? 28 : 24,
                    ),
                    const SizedBox(width: 6),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isSelected ? _labels[index] : "",
                        style: TextStyle(
                          color: ColorPallet.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
