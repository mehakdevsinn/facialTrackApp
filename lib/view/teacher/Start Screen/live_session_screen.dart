import 'dart:async';

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/session_provider.dart';
import 'package:facialtrackapp/core/models/roster_student_model.dart';
import 'package:facialtrackapp/core/utils/attendance_display.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/view_log_screen.dart';
import 'package:facialtrackapp/view/teacher/Teacher_NavBar/teacher_root_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LiveSessionScreen extends StatefulWidget {
  final String sessionId;

  const LiveSessionScreen({super.key, required this.sessionId});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  Timer? _clockTimer;
  String _currentTime = '';
  Duration _elapsed = Duration.zero;
  DateTime? _sessionStart;
  bool _isSessionRunning = true;

  static const _primaryBlue = Color.fromARGB(255, 35, 4, 170);
  static const _orangeTheme = Color(0xFFFF7043);
  static const _greenColor = Color(0xFF34A853);

  @override
  void initState() {
    super.initState();
    final provider = context.read<SessionProvider>();
    _sessionStart =
        provider.currentSession?.elapsedBaselineUtc ?? DateTime.now();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateClock();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<SessionProvider>();
      // Load roster + first attendance snapshot in parallel.
      await Future.wait([p.loadRoster(), p.loadAttendance()]);
      // Start polling every 10 s.
      p.startPolling();
      // Sync baseline if session object was refreshed (e.g. created_at now present).
      final s = p.currentSession;
      final baseline = s?.elapsedBaselineUtc;
      if (baseline != null) {
        setState(() => _sessionStart = baseline);
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    final h = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    if (_sessionStart != null) {
      var diff = now.difference(_sessionStart!);
      if (diff.isNegative) diff = Duration.zero;
      _elapsed = diff;
    }
    setState(() {
      _currentTime = '$h:$mm:$ss $amPm';
    });
  }

  String _fmt(Duration d) {
    var x = d.isNegative ? Duration.zero : d;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(x.inHours)}:${two(x.inMinutes.remainder(60))}:${two(x.inSeconds.remainder(60))}';
  }

  Future<void> _handleEndSession() async {
    final provider = context.read<SessionProvider>();
    final stopped = await provider.endSession();
    if (!mounted) return;
    if (stopped != null) {
      setState(() => _isSessionRunning = false);
      await provider.refreshActiveSessions();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceLogsScreen(sessionId: widget.sessionId),
        ),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
      provider.clearError();
    }
  }

  Future<void> _showMarkLeaveDialog(
    BuildContext dialogContext,
    SessionProvider provider,
    String studentId,
    String studentName,
  ) async {
    final controller = TextEditingController();
    String? reason;
    try {
      reason = await showDialog<String>(
        context: dialogContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Mark on leave'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(studentName,
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
      final c = controller;
      WidgetsBinding.instance.addPostFrameCallback((_) => c.dispose());
    }
    if (reason == null || !mounted) return;
    provider.clearError();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.markStudentOnLeave(studentId, reason);
    if (!mounted) return;
    if (!ok && provider.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
      provider.clearError();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        final course = provider.selectedCourse;
        final roster = provider.rosterStudents;
        final present = provider.presentStudentIds;
        final onLeave = provider.onLeaveStudentIds;
        final totalCount = roster.length;
        final presentCount = present.length;
        final onLeaveCount = onLeave.length;
        final absentUnexcused =
            (totalCount - presentCount - onLeaveCount).clamp(0, totalCount);
        final pct = totalCount > 0
            ? (presentCount / totalCount * 100).round()
            : 0;

        return SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F7FA),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              titleSpacing: 0,
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      provider.stopPolling();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TeacherRootScreen()),
                        (r) => false,
                      );
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Live Session Status',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _isSessionRunning ? _orangeTheme : Colors.grey,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: _isSessionRunning
                        ? [
                            BoxShadow(
                              color: _orangeTheme.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _currentTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Body ────────────────────────────────────────────────────────
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Class info card ────────────────────────────────────────
                  _buildClassInfoCard(
                    course?.name ?? 'Loading…',
                    course?.semester != null
                        ? 'Semester ${course!.semester!.semesterNumber}'
                        : '',
                    presentCount,
                    onLeaveCount,
                    absentUnexcused,
                    totalCount,
                    pct,
                  ),
                  const SizedBox(height: 25),

                  // ── Students grid (tap to mark present) ───────────────────
                  _buildStudentsGrid(roster, provider),
                  const SizedBox(height: 25),

                  // ── Stat cards ─────────────────────────────────────────────
                  Row(
                    children: [
                      _buildStatCard(
                        'Attendance',
                        '$pct%',
                        Icons.pie_chart,
                        Colors.teal,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Present',
                        '$presentCount',
                        Icons.check_circle_outline,
                        _primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Duration',
                        _fmt(_elapsed),
                        Icons.timer,
                        _orangeTheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // ── End session ────────────────────────────────────────────
                  ElevatedButton(
                    onPressed: _isSessionRunning && !provider.isLoading
                        ? _handleEndSession
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallet.orange,
                      disabledBackgroundColor: Colors.grey,
                      minimumSize: const Size(double.infinity, 54),
                      shape: const StadiumBorder(),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            _isSessionRunning
                                ? 'End Session'
                                : 'Session Ended',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This will finalize attendance',
                    style: TextStyle(
                      color: _isSessionRunning ? _orangeTheme : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Class Info Card ────────────────────────────────────────────────────────
  Widget _buildClassInfoCard(
    String courseName,
    String semesterLabel,
    int presentCount,
    int onLeaveCount,
    int absentUnexcused,
    int totalCount,
    int pct,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _greenColor, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            semesterLabel.isNotEmpty ? '$semesterLabel — $courseName' : courseName,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2671),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: Colors.orange, size: 10),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: _greenColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '— $presentCount present, $onLeaveCount on leave, '
                  '$absentUnexcused absent (unexcused) / $totalCount',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? presentCount / totalCount : 0,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(_orangeTheme),
            ),
          ),
        ],
      ),
    );
  }

  // ── Students Grid ──────────────────────────────────────────────────────────
  Widget _buildStudentsGrid(
    List<RosterStudentModel> roster,
    SessionProvider provider,
  ) {
    if (roster.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text('No students in this course.',
              style: TextStyle(color: Colors.black54)),
        ),
      );
    }

    final presentCount = provider.presentStudentIds.length;
    final total = roster.length;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 18,
              crossAxisSpacing: 15,
            ),
            itemCount: roster.length,
            itemBuilder: (_, i) {
              final student = roster[i];
              final isPending = provider.isPending(student.id);
              return _buildStudentAvatar(student, isPending, provider);
            },
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _greenColor, width: 2),
                ),
                child: Text(
                  '$presentCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ $total students present',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAvatar(
    RosterStudentModel student,
    bool isPending,
    SessionProvider provider,
  ) {
    final rec = provider.recordForStudent(student.id);
    final isPresent = rec?.isPresent == true;
    final isOnLeave = rec?.onLeave == true;
    final vis = sessionRowVisualState(
      isPresent: isPresent,
      onLeave: isOnLeave,
    );
    final bg = sessionAttendanceStatusColor(vis);
    final canMarkLeave = !isPresent && !isOnLeave;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: isPending
              ? null
              : () async {
                  if (!isPresent) {
                    await provider.markPresent(student.id);
                  }
                },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bg.withOpacity(0.25),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isPending
                ? const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundColor: bg,
                    child: Text(
                      student.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        if (!isPending)
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: Colors.white,
              child: Icon(
                isPresent
                    ? Icons.check_circle
                    : isOnLeave
                        ? Icons.flight_takeoff
                        : Icons.touch_app,
                color: bg,
                size: 16,
              ),
            ),
          ),
        if (!isPending && canMarkLeave)
          Positioned(
            top: -4,
            right: -4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showMarkLeaveDialog(
                  context,
                  provider,
                  student.id,
                  student.fullName,
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.event_note,
                    size: 14,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Stat Card ─────────────────────────────────────────────────────────────
  Widget _buildStatCard(
      String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: TextStyle(
                fontSize: 12,
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
