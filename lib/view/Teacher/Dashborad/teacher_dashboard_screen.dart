// import 'package:flutter/material.dart';

// class TeacherDashboardScreen extends StatelessWidget {
//   const TeacherDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffF6F8FB),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color.fromARGB(255, 73, 33, 252),
//         foregroundColor: Colors.white,
//         title: const Text(
//           'Facial Track',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
//         ),
//         actions: [
//           PopupMenuButton<int>(
//             offset: const Offset(0, 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             onSelected: (value) {
//               if (value == 1) {
//                 // View Profile action
//               } else if (value == 2) {
//                 // Logout action
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               margin: const EdgeInsets.only(right: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 18,
//                     backgroundImage: AssetImage('assets/logo.png'),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Mr. Anderson',
//                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(width: 4),
//                   const Icon(Icons.keyboard_arrow_down, color: Colors.white),
//                 ],
//               ),
//             ),
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 1,
//                 child: ListTile(
//                   leading: Icon(Icons.person_outline),
//                   title: Text('View Profile'),
//                   contentPadding: EdgeInsets.zero,
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 2,
//                 child: ListTile(
//                   leading: Icon(Icons.logout, color: Colors.red),
//                   title: Text('Logout', style: TextStyle(color: Colors.red)),
//                   contentPadding: EdgeInsets.zero,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: MediaQuery.removePadding(
//         context: context,
//         removeBottom: true,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               const Text(
//                 'Welcome, Mr. Anderson',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 'Monday, October 28, 2024',
//                 style: TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 20),

//               // ---------------- GRID CARDS ----------------
//               GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1,
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: const [
//                   _AnimatedDashboardCard(
//                     color: Colors.green,
//                     icon: Icons.play_arrow,
//                     title: 'Start Attendance',
//                   ),
//                   _AnimatedDashboardCard(
//                     color: Colors.orange,
//                     icon: Icons.stop,
//                     title: 'End Attendance',
//                   ),
//                   _AnimatedDashboardCard(
//                     color: Colors.blue,
//                     icon: Icons.calendar_today,
//                     title: "Today's Logs",
//                   ),
//                   _AnimatedDashboardCard(
//                     color: Colors.purple,
//                     icon: Icons.bar_chart,
//                     title: 'Monthly Report',
//                   ),
//                   _AnimatedDashboardCard(
//                     color: Colors.teal,
//                     icon: Icons.menu_book,
//                     title: 'Subjects',
//                   ),
//                   _AnimatedDashboardCard(
//                     color: Colors.indigo,
//                     icon: Icons.person,
//                     title: 'Profile',
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),
// AnimatedLogoutCard(),
//               // Container(
//               //   height: 120,
//               //   decoration: BoxDecoration(
//               //     color: Colors.white,
//               //     borderRadius: BorderRadius.circular(18),
//               //     boxShadow: [
//               //       BoxShadow(
//               //         color: Colors.black.withOpacity(0.08),
//               //         blurRadius: 10,
//               //         spreadRadius: 1,
//               //         offset: const Offset(0, 6),
//               //       ),
//               //     ],
//               //   ),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.center,
//               //     children: const [
//               //       CircleAvatar(
//               //         radius: 22,
//               //         backgroundColor: Color(0xffFDECEA),
//               //         child: Icon(Icons.logout, color: Colors.red),
//               //       ),
//               //       SizedBox(width: 12),
//               //       Text(
//               //         'Logout',
//               //         style: TextStyle(
//               //           color: Colors.red,
//               //           fontSize: 16,
//               //           fontWeight: FontWeight.w600,
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ---------------- ANIMATED DASHBOARD CARD ----------------
// class _AnimatedDashboardCard extends StatefulWidget {
//   final Color color;
//   final IconData icon;
//   final String title;

//   const _AnimatedDashboardCard({
//     required this.color,
//     required this.icon,
//     required this.title,
//   });

//   @override
//   State<_AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
// }

// class _AnimatedDashboardCardState extends State<_AnimatedDashboardCard> {
//   bool _isPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _isPressed = true),
//       onTapUp: (_) => setState(() => _isPressed = false),
//       onTapCancel: () => setState(() => _isPressed = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         curve: Curves.easeOut,
//         transform: _isPressed ? (Matrix4.identity()..scale(0.95)) : Matrix4.identity(),
//         decoration: BoxDecoration(
//           color: _isPressed ? widget.color.withOpacity(0.2) : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: _isPressed 
//                   ? widget.color.withOpacity(0.15) 
//                   : widget.color.withOpacity(0.3),
//               blurRadius: 12,
//               spreadRadius: 2,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: widget.color.withOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(widget.icon, color: widget.color, size: 32),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               widget.title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey[800],
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Container(
//               height: 3,
//               width: 40,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(2),
//                 gradient: LinearGradient(
//                   colors: [widget.color.withOpacity(0.5), widget.color],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// class AnimatedLogoutCard extends StatefulWidget {
//   const AnimatedLogoutCard({super.key});

//   @override
//   State<AnimatedLogoutCard> createState() => _AnimatedLogoutCardState();
// }

// class _AnimatedLogoutCardState extends State<AnimatedLogoutCard> {
//   bool _isPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _isPressed = true),
//       onTapUp: (_) => setState(() => _isPressed = false),
//       onTapCancel: () => setState(() => _isPressed = false),
//       onTap: () {
//         // Logout logic yahan add karein
//       },
//       child: AnimatedContainer(
//         height: 100,
//         duration: const Duration(milliseconds: 150),
//         curve: Curves.easeOut,
//         transform: _isPressed ? (Matrix4.identity()..scale(0.97)) : Matrix4.identity(),
//         decoration: BoxDecoration(
//           color: _isPressed ? Colors.red.withOpacity(0.1) : Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: _isPressed 
//                   ? Colors.red.withOpacity(0.2) 
//                   : Colors.red.withOpacity(0.3),
//               blurRadius: 12,
//               spreadRadius: 2,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             CircleAvatar(
//               radius: 22,
//               backgroundColor: Color(0xffFDECEA),
//               child: Icon(Icons.logout, color: Colors.red),
//             ),
//             SizedBox(width: 12),
//             Text(
//               'Logout',
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 35, 4, 170),
        foregroundColor: Colors.white,
        title: const Text(
          'Facial Track',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    'Mr. Anderson',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
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
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Text(
                'Welcome, Mr. Anderson',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Monday, October 28, 2024',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // ---------------- GRID CARDS ----------------
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _AnimatedDashboardCard(
                    color: Colors.green,
                    icon: Icons.play_arrow,
                    title: 'Start Attendance',
                  ),
                  _AnimatedDashboardCard(
                    color: Colors.orange,
                    icon: Icons.stop,
                    title: 'End Attendance',
                  ),
                  _AnimatedDashboardCard(
                    color: Colors.blue,
                    icon: Icons.calendar_today,
                    title: "Today's Logs",
                  ),
                  _AnimatedDashboardCard(
                    color: Colors.purple,
                    icon: Icons.bar_chart,
                    title: 'Monthly Report',
                  ),
                  _AnimatedDashboardCard(
                    color: Colors.teal,
                    icon: Icons.menu_book,
                    title: 'Subjects',
                  ),
                  _AnimatedDashboardCard(
                    color: Colors.indigo,
                    icon: Icons.person,
                    title: 'Profile',
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // ---------------- LOGOUT CARD ----------------
              AnimatedLogoutCard(),
            ],
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

  const _AnimatedDashboardCard({
    required this.color,
    required this.icon,
    required this.title,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: _isPressed ? (Matrix4.identity()..scale(0.95)) : Matrix4.identity(),
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
      child: AnimatedContainer(
        height: 120,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: _isPressed ? (Matrix4.identity()..scale(0.97)) : Matrix4.identity(),
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
    );
  }
}
