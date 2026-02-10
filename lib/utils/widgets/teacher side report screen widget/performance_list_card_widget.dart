import 'package:flutter/material.dart';
import 'package:facialtrackapp/view/teacher/Report/view_full_report_screen.dart';

class PerformanceListCard extends StatelessWidget {
  final bool showOnlyLow;
  final String selectedSemester;
  final String selectedMonth;
  final String selectedSubject;

  const PerformanceListCard({
    super.key,
    required this.showOnlyLow,
    required this.selectedSemester,
    required this.selectedMonth,
    required this.selectedSubject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Class Performance",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                "Sorted by %",
                style: TextStyle(
                  color: Color(0xFF1A4B8F),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (!showOnlyLow) _studentRow("Jane Doe", 90),
          _studentRow("Lisa Davis", 70),
          _studentRow("Mike King", 72),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullReportScreen(
                      month: selectedMonth,
                      subject: selectedSubject,
                      semester: selectedSemester,
                    ),
                  ),
                );
              },
              child: const Text(
                "View Complete Report",
                style: TextStyle(
                  color: Color(0xFF1A4B8F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentRow(String name, int percentage) {
    bool isLow = percentage < 75;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1A4B8F).withOpacity(0.1),
            child: Text(
              name[0],
              style: const TextStyle(
                color: Color(0xFF1A4B8F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            "$percentage%",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: (isLow ? Colors.orange : Colors.teal).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                isLow ? "LOW" : "OKAY",
                style: TextStyle(
                  color: isLow ? Colors.orange : Colors.teal,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
