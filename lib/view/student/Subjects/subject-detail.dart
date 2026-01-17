import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/student/Attendence%20History/attendence-detail-screen.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SubjectDetailScreen extends StatelessWidget {
  final String subject;
  final String teacher;
  final int attendance;
  final int presentDays;
  final int absentDays;
  final Color color;

  const SubjectDetailScreen({
    super.key,
    required this.subject,
    required this.teacher,
    required this.attendance,
    required this.presentDays,
    required this.absentDays,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3F3),

      appBar: AppBar(
        backgroundColor: ColorPallet.primaryBlue,
        elevation: 0,
        title: Text(
          "$subject Detail",
          style: const TextStyle(fontSize: 18, color: ColorPallet.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorPallet.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          // Padding(
          //   padding: EdgeInsets.only(right: 12),
          //   child: Icon(Icons.info_outline, color: ColorPallet.white),
          // ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),

              decoration: _cardDecoration(),
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 45,
                    lineWidth: 7,
                    percent: attendance / 100,

                    center: Text(
                      "$attendance%",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    progressColor: color,
                    backgroundColor: color.withOpacity(0.2),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Teacher: $teacher",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "This is your calculated attendance rate based on all recorded sessions for $subject.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 7),
                  const Text(
                    "Recent Sessions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 28),

                  _sessionTile(
                    day: "Monday",
                    exit: "4:00pm",
                    entry: "10:30am",
                    present: true,
                    context: context,

                    date: "2025-10-25",
                    status: "Present",
                    statusColor: Colors.green,
                    time: "09:20 - 10:30",
                  ),

                  _sessionTile(
                    day: "Tuesday",
                    exit: "4:00pm",
                    entry: "10:30am",
                    present: false,
                    context: context,

                    date: "2025-10-23",
                    status: "Absent",
                    statusColor: Colors.red,
                    time: "---- - 10:28",
                  ),

                  _sessionTile(
                    day: "Wednesday",
                    exit: "4:00pm",
                    entry: "10:30am",
                    present: true,
                    context: context,
                    date: "2025-10-21",
                    status: "Late",
                    statusColor: Colors.orange,
                    time: "09:15 - 10:30",
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionTile({
    required String date,
    required String status,

    required String day,
    required String exit,
    required String entry,
    required bool present,

    required Color statusColor,
    required String time,
    bool isLast = false,

    required final context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceDetailScreen(
              date: date,
              day: day,
              entry: entry,
              exit: exit,
              subject: subject ?? "",
              present: present,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          if (!isLast) const Divider(height: 24),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 2,
          offset: const Offset(4, 4),
        ),
      ],
    );
  }
}
