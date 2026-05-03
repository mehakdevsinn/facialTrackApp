import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_report_provider.dart';
import 'package:facialtrackapp/core/models/report_models.dart';
import 'package:facialtrackapp/services/teacher_report_pdf_service.dart';
import 'package:facialtrackapp/view/teacher/Attendence%20Report/individual_student_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AttendanceReportScreen extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const AttendanceReportScreen({super.key, this.startDate, this.endDate});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherReportProvider>(
      builder: (context, report, _) {
        final data = report.courseReport;
        if (data == null) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Analytics Report'),
                backgroundColor: ColorPallet.primaryBlue,
                foregroundColor: Colors.white,
              ),
              body: const Center(child: Text('No report data available.')),
            ),
          );
        }

        final rangeLabel = _rangeText();
        final sem = report.selectedCourse?.semester;
        final semesterPdfLabel =
            sem == null ? null : 'Semester ${sem.semesterNumber}';

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: ColorPallet.primaryBlue,
              title: const Text('Analytics Report'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Export PDF',
                  onPressed: () async {
                    try {
                      await TeacherReportPdfService.layoutCourseReportPdf(
                        data: data,
                        dateRangeLabel: rangeLabel,
                        semesterLabel: semesterPdfLabel,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PDF export failed: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Overall Class Attendance',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _rangeText(),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _summaryCard(data),
                  const SizedBox(height: 25),
                  const Text(
                    'Student Performance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  ...data.students.map(
                    (student) => _studentCard(context, student, data.totalSessions),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(CourseReportResponse data) {
    final pct = data.courseAveragePercentage;
    final presentSum = data.students.fold<int>(
      0,
      (sum, s) => sum + s.sessionsAttended,
    );
    final totalSum = data.students.fold<int>(
      0,
      (sum, s) => sum + s.totalSessions,
    );
    final absentSum = totalSum - presentSum;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            data.courseName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metric('Sessions', data.totalSessions.toString(), Colors.indigo),
              _metric(
                  'Attendance', '${pct.toStringAsFixed(1)}%', Colors.blueAccent),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metric('Present', presentSum.toString(), Colors.green),
              _metric('Absent', absentSum.toString(), Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _studentCard(
    BuildContext context,
    CourseReportStudent student,
    int courseTotalSessions,
  ) {
    final threshold =
        context.read<TeacherReportProvider>().attendanceThreshold.toDouble();
    final isLow = student.attendancePercentage < threshold;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDetailOptionsScreen(
              student: student,
              courseTotalSessions: courseTotalSessions,
              startDate: startDate,
              endDate: endDate,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.indigo.withOpacity(0.08),
              child: Text(
                student.studentName.isEmpty ? '?' : student.studentName[0],
                style: const TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    student.rollNumber,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${student.attendancePercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: isLow ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rangeText() {
    if (startDate != null && endDate != null) {
      final start = DateFormat('dd MMM, yyyy').format(startDate!);
      final end = DateFormat('dd MMM, yyyy').format(endDate!);
      return '$start - $end';
    }
    return 'Full Academic Session';
  }
}
