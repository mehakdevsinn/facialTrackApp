import 'dart:ui';

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/student/Subjects/subject-detail.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class timeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const timeInfo(this.icon, this.label, this.time);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 13),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(255, 126, 125, 125),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

Widget todayAttendanceCard() {
  return Padding(
    padding: const EdgeInsets.only(left: 1, right: 1),
    child: Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 16),

      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Today's Attendance - Wed, Dec 10",
            style: TextStyle(
              color: Color.fromARGB(255, 102, 102, 102),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: ColorPallet.softGreen, size: 30),
              SizedBox(width: 6),
              Text(
                "Present",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 7),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              timeInfo(Icons.login, "Entry Time", "09:02 AM"),

              SizedBox(width: 18),
              SizedBox(
                height: 40,
                child: VerticalDivider(thickness: 1, color: Colors.grey),
              ),
              SizedBox(width: 18),

              timeInfo(Icons.logout, "Exit Time", "03:45 PM"),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget overallAttendanceCard() {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 60,
            lineWidth: 12,
            percent: attendancePercent,
            center: Text(
              "${(attendancePercent * 100).toInt()}%",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            linearGradient: attendanceGradient(attendancePercent),

            backgroundColor: Colors.grey.shade200,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 10),
          const Text(
            "Overall Attendance",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text("Last 30 days", style: TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );
}

double attendancePercent = 0.88;
LinearGradient attendanceGradient(double percent) {
  if (percent < 0.5) {
    return LinearGradient(colors: [Colors.red.withOpacity(0.2), Colors.red]);
  } else if (percent < 0.75) {
    return LinearGradient(
      colors: [Colors.orange.withOpacity(0.2), Colors.orange],
    );
  } else {
    return LinearGradient(
      colors: [
        Colors.green.withOpacity(0.7),
        const Color.fromARGB(255, 8, 123, 216),
      ],
    );
  }
}

Widget subjectsSection(context) {
  return Padding(
    padding: const EdgeInsets.only(left: 17, right: 17),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Subjects",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 19, 19, 19),
          ),
        ),
        const SizedBox(height: 12),
        subjectTile(
          context,
          title: "Computer Science",
          percent: "92%",
          color: Colors.green,
          icon: Icons.computer,
          teacher: "Mr. Smith",
          attendance: 92,
          presentDays: 46,
          absentDays: 4,
        ),

        subjectTile(
          context,
          title: "Mathematics",
          percent: "89%",
          color: Colors.green,
          icon: Icons.calculate,
          teacher: "Mrs. Brown",
          attendance: 89,
          presentDays: 40,
          absentDays: 5,
        ),

        subjectTile(
          context,
          title: "Physics",
          percent: "74%",
          color: Colors.orange,
          icon: Icons.science,
          teacher: "Dr. John",
          attendance: 74,
          presentDays: 37,
          absentDays: 13,
        ),
      ],
    ),
  );
}

Widget subjectTile(
  BuildContext context, {
  required String title,
  required String percent,
  required Color color,
  required IconData icon,
  required String teacher,
  required int attendance,
  required int presentDays,
  required int absentDays,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectDetailScreen(
            subject: title,
            teacher: teacher,
            attendance: attendance,
            presentDays: presentDays,
            absentDays: absentDays,
            color: color,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            percent,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: ColorPallet.grey,
          ),
        ],
      ),
    ),
  );
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 3,
        offset: const Offset(4, 4),
      ),
    ],
  );
}
