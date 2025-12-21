import 'package:facialtrackapp/utilis/color_pallet.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  int selectedChipIndex = 0;

  String selectedMonth = "December 2025";

  final List<String> months = [
    "January 2025",
    "February 2025",
    "March 2025",
    "April 2025",
    "May 2025",
    "June 2025",
    "July 2025",
    "August 2025",
    "September 2025",
    "October 2025",
    "November 2025",
    "December 2025",
  ];

  final List<String> subjects = [
    "All Subjects",
    "Computer Science",
    "Mathematics",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 243, 243),

      appBar: AppBar(
        backgroundColor: ColorPallet.deepBlue,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text(
          "Attendance History",
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Icon(Icons.filter_alt_outlined, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),

      body: Column(
        children: [
          Container(
            color: ColorPallet.white,
            padding: EdgeInsets.only(top: 13, bottom: 13),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Row(
                children: List.generate(subjects.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedChipIndex = index;
                        });
                      },
                      child: _filterChip(
                        subjects[index],
                        selected: selectedChipIndex == index,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth,

                dropdownColor: const Color.fromARGB(255, 235, 235, 235),
                icon: const Icon(Icons.keyboard_arrow_down),
                isExpanded: true,
                items: months.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(month),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                AttendanceCard(
                  date: "Dec 10, 2025",
                  day: "Wednesday",
                  entry: "09:02 AM",
                  exit: "10:30 AM",
                  subject: "Computer Science",
                  present: true,
                ),
                AttendanceCard(
                  date: "Dec 09, 2025",
                  day: "Tuesday",
                  entry: "08:55 AM",
                  exit: "11:45 AM",
                  subject: "Mathematics",
                  present: true,
                ),
                AttendanceCard(
                  date: "Dec 08, 2025",
                  day: "Monday",
                  present: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String text, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? ColorPallet.deepBlue
            : const Color.fromARGB(255, 185, 183, 183),
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: Colors.green),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? ColorPallet.white : ColorPallet.black,
          fontSize: 12,
        ),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String date;
  final String day;
  final String? entry;
  final String? exit;
  final String? subject;
  final bool present;

  const AttendanceCard({
    super.key,
    required this.date,
    required this.day,
    this.entry,
    this.exit,
    this.subject,
    required this.present,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: present ? Colors.green : Colors.red,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: present
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    present ? "Present" : "Absent",
                    style: TextStyle(
                      color: present ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            if (present) ...[
              const SizedBox(height: 10),

              _infoRow(Icons.login, "Entry: $entry"),
              const SizedBox(height: 6),
              _infoRow(Icons.logout, "Exit: $exit"),
              const SizedBox(height: 6),
              _infoRow(Icons.book, subject ?? ""),
            ],

            const SizedBox(height: 5),

            Divider(),
            const SizedBox(height: 7),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "View Details",
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
