import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/student/attendence-history-screen.dart';
import 'package:facialtrackapp/view/student/dashboard-screeen.dart';
import 'package:facialtrackapp/view/student/my-subjects-screen.dart';
import 'package:flutter/material.dart';

// import 'package:facialtrackapp/utilis/color_pallet.dart';
// import 'package:facialtrackapp/view/student/attendence-history-screen.dart';
// import 'package:facialtrackapp/view/student/dashboard-screeen.dart';
// import 'package:flutter/material.dart';
// import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     DashboardScreen(),
//     AttendanceHistoryScreen(),
//     AttendanceHistoryScreen(),
//     AttendanceHistoryScreen(),

//     // SubjectsScreen(),
//     // ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SalomonBottomBar(
//           currentIndex: _currentIndex,
//           onTap: (index) => setState(() => _currentIndex = index),
//           items: [
//             SalomonBottomBarItem(
//               icon: Icon(Icons.dashboard),
//               title: Text("Dashboard"),
//               selectedColor: ColorPallet.deepBlue,
//             ),

//             SalomonBottomBarItem(
//               icon: Icon(Icons.history),
//               title: Text("Attendance"),
//               selectedColor: Colors.orange,
//             ),

//             SalomonBottomBarItem(
//               icon: Icon(Icons.menu_book),
//               title: Text("Subjects"),
//               selectedColor: Colors.green,
//             ),

//             SalomonBottomBarItem(
//               icon: Icon(Icons.person),
//               title: Text("Profile"),
//               selectedColor: Colors.purple,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AttendanceHistoryScreen(),
    MySubjectsScreen(),
    // ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _indicatorAlignment(currentIndex),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              height: 3,
              width: MediaQuery.of(context).size.width / 4,
              color: Colors.green,
            ),
          ),

          Row(
            children: [
              _navItem(Icons.home, "Dashboard", 0),
              _navItem(Icons.calendar_today_rounded, "Attendance History", 1),
              _navItem(Icons.menu_book, "Subjects", 2),
              _navItem(Icons.person, "Profile", 3),
            ],
          ),
        ],
      ),
    );
  }

  Alignment _indicatorAlignment(int index) {
    switch (index) {
      case 0:
        return Alignment.topLeft;
      case 1:
        return Alignment(-0.33, -1);
      case 2:
        return Alignment(0.33, -1);
      case 3:
        return Alignment.topRight;
      default:
        return Alignment.topLeft;
    }
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isSelected = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          children: [
            const SizedBox(height: 9),
            Icon(icon, color: isSelected ? Colors.green : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.green : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
