import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/session_provider.dart';
import 'package:facialtrackapp/core/models/attendance_record_model.dart';
import 'package:facialtrackapp/core/models/roster_student_model.dart';
import 'package:facialtrackapp/utils/widgets/export_pdf.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AttendanceLogsScreen extends StatefulWidget {
  final String sessionId;

  const AttendanceLogsScreen({super.key, required this.sessionId});

  @override
  State<AttendanceLogsScreen> createState() => _AttendanceLogsScreenState();
}

class _AttendanceLogsScreenState extends State<AttendanceLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure attendance is loaded (may already be if coming from Live Session).
      context
          .read<SessionProvider>()
          .ensureAttendanceLoaded(widget.sessionId);
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
        final presentIds = provider.presentStudentIds;

        // Combine roster + attendance into a merged list.
        final mergedStudents = _buildMergedList(roster, records, presentIds);

        final displayDate = session?.startDateTime != null
            ? DateFormat('MMMM d, y').format(session!.startDateTime!.toLocal())
            : DateFormat('MMMM d, y').format(DateTime.now());
        final rawDate = session?.startDateTime != null
            ? DateFormat('yyyy-MM-dd')
                .format(session!.startDateTime!.toLocal())
            : DateFormat('yyyy-MM-dd').format(DateTime.now());

        final totalCount = roster.length;
        final presentCount = presentIds.length;
        final absentCount = totalCount - presentCount;

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
                      Row(
                        children: [
                          const Text('Total: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            '$totalCount',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 15),
                          const Text('Present: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            '$presentCount',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 15),
                          const Text('Absent: ',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            '$absentCount',
                            style: const TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$displayDate · $courseLabel',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
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
                    context, displayDate, rawDate, mergedStudents),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Merge roster (full list) with attendance records into display rows.
  List<_StudentRow> _buildMergedList(
    List<RosterStudentModel> roster,
    List<AttendanceRecordModel> records,
    Set<String> presentIds,
  ) {
    final recordMap = {for (final r in records) r.studentId: r};
    return roster.map((s) {
      final rec = recordMap[s.id];
      final isPresent = presentIds.contains(s.id);
      return _StudentRow(
        studentId: s.id,
        name: s.fullName,
        rollNumber: s.rollNumber,
        isPresent: isPresent,
        markedAt: rec?.markedAt,
        method: rec?.method,
      );
    }).toList();
  }

  Widget _buildStudentCard(_StudentRow row, SessionProvider provider) {
    final isPending = provider.isPending(row.studentId);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor:
                  row.isPresent ? Colors.green : Colors.orange,
              child: Text(
                _initials(row.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (row.rollNumber != null)
                    Text(
                      row.rollNumber!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  if (row.markedAt != null)
                    Text(
                      _formatMarkedAt(row.markedAt!),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(row.isPresent ? 'Present' : 'Absent'),
                const SizedBox(height: 8),
                isPending
                    ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Transform.scale(
                        scale: 0.8,
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPresent = status == 'Present';
    final mainColor = isPresent
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF7043);
    final bgColor = isPresent
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFBE9E7);
    final icon = isPresent ? Icons.check_box : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: mainColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: mainColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
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
  ) {
    // Convert to the legacy Map format expected by exportToPDF.
    final legacyList = rows
        .map((r) => {
              'name': r.name,
              'status': r.isPresent ? 'Present' : 'Absent',
              'time': r.markedAt != null
                  ? _formatMarkedAt(r.markedAt!)
                  : '--',
            })
        .toList();

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
            onPressed: () => exportToPDF(displayDate, rawDate, legacyList),
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

  String _formatMarkedAt(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

// ── Simple row model for display ──────────────────────────────────────────────
class _StudentRow {
  final String studentId;
  final String name;
  final String? rollNumber;
  final bool isPresent;
  final String? markedAt;
  final String? method;

  const _StudentRow({
    required this.studentId,
    required this.name,
    this.rollNumber,
    required this.isPresent,
    this.markedAt,
    this.method,
  });
}
