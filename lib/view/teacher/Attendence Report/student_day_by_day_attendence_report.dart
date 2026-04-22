import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/core/models/report_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayByDayReportScreen extends StatelessWidget {
  final CourseReportStudent student;
  final int courseTotalSessions;
  final DateTime? startDate;
  final DateTime? endDate;

  const DayByDayReportScreen({
    super.key,
    required this.student,
    required this.courseTotalSessions,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final absent = student.totalSessions - student.sessionsAttended;
    final range = '${startDate != null ? DateFormat('dd MMM').format(startDate!) : '-'}'
        ' - ${endDate != null ? DateFormat('dd MMM').format(endDate!) : '-'}';
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F7FF),
        appBar: AppBar(
          title: Text('${student.studentName} History'),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Logs: $range',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student.studentName} (${student.rollNumber})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _line('Present', student.sessionsAttended.toString()),
                    _line('Absent', absent.toString()),
                    _line('Total Classes', student.totalSessions.toString()),
                    _line(
                      'Attendance %',
                      '${student.attendancePercentage.toStringAsFixed(2)}%',
                    ),
                    _line('Late Count', student.lateCount.toString()),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Per-day logs endpoint is not available yet. '
                  'This screen currently shows backend-provided student summary for the selected range.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
