import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:facialtrackapp/view/student/Dashboard/monthly_attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubjectSessionsHistoryScreen extends StatelessWidget {
  final SubjectAttendanceData subject;

  const SubjectSessionsHistoryScreen({super.key, required this.subject});

  static DateTime? _sortInstant(StudentAttendanceSessionRecord r) =>
      r.sessionStartTimeUtc ?? r.sessionDateUtc;

  static String _dateLabel(StudentAttendanceSessionRecord r) {
    final t = _sortInstant(r);
    if (t == null) return '—';
    return DateFormat('MMM d, EEE').format(reportUtcToPktWallForDisplay(t));
  }

  static String _timeLabel(StudentAttendanceSessionRecord r) {
    final range = formatPktEntryExitRange(r.entryTimeUtc, r.exitTimeUtc);
    if (range != '---- - ----') return range;
    final start = r.sessionStartTimeUtc ?? r.sessionDateUtc;
    return start != null ? formatPktTime12h(start) : '—';
  }

  @override
  Widget build(BuildContext context) {
    final sessions = List<StudentAttendanceSessionRecord>.from(
      subject.monthSessions,
    );
    sessions.sort((a, b) {
      final ta = _sortInstant(a) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final tb = _sortInstant(b) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      return tb.compareTo(ta);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF2304AA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${subject.title} Sessions",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: subject.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        subject.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${subject.percentage.toInt()}% Attendance",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${subject.present} Present • ${subject.absent} Absent • ${subject.leave} Leave",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: sessions.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No sessions for this subject in the selected month.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final status =
                              session.isPresent ? 'Present' : 'Absent';
                          Color statusColor;
                          if (status == 'Present') {
                            statusColor = const Color(0xFF10B981);
                          } else {
                            statusColor = const Color(0xFFEF4444);
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        session.isPresent
                                            ? Icons.check
                                            : Icons.close,
                                        color: statusColor,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _dateLabel(session),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _timeLabel(session),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
