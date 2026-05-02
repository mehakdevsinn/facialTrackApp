import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:facialtrackapp/view/student/Attendence%20History/attendence-detail-screen.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// [courseId] null or empty: legacy dashboard demo (static recent sessions, not linked to API).
/// Non-empty: loads `GET .../subjects/{course_id}` and shows [recentSessions].
class SubjectDetailScreen extends StatefulWidget {
  final String? courseId;
  final String subject;
  final String teacher;
  final int attendance;
  final int presentDays;
  final int absentDays;
  final Color color;

  const SubjectDetailScreen({
    super.key,
    this.courseId,
    required this.subject,
    required this.teacher,
    required this.attendance,
    required this.presentDays,
    required this.absentDays,
    required this.color,
  });

  bool get _useApi => courseId != null && courseId!.trim().isNotEmpty;

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  bool _loading = false;
  String? _error;
  StudentSubjectDetailResponse? _detail;

  @override
  void initState() {
    super.initState();
    if (widget._useApi) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await ApiManager.instance
          .getStudentSubjectDetail(widget.courseId!.trim());
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detail = null;
        _error = 'Subject unavailable.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?.courseName ?? widget.subject;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: ColorPallet.primaryBlue,
          elevation: 0,
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              '$title Detail'.replaceAll('\n', ' ').replaceAll('\r', ''),
              style: const TextStyle(fontSize: 18, color: ColorPallet.white),
              maxLines: 1,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ColorPallet.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body:
            widget._useApi ? _buildApiBody(context) : _buildLegacyBody(context),
      ),
    );
  }

  Widget _buildApiBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final d = _detail!;
    final pct = (d.attendancePercentage / 100).clamp(0.0, 1.0).toDouble();
    final color = widget.color;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 45,
                  lineWidth: 7,
                  percent: pct,
                  center: Text(
                    '${d.attendancePercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: color,
                  backgroundColor: color.withOpacity(0.2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          'Teacher: ${d.teacherName}'
                              .replaceAll('\n', ' ')
                              .replaceAll('\r', ''),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Code: ${d.courseCode} · Sessions: ${d.totalSessions} '
                        '(present ${d.sessionsAttended}, absent ${d.sessionsAbsent})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _recentSessionsCard(context, d.recentSessions),
        ],
      ),
    );
  }

  Widget _buildLegacyBody(BuildContext context) {
    final color = widget.color;
    final attendance = widget.attendance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 45,
                  lineWidth: 7,
                  percent: (attendance / 100).clamp(0.0, 1.0).toDouble(),
                  center: Text(
                    '$attendance%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: color,
                  backgroundColor: color.withOpacity(0.2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          'Teacher: ${widget.teacher}'
                              .replaceAll('\n', ' ')
                              .replaceAll('\r', ''),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This is your calculated attendance rate based on all recorded sessions for ${widget.subject}.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 7),
                const Text(
                  'Recent Sessions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Demo preview only. Open a subject from My Subjects for live sessions.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                _legacySessionTile(
                  dateLabel: 'Oct 25, 2025',
                  status: 'Present',
                  statusColor: Colors.green,
                  time: '09:20 AM - 10:30 AM',
                ),
                _legacySessionTile(
                  dateLabel: 'Oct 23, 2025',
                  status: 'Absent',
                  statusColor: Colors.red,
                  time: '---- - 10:28 AM',
                ),
                _legacySessionTile(
                  dateLabel: 'Oct 21, 2025',
                  status: 'Present',
                  statusColor: Colors.orange,
                  time: '09:15 AM - 10:30 AM',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentSessionsCard(
    BuildContext context,
    List<StudentAttendanceSessionRecord> sessions,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 7),
          const Text(
            'Recent Sessions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            Text(
              'No recent sessions.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            )
          else
            ...sessions.asMap().entries.map((e) {
              final r = e.value;
              final last = e.key == sessions.length - 1;
              return _apiSessionTile(context, r, isLast: last);
            }),
        ],
      ),
    );
  }

  Widget _apiSessionTile(
    BuildContext context,
    StudentAttendanceSessionRecord r, {
    required bool isLast,
  }) {
    final u = r.sessionDateUtc;
    final dateLabel = u != null ? formatPktDateCard(u) : '—';
    final status = r.isPresent ? 'Present' : 'Absent';
    final statusColor = r.isPresent ? Colors.green : Colors.red;
    // Scheduled slot (timetable window) — not the system "marked at" time (see session detail).
    final classTime =
        formatPktEntryExitRange(r.sessionStartTimeUtc, r.exitTimeUtc);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: r.sessionId.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceDetailScreen(
                          sessionId: r.sessionId,
                        ),
                      ),
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Class: $classTime',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) const Divider(height: 24),
      ],
    );
  }

  Widget _legacySessionTile({
    required String dateLabel,
    required String status,
    required Color statusColor,
    required String time,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) const Divider(height: 24),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 2,
          offset: const Offset(4, 4),
        ),
      ],
    );
  }
}
