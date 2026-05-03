import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_report_provider.dart';
import 'package:facialtrackapp/core/models/report_models.dart';
import 'package:facialtrackapp/services/teacher_report_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentPercentageScreen extends StatelessWidget {
  final CourseReportStudent student;
  final int courseTotalSessions;
  final DateTime? startDate;
  final DateTime? endDate;

  const StudentPercentageScreen({
    super.key,
    required this.student,
    required this.courseTotalSessions,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = student.attendancePercentage.clamp(0, 100) / 100;
    final absent = student.totalSessions - student.sessionsAttended;
    final range = '${startDate != null ? DateFormat('dd MMM').format(startDate!) : '-'}'
        ' - ${endDate != null ? DateFormat('dd MMM').format(endDate!) : '-'}';
    final courseName =
        context.watch<TeacherReportProvider>().courseReport?.courseName;

    Future<void> exportPdf() async {
      try {
        await TeacherReportPdfService.layoutStudentAttendanceSummaryPdf(
          student: student,
          courseTotalSessions: courseTotalSessions,
          rangeLabel: range,
          courseName: courseName,
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e')),
        );
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: Text('${student.studentName} Report'),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export PDF',
              onPressed: exportPdf,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 15,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.grey[200],
                      color: ColorPallet.primaryBlue,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${student.attendancePercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const Text(
                        'Attendance Rate',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  _statCard('Total Classes', '${student.totalSessions}', Colors.blue),
                  const SizedBox(width: 12),
                  _statCard('Present', '${student.sessionsAttended}', Colors.green),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statCard('Absent', '$absent', Colors.redAccent),
                  const SizedBox(width: 12),
                  _statCard('Late', '${student.lateCount}', Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
