import 'package:flutter/material.dart';

class ReportDropdowns extends StatelessWidget {
  final String selectedSemester;
  final String selectedMonth;
  final String selectedSubject;
  final List<String> semesters;
  final List<String> months;
  final List<String> subjects;
  final Function(String?) onSemesterChanged;
  final Function(String?) onMonthChanged;
  final Function(String?) onSubjectChanged;

  const ReportDropdowns({
    super.key,
    required this.selectedSemester,
    required this.selectedMonth,
    required this.selectedSubject,
    required this.semesters,
    required this.months,
    required this.subjects,
    required this.onSemesterChanged,
    required this.onMonthChanged,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDropdown(
          "Semester",
          selectedSemester,
          semesters,
          Icons.school,
          onSemesterChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                "Month",
                selectedMonth,
                months,
                Icons.calendar_month,
                onMonthChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                "Subject",
                selectedSubject,
                subjects,
                Icons.auto_stories,
                onSubjectChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.unfold_more, size: 14),
              items: items
                  .map(
                    (val) => DropdownMenuItem(
                      value: val,
                      child: Row(
                        children: [
                          Icon(icon, size: 14, color: const Color(0xFF1A4B8F)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              val,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
