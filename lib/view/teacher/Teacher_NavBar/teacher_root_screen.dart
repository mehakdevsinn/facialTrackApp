// import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
// import 'package:circular_bottom_navigation/tab_item.dart';
// import 'package:facialtrackapp/constant/app_color.dart';
// import 'package:facialtrackapp/view/Teacher/Dashborad/teacher_dashboard_screen.dart';
// import 'package:facialtrackapp/view/Teacher/Profile/teacher_profile_screen.dart';
// import 'package:facialtrackapp/view/Teacher/Report/report_screen.dart';
// import 'package:facialtrackapp/view/Teacher/Start Screen/start_screen.dart';
// import 'package:flutter/material.dart';

// class TeacherRootScreen extends StatefulWidget {
//   const TeacherRootScreen({super.key});

//   @override
//   State<TeacherRootScreen> createState() => _TeacherRootScreenState();
// }

// class _TeacherRootScreenState extends State<TeacherRootScreen> {
//   int selectedPos = 0;
//   late CircularBottomNavigationController _navigationController;

//   @override
//   void initState() {
//     super.initState();
//     _navigationController =
//         CircularBottomNavigationController(selectedPos);
//   }

//   @override
//   void dispose() {
//     _navigationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _getBody(selectedPos),
//       bottomNavigationBar: Material(
//         elevation: 10,
//         child: _bottomNav(),
//       ),
//     );
//   }

//   /// ---------------- SCREEN SWITCH ----------------
//   Widget _getBody(int pos) {
//     switch (pos) {
//       case 0:
//         return const TeacherDashboardScreen();
//       case 1:
//         return const StartSessionScreen();
//       case 2:
//         return const ReportScreen();
//       case 3:
//         return const TeacherProfileScreen();
//       default:
//         return const TeacherDashboardScreen();
//     }
//   }

//   /// ---------------- BOTTOM NAV ----------------
//   Widget _bottomNav() {
//     return CircularBottomNavigation(
//       tabItems,
//       controller: _navigationController,
//       selectedPos: selectedPos,
//       barHeight: 65,
//       iconsSize: 24,
//       animationDuration: const Duration(milliseconds: 300),

//       /// White background
//       barBackgroundColor: Colors.white,

//       /// Unselected ICON color
//       normalIconColor: Colors.grey,

//       selectedCallback: (int? pos) {
//         setState(() {
//           selectedPos = pos ?? 0;
//         });
//       },
//     );
//   }

//   /// ---------------- TAB ITEMS (ICON + LABEL) ----------------
//   final List<TabItem> tabItems = [
//     TabItem(
//       Icons.dashboard_rounded,
//       "Dashboard",
//       const Color.fromARGB(255, 73, 33, 252), // selected icon + text color
//       labelStyle: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w500,
//         color: Colors.grey, // ✅ unselected text color
//       ),
//     ),
//     TabItem(
//       Icons.play_circle_fill,
//       "Start Section",
//       const Color.fromARGB(255, 73, 33, 252), // selected icon + text color
//       labelStyle: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w500,
//         color: Colors.grey,
//       ),
//     ),
//     TabItem(
//       Icons.bar_chart_rounded,
//       "Reports",
//       const Color.fromARGB(255, 73, 33, 252), // selected icon + text color
//       labelStyle: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w500,
//         color: Colors.grey,
//       ),
//     ),
//     TabItem(
//       Icons.person_rounded,
//       "Profile",
//       const Color.fromARGB(255, 73, 33, 252), // selected icon + text color
//       labelStyle: const TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w500,
//         color: Colors.grey,
//       ),
//     ),
//   ];
// }
import 'package:facialtrackapp/view/teacher/Report/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:facialtrackapp/view/Teacher/Dashborad/teacher_dashboard_screen.dart';
import 'package:facialtrackapp/view/Teacher/Profile/teacher_profile_screen.dart';
import 'package:facialtrackapp/view/Teacher/Start Screen/start_screen.dart';

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
     AttendanceReport(),
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
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOut);
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
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const  Color.fromARGB(255, 35, 4, 170).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      _icons[index],
                      color: isSelected
                          ? const Color.fromARGB(255, 73, 33, 252)
                          : Colors.grey,
                      size: isSelected ? 28 : 24,
                    ),
                    const SizedBox(width: 6),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isSelected ? _labels[index] : "",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 73, 33, 252),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
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
