import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20report%20screen%20widget/attendence_summary_card_widget.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20report%20screen%20widget/monthly_trend_chart_widget.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20report%20screen%20widget/performance_list_card_widget.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20report%20screen%20widget/report_dropdown_widget.dart';
import 'package:flutter/material.dart';

class MonthlyAttendanceReport extends StatefulWidget {
  final bool showBackButton;
  const MonthlyAttendanceReport({super.key, this.showBackButton = false});

  @override
  State<MonthlyAttendanceReport> createState() =>
      _MonthlyAttendanceReportState();
}

class _MonthlyAttendanceReportState extends State<MonthlyAttendanceReport> {
  final Color primaryDark = const Color(0xFF1A4B8F);

  final Color accentTeal = const Color(0xFF26A69A);

  final Color accentOrange = const Color(0xFFFF8A65);
  bool showOnlyLow = false;
  String selectedSemester = "Semester 2";
  String selectedMonth = "October 2025";
  String selectedSubject = "Computer Science";

  // Even Semesters
  final List<String> semesters = [
    "Semester 2",
    "Semester 4",
    "Semester 6",
    "Semester 8",
  ];

  // Full list of 12 Months
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

  // Subjects for the teacher
  final List<String> subjects = [
    "Computer Science",
    "Software Engineering",
    "Information Technology",
    "Artificial Intelligence",
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.showBackButton,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            foregroundColor: ColorPallet.white,
            automaticallyImplyLeading: false,
            backgroundColor: ColorPallet.primaryBlue,
            leading: widget.showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: Column(
              children: [
                const Text(
                  'Monthly Report',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  "$selectedSubject • $selectedSemester",
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ReportDropdowns(
                  selectedSemester: selectedSemester,
                  selectedMonth: selectedMonth,
                  selectedSubject: selectedSubject,
                  semesters: semesters,
                  months: months,
                  subjects: subjects,
                  onSemesterChanged: (val) =>
                      setState(() => selectedSemester = val!),
                  onMonthChanged: (val) => setState(() => selectedMonth = val!),
                  onSubjectChanged: (val) =>
                      setState(() => selectedSubject = val!),
                ),
                const SizedBox(height: 16),
                AttendanceSummaryCard(
                  showOnlyLow: showOnlyLow,
                  onToggleLow: () => setState(() => showOnlyLow = !showOnlyLow),
                ),
                const SizedBox(height: 16),
                PerformanceListCard(
                  showOnlyLow: showOnlyLow,
                  selectedSemester: selectedSemester,
                  selectedMonth: selectedMonth,
                  selectedSubject: selectedSubject,
                ),
                const SizedBox(height: 16),
                MonthlyTrendChart(showOnlyLow: showOnlyLow),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
