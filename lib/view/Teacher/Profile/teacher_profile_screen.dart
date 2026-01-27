import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/teacher/Password%20Changed/change_password_inside_teacher_profile.dart';
import 'package:flutter/material.dart';

class TeacherProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const TeacherProfileScreen({super.key, this.showBackButton = false});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.showBackButton,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: SafeArea(
        child: Scaffold(
                    backgroundColor: Colors.grey[100],

          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                // Content below the profile card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildOverviewCard(),
                      const SizedBox(height: 20),
                      _buildSubjectsCard(),
                      const SizedBox(height: 20),
                      _buildAccountSettingsCard(),
                      const SizedBox(height: 30),

                      _buildLogoutButton(),
                      const SizedBox(height: 40), // Extra space at bottom
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

  // Widget _buildHeader(BuildContext context) {
  //   return Stack(
  //     alignment: Alignment.topCenter,
  //     children: [
  //       // 1. Dark Blue Background (Top Section)
  //       Container(
  //         height: 220, // Reduced height to fix the "distance"
  //         width: double.infinity,
  //         color: const Color.fromARGB(255, 35, 4, 170),
  //         child: SafeArea(
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 const Padding(
  //                   padding: EdgeInsets.only(top: 12,left: 15),
  //                   child: Text("Teacher Profile",
  //                     style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
  //                 ),
  //                 IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),

  //       // 2. The White Card with Profile Details
  //       // We use Padding to push it down so it overlaps the blue
  //       Container(
  //         margin: const EdgeInsets.only(top: 160), // Adjust this to control the overlap
  //         width: double.infinity,
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.only(

  //             topLeft: Radius.circular(40),
  //             topRight: Radius.circular(40),
  //           ),
  //         ),
  //         child: Column(
  //           children: [
  //             const SizedBox(height: 70), // Space for the floating image
  //             const Text("Dr. Anya Sharma",
  //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  //             Text("ID: TCH-2025-014",
  //               style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
  //             const SizedBox(height: 20),
  //           ],
  //         ),
  //       ),

  //       // 3. Profile Image (Floating)
  //       Positioned(
  //         top: 100, // Positioned exactly between blue and white sections
  //         child: Container(
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             border: Border.all(color: Colors.white, width: 4),
  //             boxShadow: [
  //               BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
  //             ]
  //           ),
  //           child: const CircleAvatar(
  //             radius: 60,
  //             backgroundColor: Color(0xFFE0E0FF), // Placeholder light purple
  //             backgroundImage: AssetImage('assets/profile.png'),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 1. Dark Blue Background (Top Section)
        Container(
          height: 220,
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
                children: [
                  // AGAR showBackButton true hai toh icon dikhao, warna empty space
                  widget.showBackButton
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      : const SizedBox(
                          width: 20,
                        ), // Left margin for title when no back button

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        "Teacher Profile",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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

        // 2. White Card Section
        Container(
          margin: const EdgeInsets.only(top: 160),
          width: double.infinity,
          decoration:  BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 70),
              const Text(
                "Dr. Saima Kamran",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "ID: TCH-2025-014",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // 3. Floating Profile Image
        Positioned(
          top: 100,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFE0E0FF),
              backgroundImage: AssetImage('assets/profile.png'),
            ),
          ),
        ),
      ],
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
                    // Row(
                    //   children: [
                    //     // No / Cancel Button
                    //     Expanded(
                    //       child: TextButton(
                    //         onPressed: () => Navigator.pop(context),
                    //         child: const Text(
                    //           "Not yet",
                    //           style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    //         ),
                    //       ),
                    //     ),
                    //      const Icon(
                    //       Icons.power_settings_new_rounded, // Unique logout icon
                    //       size: 50,
                    //       color: Color(0xFFF27121),
                    //     ),
                    //   ]    ),
                    //   const SizedBox(height: 20),
                    //   const Text(
                    //     "Ready to Leave?",
                    //     style: TextStyle(
                    //       fontSize: 22,
                    //       fontWeight: FontWeight.w900,
                    //       letterSpacing: 0.5,
                    //     ),
                    //   ),
                    //   const SizedBox(height: 10),
                    //   const Text(
                    //     "Are you sure to the\nwant to logout?",
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(color: Colors.grey, fontSize: 14),
                    //   ),
                    //   const SizedBox(height: 30),
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

  // --- Keep your existing _buildOverviewCard, _buildSubjectsCard, etc. below ---
  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _rowInfo(Icons.group, "Subjects assigned", "4", Colors.green),
          const Divider(height: 30),
          _rowInfo(
            Icons.access_time,
            "Total classes handled",
            "13",
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Subjects Assigned",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _subjectTile(
            Icons.book,
            "Computer Science",
            "BSCS - Semester 5",
            Colors.blue,
          ),
          const Divider(),
          _subjectTile(
            Icons.menu_book,
            "Data Structures",
            "BSCS - Semester 5",
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade400),
        const SizedBox(width: 15),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

  Widget _buildAccountSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Account Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_outline, color: Colors.orange),
            ),
            title: const Text(
              "Change Password",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangePasswordScreen()));
              print("Navigate to Change Password Screen");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Builder(
      // Use Builder to get the correct context if needed
      builder: (context) => SizedBox(
  width: double.infinity,
        height: 50,        child: ElevatedButton.icon(
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
}
