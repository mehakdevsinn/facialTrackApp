import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/session_provider.dart';
import 'package:facialtrackapp/core/models/attendance_record_model.dart';
import 'package:facialtrackapp/core/models/roster_student_model.dart';
import 'package:facialtrackapp/core/models/session_model.dart';
import 'package:facialtrackapp/core/models/teacher_course_model.dart';
import 'package:facialtrackapp/core/utils/attendance_display.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:facialtrackapp/core/utils/teacher_session_display.dart';
import 'package:facialtrackapp/utils/widgets/export_pdf.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceLogsScreen extends StatefulWidget {
  final String sessionId;

  const AttendanceLogsScreen({super.key, required this.sessionId});

  @override
  State<AttendanceLogsScreen> createState() => _AttendanceLogsScreenState();
}

class _AttendanceLogsScreenState extends State<AttendanceLogsScreen> {
  String _pdfStatusLine(_StudentRow r) {
    if (r.isPresent) return 'Present';
    if (r.isOnLeave) {
      final reason = (r.leaveReason ?? '').trim();
      if (reason.isEmpty) return 'On leave';
      final short =
          reason.length > 80 ? '${reason.substring(0, 77)}...' : reason;
      return 'On leave — $short';
    }
    return 'Absent (unexcused)';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<SessionProvider>();
      await p.refreshActiveSessions();
      if (!mounted) return;
      await p.ensureAttendanceLoaded(widget.sessionId);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        final session = provider.currentSession;
        final course = provider.selectedCourse;
        final roster = provider.rosterStudents;
        final records = provider.attendanceRecords;

        // Combine roster + attendance; if roster empty (cold open), use records.
        final mergedStudents = _buildMergedList(roster, records);

        final displayDate = session?.startDateTime != null
            ? formatTeacherSessionDatePkt(session!.startDateTime)
            : formatTeacherSessionDatePkt(DateTime.now().toUtc());
        final rawDate = session?.startDateTime != null
            ? formatTeacherSessionDateIsoPkt(session!.startDateTime)
            : formatTeacherSessionDateIsoPkt(DateTime.now().toUtc());
        final sessionWindowPkt = session != null
            ? formatTeacherSessionWindowPkt(
                session.startDateTime, session.endDateTime)
            : '';

        final totalCount = mergedStudents.length;
        final presentCount =
            mergedStudents.where((r) => r.isPresent).length;
        final onLeaveCount =
            mergedStudents.where((r) => r.isOnLeave).length;
        final absentUnexcused =
            mergedStudents.where((r) => !r.isPresent && !r.isOnLeave).length;

        final courseLabel = course != null
            ? '${course.name} — ${course.semester != null ? "Semester ${course.semester!.semesterNumber}" : ""}'
            : '';

        return SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FB),
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: ColorPallet.primaryBlue,
              title: const Text(
                "Today's Attendance Logs",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            body: Column(
              children: [
                // ── Summary card ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Session Summary",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (courseLabel.isNotEmpty)
                        Text(
                          courseLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D2671),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _summaryStat('Total', '$totalCount', Colors.green),
                          _summaryStat('Present', '$presentCount', Colors.orange),
                          _summaryStat(
                              'On leave', '$onLeaveCount', Colors.indigo),
                          _summaryStat(
                            'Absent (unexcused)',
                            '$absentUnexcused',
                            Colors.deepOrange,
                          ),
                        ],
                      ),
                      if (sessionWindowPkt.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          sessionWindowPkt,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        '$displayDate · $courseLabel',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),

                // ── Student list ─────────────────────────────────────────────
                provider.isLoading && mergedStudents.isEmpty
                    ? const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                    : Expanded(
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: mergedStudents.length,
                          itemBuilder: (_, i) =>
                              _buildStudentCard(mergedStudents[i], provider),
                        ),
                      ),

                // ── Bottom actions ───────────────────────────────────────────
                _buildBottomActions(
                  context,
                  displayDate,
                  rawDate,
                  mergedStudents,
                  session,
                  course,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _summaryStat(String label, String value, Color valueColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Merge roster (full list) with attendance records into display rows.
  /// When [roster] is empty (e.g. logs opened without prior [loadRoster]),
  /// builds one row per attendance record so the list still renders.
  List<_StudentRow> _buildMergedList(
    List<RosterStudentModel> roster,
    List<AttendanceRecordModel> records,
  ) {
    final recordMap = {for (final r in records) r.studentId: r};
    if (roster.isNotEmpty) {
      return roster.map((s) {
        final rec = recordMap[s.id];
        final isPresent = rec?.isPresent == true;
        final isOnLeave = rec?.onLeave == true;
        return _StudentRow(
          studentId: s.id,
          name: s.fullName,
          rollNumber: s.rollNumber,
          isPresent: isPresent,
          isOnLeave: isOnLeave,
          leaveReason: rec?.leaveReason,
          markedAt: rec?.markedAt,
          method: rec?.method,
        );
      }).toList();
    }
    final unique = <String, AttendanceRecordModel>{};
    for (final r in records) {
      unique[r.studentId] = r;
    }
    return unique.values.map((r) {
      final name = (r.studentName ?? '').trim();
      return _StudentRow(
        studentId: r.studentId,
        name: name.isEmpty ? 'Student' : name,
        rollNumber: r.studentRollNumber,
        isPresent: r.isPresent,
        isOnLeave: r.onLeave,
        leaveReason: r.leaveReason,
        markedAt: r.markedAt,
        method: r.method,
      );
    }).toList();
  }

  Widget _buildStudentCard(_StudentRow row, SessionProvider provider) {
    final isPending = provider.isPending(row.studentId);
    final vis = sessionRowVisualState(
      isPresent: row.isPresent,
      onLeave: row.isOnLeave,
    );
    final statusColor = sessionAttendanceStatusColor(vis);
    final canMarkLeave = !row.isPresent && !row.isOnLeave;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: statusColor.withOpacity(0.18),
                            foregroundColor: statusColor,
                            child: Text(
                              _initials(row.name),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                if (row.rollNumber != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Roll ${row.rollNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          _buildStatusBadge(vis),
                        ],
                      ),
                      if (row.isOnLeave &&
                          row.leaveReason != null &&
                          row.leaveReason!.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            row.leaveReason!.trim(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo.shade900,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                      if (row.markedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Marked ${_formatMarkedAt(row.markedAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const Divider(height: 22),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Present in class',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  row.isPresent
                                      ? 'Turn off to remove presence'
                                      : 'Turn on to mark present',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isPending)
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                            )
                          else
                            Transform.scale(
                              scale: 0.88,
                              alignment: Alignment.centerRight,
                              child: Switch(
                                value: row.isPresent,
                                onChanged: (val) async {
                                  if (val) {
                                    await provider.markPresent(row.studentId);
                                  } else {
                                    await provider.markAbsent(row.studentId);
                                  }
                                },
                                activeTrackColor: const Color(0xFF4CAF50),
                                inactiveTrackColor: const Color(0xFFFF7043),
                                activeColor: Colors.white,
                                inactiveThumbColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      if (canMarkLeave) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isPending
                                ? null
                                : () => _showMarkLeaveDialog(
                                    context, provider, row),
                            icon: Icon(
                              Icons.event_busy_outlined,
                              size: 18,
                              color: ColorPallet.primaryBlue,
                            ),
                            label: const Text('Mark on leave'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorPallet.primaryBlue,
                              side: BorderSide(
                                color:
                                    ColorPallet.primaryBlue.withOpacity(0.45),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _showMarkLeaveDialog(
    BuildContext dialogContext,
    SessionProvider provider,
    _StudentRow row,
  ) async {
    final controller = TextEditingController();
    String? submitted;
    try {
      submitted = await showDialog<String>(
        context: dialogContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Mark on leave'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Student: ${row.name}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Leave reason (min 3 characters)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final t = controller.text.trim();
                if (t.length < 3) return;
                Navigator.pop(ctx, t);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    } finally {
      // Let the dialog route detach the TextField before disposing the controller
      // (avoids "TextEditingController was used after being disposed").
      final c = controller;
      WidgetsBinding.instance.addPostFrameCallback((_) => c.dispose());
    }
    if (submitted == null || !mounted) return;
    provider.clearError();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.markStudentOnLeave(row.studentId, submitted);
    if (!mounted) return;
    if (!ok && provider.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
      provider.clearError();
    }
  }

  Widget _buildStatusBadge(SessionAttendanceVisualState vis) {
    final mainColor = sessionAttendanceStatusColor(vis);
    final bgColor = mainColor.withOpacity(0.12);
    final label = sessionAttendanceStatusLabel(vis);
    final icon = vis == SessionAttendanceVisualState.present
        ? Icons.check_box
        : vis == SessionAttendanceVisualState.onLeave
            ? Icons.flight_takeoff
            : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mainColor.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: mainColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: mainColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    String displayDate,
    String rawDate,
    List<_StudentRow> rows,
    SessionModel? session,
    TeacherCourseModel? course,
  ) {
    final pdfRows = rows
        .map(
          (r) => {
            'name': r.name,
            'status': _pdfStatusLine(r),
            'inTime':
                r.markedAt != null ? _formatMarkedAt(r.markedAt!) : '-',
            'method': verificationMethodLabel(r.method) ?? r.method ?? '-',
          },
        )
        .toList();

    Future<void> exportLogs() async {
      try {
        await exportSessionAttendanceLogsPdf(
          dateDisplay: displayDate,
          semesterNumber: course?.semester?.semesterNumber,
          subjectName: course?.name ?? '—',
          sessionStartPkt: session != null
              ? formatTeacherSessionTime12hPkt(session.startDateTime)
              : '',
          sessionEndPkt: session != null
              ? formatTeacherSessionTime12hPkt(session.endDateTime)
              : '',
          rows: pdfRows,
          fileNameDate: rawDate,
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e')),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPallet.primaryBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Attendance changes are saved automatically',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          OutlinedButton(
            onPressed: exportLogs,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Export Logs',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // ── Utilities ──────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatMarkedAt(String raw) => formatTeacherApiInstantTimePkt(raw);
}

// ── Simple row model for display ──────────────────────────────────────────────
class _StudentRow {
  final String studentId;
  final String name;
  final String? rollNumber;
  final bool isPresent;
  final bool isOnLeave;
  final String? leaveReason;
  final String? markedAt;
  final String? method;

  const _StudentRow({
    required this.studentId,
    required this.name,
    this.rollNumber,
    required this.isPresent,
    this.isOnLeave = false,
    this.leaveReason,
    this.markedAt,
    this.method,
  });
}
