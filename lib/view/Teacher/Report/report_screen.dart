import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20report%20screen%20widget/attendence_summary_card_widget.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20report%20screen%20widget/monthly_trend_chart_widget.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20report%20screen%20widget/performance_list_card_widget.dart';
import 'package:facialtrackapp/widgets/teacher%20side%20report%20screen%20widget/report_dropdown_widget.dart';
import 'package:flutter/material.dart';

class AttendanceReport extends StatefulWidget {
  final bool showBackButton;
  const AttendanceReport({super.key, this.showBackButton = false});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  final Color primaryDark = const Color(0xFF1A4B8F);

  final Color accentTeal = const Color(0xFF26A69A);

  final Color accentOrange = const Color(0xFFFF8A65);
  bool showOnlyLow = false;
  String selectedMonth = "October 2025";

  String selectedSubject = "Computer Science";

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

  // Expanded List of Subjects
  final List<String> subjects = [
    "Computer Science",
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "English Literature",
    "History",
    "Geography",
    "Economics",
    "Business Studies",
    "Art & Design",
    "Physical Education",
  ];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Agar dashboard se aaye hain toh pop hona chahiye (true)
      // Agar bottom nav se aaye hain toh pop nahi hona chahiye (false)
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
            title: const Text(
              'Monthly Report',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            centerTitle: true,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ReportDropdowns(
                  selectedMonth: selectedMonth,
                  selectedSubject: selectedSubject,
                  months: months,
                  subjects: subjects,
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
