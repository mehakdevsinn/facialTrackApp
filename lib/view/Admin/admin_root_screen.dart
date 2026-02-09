import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Admin/Assignment/assignment_screen.dart';
import 'package:facialtrackapp/view/Admin/Dashboard/admin_dashboard_screen.dart';
import 'package:facialtrackapp/view/Admin/Profile/admin_profile_screen.dart';
import 'package:facialtrackapp/view/Admin/User%20Approval/user_approval_screen.dart';
import 'package:flutter/material.dart';

class AdminRootScreen extends StatefulWidget {
  const AdminRootScreen({super.key});

  @override
  State<AdminRootScreen> createState() => _AdminRootScreenState();
}

class _AdminRootScreenState extends State<AdminRootScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const UserApprovalScreen(showBackButton: false),
    const AssignmentScreen(),
    const AdminProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.how_to_reg_rounded,
    Icons.link,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    "Dashboard",
    "Student Approval",
    "Assignment",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
    return SafeArea(
      child: Scaffold(
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
                        color: isSelected
                            ? ColorPallet.primaryBlue
                            : Colors.grey,
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
      ),
    );
  }
}
