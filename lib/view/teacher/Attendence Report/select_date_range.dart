import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Attendence%20Report/attendence_report_screen.dart';
import 'package:facialtrackapp/view/teacher/Attendence%20Report/date_range.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String? selectedSemester;
  String? selectedSubject;
  DateTime? startDate;
  DateTime? endDate;

  final List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
  ];
  final List<String> subjects = [
    'Mathematics',
    'Computer Science',
    'Physics',
    'History',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF), // Ultra light blue-grey
        appBar: AppBar(
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: ColorPallet.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Academic Selection",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          // ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Analyze Reports",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D3142),
                ),
              ),
              const Text(
                "Select details to generate analytics",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 35),

              // --- Semester Selection ---
              _buildSectionHeader(
                "Academic Semester",
                Icons.auto_awesome_mosaic_rounded,
              ),
              _buildCustomDropdown(
                hint: "Choose Semester",
                value: selectedSemester,
                items: semesters,
                onChanged: (val) => setState(() => selectedSemester = val),
                icon: Icons.school_rounded,
              ),

              const SizedBox(height: 25),

              // --- Subject Selection ---
              _buildSectionHeader("Course Subject", Icons.menu_book_rounded),
              _buildCustomDropdown(
                hint: "Choose Subject",
                value: selectedSubject,
                items: subjects,
                onChanged: (val) => setState(() => selectedSubject = val),
                icon: Icons.subject_rounded,
              ),

              const SizedBox(height: 25),

              _buildSectionHeader("Time Period", Icons.calendar_today_rounded),
              _buildDateTile(),

              const SizedBox(height: 50),

              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorPallet.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String hint,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: ColorPallet.primaryBlue.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        items: items
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s, style: const TextStyle(fontSize: 15)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget _buildDateTile() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TimeframeScreen()),
        );
        if (result != null && result is Map<String, DateTime?>) {
          setState(() {
            startDate = result['start'];
            endDate = result['end'];
          });
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: startDate == null
                ? Colors.transparent
                : ColorPallet.primaryBlue.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorPallet.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.date_range_rounded,
                color: ColorPallet.primaryBlue,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startDate == null ? "Select Date Range" : "Selected Period",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    startDate == null
                        ? "Not Selected"
                        : "${DateFormat('MMM d, y').format(startDate!)} - ${DateFormat('MMM d, y').format(endDate!)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    bool isReady =
        selectedSemester != null &&
        selectedSubject != null &&
        startDate != null;
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isReady
            ? LinearGradient(
                colors: [ColorPallet.primaryBlue, const Color(0xFF6A85E6)],
              )
            : const LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
        boxShadow: isReady
            ? [
                BoxShadow(
                  color: ColorPallet.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: isReady
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceReportScreen(
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  ),
                );
              }
            : null,
        child: const Text(
          "Generate Report",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
