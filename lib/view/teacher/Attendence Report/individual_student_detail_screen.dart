import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Attendence%20Report/student_day_by_day_attendence_report.dart';
import 'package:facialtrackapp/view/teacher/Attendence%20Report/student_percenatge_screen.dart'; // Ensure correct path
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentDetailOptionsScreen extends StatelessWidget {
  final String studentName;
  // --- ADD THESE TWO LINES ---
  final DateTime? startDate;
  final DateTime? endDate;

  // --- UPDATE THE CONSTRUCTOR ---
  const StudentDetailOptionsScreen({
    super.key, 
    required this.studentName,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text("$studentName Attendance"),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Report Type",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
            ),
            if (startDate != null && endDate != null)
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorPallet.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month, size: 14, color: ColorPallet.primaryBlue),
          const SizedBox(width: 6),
          Text(
            "${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM').format(endDate!)}",
            style: TextStyle(
              color: ColorPallet.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  ),
            const Text(
              "How would you like to view the attendance data?",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            _buildOptionCard(
              context: context,
              title: "Day-by-Day Report",
              subtitle: "Detailed list of every single day's status",
              icon: Icons.calendar_view_day_rounded,
              color: Colors.blue,
            onTap: () {
    // --- YE NAVIGATOR ADD KAREIN ---
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayByDayReportScreen(
          studentName: studentName, // Jo class mein variable hai
          startDate: startDate,     // Calendar se aya hua start date
          endDate: endDate,         // Calendar se aya hua end date
        ),
      ),
    );
  },
            ),

            const SizedBox(height: 20),

            _buildOptionCard(
              context: context,
              title: "Percentage Analytics",
              subtitle: "Visual charts and attendance summary",
              icon: Icons.pie_chart_rounded,
              color: Colors.orange,
              onTap: () {
                // --- NOW THESE WILL WORK ---
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentPercentageScreen(
                      studentName: studentName,
                      startDate: startDate, 
                      endDate: endDate,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Your _buildOptionCard helper method...
  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}