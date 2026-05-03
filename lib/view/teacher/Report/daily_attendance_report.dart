import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_report_provider.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:facialtrackapp/services/teacher_report_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DailyAttendanceReportScreen extends StatelessWidget {
  const DailyAttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherReportProvider>(
      builder: (context, report, _) {
        final data = report.dailyReport;
        if (data == null) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Day Inspection'),
                backgroundColor: ColorPallet.primaryBlue,
                foregroundColor: Colors.white,
              ),
              body: const Center(
                child: Text('No daily report loaded.'),
              ),
            ),
          );
        }

        final u = parseReportToUtcInstant(data.reportDate);
        final titleDate = u == null
            ? data.reportDate
            : DateFormat('EEEE, dd MMMM yyyy')
                .format(reportUtcToPktWallForDisplay(u));

        final sem = report.selectedCourse?.semester;
        final semesterPdfLabel =
            sem == null ? null : 'Semester ${sem.semesterNumber}';

        Future<void> exportPdf() async {
          try {
            await TeacherReportPdfService.layoutDailyRollCallPdf(
              data: data,
              titleDateLine: titleDate,
              semesterLabel: semesterPdfLabel,
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
            backgroundColor: const Color(0xFFF8F9FE),
            appBar: AppBar(
              title: const Text(
                'Day Inspection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
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
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 26),
                  decoration: const BoxDecoration(
                    color: ColorPallet.primaryBlue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        titleDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.courseName,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      if (sem != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Semester ${sem.semesterNumber}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statItem('Total', data.totalEnrolled.toString()),
                          _statItem('Present', data.presentCount.toString()),
                          _statItem('Absent', data.absentCount.toString()),
                          _statItem(
                            'Attendance',
                            '${data.attendancePercentage.toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Student Roll Call',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.students.length,
                    itemBuilder: (_, index) {
                      final s = data.students[index];
                      final present = s.isPresent;
                      final color = present ? Colors.green : Colors.red;
                      final status = present ? 'Present' : 'Absent';
                      final inTime = s.markedAt == null || s.markedAt!.isEmpty
                          ? '-'
                          : _formatTime(s.markedAt!);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: color.withOpacity(0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.studentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.rollNumber,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'In Time: $inTime',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Method: ${s.verificationMethod ?? '-'}',
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatTime(String iso) => formatPktTimeLineFromApiString(iso);
}
