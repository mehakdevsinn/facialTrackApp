import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/core/utils/attendance_display.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:flutter/material.dart';

/// Session detail from `GET /reports/students/sessions/{session_id}`.
class AttendanceDetailScreen extends StatefulWidget {
  final String sessionId;

  const AttendanceDetailScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  bool _loading = true;
  String? _error;
  StudentAttendanceSessionRecord? _record;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await ApiManager.instance.getStudentSessionDetail(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _record = r;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _record = null;
        _error = 'Session unavailable.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: ColorPallet.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ColorPallet.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Attendance Detail',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
              OutlinedButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final r = _record!;
    final sessionDate = r.sessionDateUtc;
    final dateStr = sessionDate != null ? formatPktDateCard(sessionDate) : '—';
    final dayStr = sessionDate != null ? formatPktDayName(sessionDate) : '';
    final vis = sessionRowVisualState(
      isPresent: r.isPresent,
      onLeave: r.isOnLeave,
    );
    final statusColor = sessionAttendanceStatusColor(vis);
    final statusTitle = vis == SessionAttendanceVisualState.absentUnexcused
        ? 'Absent (unexcused)'
        : sessionAttendanceStatusLabel(vis);
    final statusSubtitle = switch (vis) {
      SessionAttendanceVisualState.present => 'Status verified',
      SessionAttendanceVisualState.onLeave => 'Excused leave',
      SessionAttendanceVisualState.absentUnexcused => 'Status not verified',
    };
    final statusIcon = switch (vis) {
      SessionAttendanceVisualState.present => Icons.check_circle,
      SessionAttendanceVisualState.onLeave => Icons.event_note,
      SessionAttendanceVisualState.absentUnexcused => Icons.cancel,
    };
    final markedAtStr =
        r.entryTimeUtc != null ? formatPktTime12h(r.entryTimeUtc!) : '—';
    final sessionStartStr = r.sessionStartTimeUtc != null
        ? formatPktTime12h(r.sessionStartTimeUtc!)
        : '—';
    final exitStr =
        r.exitTimeUtc != null ? formatPktTime12h(r.exitTimeUtc!) : '—';
    final subject = r.courseName ?? '—';
    final verify = verificationMethodLabel(r.verificationMethod);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            dateStr,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          if (dayStr.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dayStr,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 8),
          if (verify != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Chip(
                label: Text(verify, style: const TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  statusIcon,
                  size: 40,
                  color: statusColor,
                ),
                const SizedBox(height: 8),
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusSubtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                if (vis == SessionAttendanceVisualState.onLeave &&
                    r.leaveReason != null &&
                    r.leaveReason!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Reason: ${r.leaveReason!.trim()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.indigo.shade800,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (r.isPresent) ...[
            _timeLogsCard(markedAtStr),
            const SizedBox(height: 16),
          ],
          _sessionInfoCard(
            subject: subject,
            sessionStartDisplay: sessionStartStr,
            exitDisplay: exitStr,
          ),
        ],
      ),
    );
  }

  /// System marking time only (`entry_time`).
  Widget _timeLogsCard(String entryTimeDisplay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TIME LOGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.fingerprint, 'Entry time', entryTimeDisplay),
        ],
      ),
    );
  }

  Widget _sessionInfoCard({
    required String subject,
    required String sessionStartDisplay,
    required String exitDisplay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SESSION INFO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.book, 'Subject', subject),
          const SizedBox(height: 8),
          _infoRow(
            Icons.schedule,
            'Session',
            '$sessionStartDisplay - $exitDisplay',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, [String? value]) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ${value ?? ''}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(2, 2),
        ),
      ],
    );
  }
}
