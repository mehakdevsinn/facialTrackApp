import 'package:facialtrackapp/view/Admin/Profile/admin_change_password_screen.dart';
import 'package:facialtrackapp/view/Admin/Profile/admin_edit_profile_screen.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20profile%20screen%20widgets/logout_button.dart';
import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // 1. Dark Blue Background
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
                            const SizedBox(width: 20),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Admin Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. White Card Section (for alignment overlap)
                  Container(
                    margin: const EdgeInsets.only(top: 160),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 70),
                        const Text(
                          "Administrator",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "ID: ADM-001",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Profile Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildInfoCard(
                                icon: Icons.email_outlined,
                                label: "Email",
                                value: "admin@facialtrack.com",
                                color: Colors.blue,
                              ),
                              _buildInfoCard(
                                icon: Icons.phone_outlined,
                                label: "Phone",
                                value: "+92 300 1234567",
                                color: Colors.green,
                              ),
                              _buildInfoCard(
                                icon: Icons.badge_outlined,
                                label: "Employee ID",
                                value: "ADM-2024-001",
                                color: Colors.purple,
                              ),
                              _buildInfoCard(
                                icon: Icons.business_outlined,
                                label: "Department",
                                value: "Administration",
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Account Settings",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    // Edit Profile Tile
                                    // ListTile(
                                    //   contentPadding: EdgeInsets.zero,
                                    //   leading: Container(
                                    //     padding: const EdgeInsets.all(8),
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.blue.withOpacity(0.1),
                                    //       borderRadius: BorderRadius.circular(
                                    //         8,
                                    //       ),
                                    //     ),
                                    //     child: const Icon(
                                    //       Icons.person_outline,
                                    //       color: Colors.blue,
                                    //     ),
                                    //   ),
                                    //   title: const Text(
                                    //     "Edit Profile",
                                    //     style: TextStyle(
                                    //       fontWeight: FontWeight.w500,
                                    //     ),
                                    //   ),
                                    //   trailing: const Icon(
                                    //     Icons.chevron_right,
                                    //     color: Colors.grey,
                                    //   ),
                                    //   onTap: () {
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             const AdminEditProfileScreen(),
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                    // Divider(
                                    //   height: 20,
                                    //   thickness: 1,
                                    //   color: Colors.grey.withOpacity(0.1),
                                    // ),
                                    // Change Password Tile (Teacher Style)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.lock_outline,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      title: const Text(
                                        "Change Password",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AdminChangePasswordScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              const LogoutButtonWidget(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
