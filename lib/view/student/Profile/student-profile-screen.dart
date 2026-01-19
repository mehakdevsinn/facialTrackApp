// import 'package:facialtrackapp/constants/color_pallet.dart';
// import 'package:flutter/material.dart';
// import 'package:percent_indicator/percent_indicator.dart';

// class StudentProfileScreen extends StatelessWidget {
//   const StudentProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 244, 243, 243),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: Column(
//               children: [
//                 /// 📌 HEADER (Cover + Profile Pic)
//                 Stack(
//                   clipBehavior: Clip.none,
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       height: 140,
//                       width: double.infinity,
//                       color: ColorPallet.primaryBlue,
//                     ),
//                     Positioned(
//                       bottom: -50,
//                       child: CircleAvatar(
//                         radius: 55,
//                         backgroundColor: Colors.white,
//                         child: CircleAvatar(
//                           radius: 50,
//                           backgroundImage: NetworkImage(
//                             "https://i.pravatar.cc/150?img=12",
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 60),

//                 /// 👤 Name & ID
// Text(
//   "Ahmad Hassan",
//   style: TextStyle(
//     fontSize: 23,
//     fontWeight: FontWeight.bold,
//     color: Colors.black,
//   ),
// ),

// const SizedBox(height: 4),
// Text(
//   "ID: STU-2024-1234",
//   style: TextStyle(color: Colors.grey.shade600, fontSize: 17),
// ),

// const SizedBox(height: 4),
// Container(
//   decoration: BoxDecoration(
//     border: Border.all(color: Colors.grey),
//     borderRadius: BorderRadius.circular(20),
//   ),
//   child: Padding(
//     padding: const EdgeInsets.all(5.0),
//     child: Text(
//       "Computer Science - Semester 5",
//       style: TextStyle(
//         color: Colors.grey.shade800,
//         fontSize: 12,
//       ),
//     ),
//   ),
//                 ),

// const SizedBox(height: 20),

// /// 📄 Personal Info Card
// _infoCard(),

// const SizedBox(height: 16),

// /// 📊 Attendance Overview
// _attendanceCard(),

// const SizedBox(height: 16),

// _thisMonthCard(),

// const SizedBox(height: 24),

// /// 📥 Buttons
// _bottomButtons(context),

// const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _infoCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 3,
//             offset: const Offset(2, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _infoRow(Icons.medical_information_outlined, "Personal Information"),

//           _infoRow(Icons.email, "ahmad.hassan@university.edu"),
//           const SizedBox(height: 8),
//           _infoRow(Icons.phone, "+92 300 1234567"),
//           const SizedBox(height: 8),
//           _infoRow(Icons.calendar_today, "Enrolled: September 2023"),
//         ],
//       ),
//     );
//   }

// Widget _infoRow(IconData icon, String text) {
//   return Row(
//     children: [
//       Icon(icon, color: ColorPallet.primaryBlue),
//       const SizedBox(width: 12),
//       Text(text, style: TextStyle(fontSize: 14)),
//     ],
//   );
// }

//   Widget _attendanceCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircularPercentIndicator(
//             radius: 50,
//             lineWidth: 8,
//             percent: 0.87,
//             center: Text(
//               "87%",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             progressColor: Colors.green,
//             backgroundColor: Colors.green.withOpacity(0.2),
//           ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _statRow("Total Classes", "145", Icons.event),
//               const SizedBox(height: 6),
//               _statRow("Present", "126", Icons.check_circle),
//               const SizedBox(height: 6),
//               _statRow("Absent", "19", Icons.cancel),
//               const SizedBox(height: 6),
//               _statRow("Leave", "5", Icons.airplane_ticket),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statRow(String title, String value, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, size: 18, color: Colors.grey.shade600),
//         const SizedBox(width: 8),
//         Text("$title: $value", style: TextStyle(fontSize: 13)),
//       ],
//     );
//   }

//   Widget _thisMonthCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "This Month",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Text(
//                 "92%",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(width: 12),
//               Text("Classes attended: 18/20", style: TextStyle(fontSize: 14)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text("Best subject: ⭐ Mathematics", style: TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   Widget _bottomButtons(BuildContext context) {
//     return Column(
//       children: [
//         ElevatedButton.icon(
//           onPressed: () {},
//           icon: Icon(Icons.download_rounded),
//           label: Text("Download Report"),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blueAccent,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//         ),
//         const SizedBox(height: 8),
//         OutlinedButton(
//           onPressed: () {},
//           child: const Text("Logout", style: TextStyle(color: Colors.red)),
//           style: OutlinedButton.styleFrom(
//             side: BorderSide(color: Colors.red),
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Yeh back button ko fully disable kar deta hai
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 248, 248, 248),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                // Content below the profile card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      /// 📄 Personal Info Card
                      _infoCard(),

                      const SizedBox(height: 16),

                      /// 📊 Attendance Overview
                      _attendanceCard(),

                      const SizedBox(height: 16),

                      _thisMonthCard(),

                      const SizedBox(height: 24),

                      _buildLogoutButton(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 1. Dark Blue Background (Top Section)
        Container(
          height: 220, // Reduced height to fix the "distance"
          width: double.infinity,
          color: const Color.fromARGB(255, 35, 4, 170),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 12, left: 15),
                    child: Text(
                      "Student Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.settings, color: Colors.white),
                  //   onPressed: () {},
                  // ),
                ],
              ),
            ),
          ),
        ),

        // 2. The White Card with Profile Details
        // We use Padding to push it down so it overlaps the blue
        Container(
          margin: const EdgeInsets.only(
            top: 160,
          ), // Adjust this to control the overlap
          width: double.infinity,
          decoration: const BoxDecoration(
            color: const Color.fromARGB(255, 248, 248, 248),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 70), // Space for the floating image
              Text(
                "Ahmad Hassan",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),
              Text(
                "ID: STU-2024-1234",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 17),
              ),

              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Computer Science - Semester 5",
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        Positioned(
          top: 100, // Positioned exactly between blue and white sections
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFE0E0FF), // Placeholder light purple
              backgroundImage: AssetImage('assets/profile.png'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(Icons.medical_information_outlined, "Personal Information"),

          SizedBox(height: 20),
          Divider(),
          _infoRow(Icons.email, "ahmad.hassan@university.edu"),
          const SizedBox(height: 8),
          _infoRow(Icons.phone, "+92 300 1234567"),
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today, "Enrolled: September 2023"),
        ],
      ),
    );
  }

  Widget _subjectTile(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.medical_information_outlined, "Personal Information"),

          _infoRow(Icons.email, "ahmad.hassan@university.edu"),
          const SizedBox(height: 8),
          _infoRow(Icons.phone, "+92 300 1234567"),
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today, "Enrolled: September 2023"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: ColorPallet.primaryBlue),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _attendanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 8,
            percent: 0.87,
            center: Text(
              "87%",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            progressColor: Colors.green,
            backgroundColor: Colors.green.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statRow("Total Classes", "145", Icons.event),
              const SizedBox(height: 6),
              _statRow("Present", "126", Icons.check_circle),
              const SizedBox(height: 6),
              _statRow("Absent", "19", Icons.cancel),
              const SizedBox(height: 6),
              _statRow("Leave", "5", Icons.airplane_ticket),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text("$title: $value", style: TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _thisMonthCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This Month",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "92%",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text("Classes attended: 18/20", style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Best subject: ⭐ Mathematics", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Builder(
      // Use Builder to get the correct context if needed
      builder: (context) => SizedBox(
        width: 200, // Adjusted width to match Figma
        child: ElevatedButton.icon(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            "Logout",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF27121),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5), // Background dimming
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        // Unique Curve: Bounce effect (BackOut)
        final curvedValue = Curves.easeOutBack.transform(anim1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(
            0.0,
            curvedValue * -200,
            0.0,
          ), // Top se slide hokar aayega
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Colors.white.withOpacity(
                0.95,
              ), // Slight glass effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  30,
                ), // More rounded for modern look
                side: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              content: Container(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Unique Header: Orange Glow Icon
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF27121).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.power_settings_new_rounded, // Unique logout icon
                        size: 50,
                        color: Color(0xFFF27121),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Ready to Leave?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Are you sure to the\nwant to logout?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        // No / Cancel Button
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Not yet",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Yes / Logout Button (Styled)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF27121,
                                  ).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RoleSelectionScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF27121),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text("Yes, Logout"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
