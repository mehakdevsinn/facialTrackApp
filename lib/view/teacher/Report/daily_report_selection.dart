import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Report/daily_attendance_report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyReportSelectionScreen extends StatefulWidget {
  const DailyReportSelectionScreen({super.key});

  @override
  State<DailyReportSelectionScreen> createState() =>
      _DailyReportSelectionScreenState();
}

class _DailyReportSelectionScreenState
    extends State<DailyReportSelectionScreen> {
  String? selectedSemester;
  String? selectedSubject;
  DateTime? selectedDate;

  final List<String> semesters = [
    "Semester 2",
    "Semester 4",
    "Semester 6",
    "Semester 8",
  ];
  final List<String> subjects = [
    "Computer Science",
    "Software Engineering",
    "Information Technology",
    "Artificial Intelligence",
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorPallet.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Specific Date Report",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorPallet.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Report Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select the semester, subject and date to view the attendance report.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 35),

            _buildLabel("Select Semester"),
            _buildDropdown(
              hint: "Choose Semester",
              value: selectedSemester,
              items: semesters,
              onChanged: (val) => setState(() => selectedSemester = val),
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 25),

            _buildLabel("Select Subject"),
            _buildDropdown(
              hint: "Choose Subject",
              value: selectedSubject,
              items: subjects,
              onChanged: (val) => setState(() => selectedSubject = val),
              icon: Icons.auto_stories_outlined,
            ),
            const SizedBox(height: 25),

            _buildLabel("Select Date"),
            _buildDateTile(),

            const SizedBox(height: 50),

            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: ColorPallet.primaryBlue,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: ColorPallet.primaryBlue.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(item, style: const TextStyle(fontSize: 15)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateTile() {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: ColorPallet.primaryBlue.withOpacity(0.7),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : DateFormat('dd MMMM, yyyy').format(selectedDate!),
                style: TextStyle(
                  color: selectedDate == null ? Colors.grey : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.edit_calendar_outlined,
              size: 20,
              color: ColorPallet.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    bool isReady =
        selectedSemester != null &&
        selectedSubject != null &&
        selectedDate != null;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady
              ? ColorPallet.primaryBlue
              : Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: isReady ? 3 : 0,
        ),
        onPressed: isReady
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyAttendanceReportScreen(
                      semester: selectedSemester!,
                      subject: selectedSubject!,
                      date: selectedDate!,
                    ),
                  ),
                );
              }
            : null,
        child: const Text(
          "Generate Report",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
