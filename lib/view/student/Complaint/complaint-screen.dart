import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/student/Complaint/my_complaints_screen.dart';
import 'package:facialtrackapp/view/student/Complaint/technical_complaint_screen.dart';
import 'package:flutter/material.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Complaints & Support",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.history),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const MyComplaintsScreen(),
          //       ),
          //     );
          //   },
          //   tooltip: "My Complaints",
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(19.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOptionCard(
              context,
              title: "Report Technical Issue",
              description:
                  "App bugs, login problems, or face verification issues.",
              icon: Icons.build_circle_outlined,
              color: ColorPallet.primaryBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TechnicalComplaintScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // _buildOptionCard(
            //   context,
            //   title: "Attendance Issues",
            //   description:
            //       "To report attendance issues, please go to your Attendance History and select the specific class session.",
            //   icon: Icons.calendar_today_outlined,
            //   color: Colors.blue,
            //   onTap: () {
            //     // This is just informational as requested in requirements:
            //     // "Access: From attendance history details"
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         content: Text(
            //           "Please go to Attendance History to report specific class issues.",
            //         ),
            //       ),
            //     );
            //   },
            // ),
            const SizedBox(height: 16),

            _buildOptionCard(
              context,
              title: "View My Complaints",
              description: "Check the status of your reported issues.",
              icon: Icons.assignment_outlined,
              color: ColorPallet.primaryBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyComplaintsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            // offset: const Offset(2, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
