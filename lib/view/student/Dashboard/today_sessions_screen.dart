import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionData {
  final String iconData;
  final Color iconBgColor;
  final String title;
  final String time;
  final String status;
  final String? attendanceText;
  final String? upcomingNotice;

  SessionData({
    required this.iconData,
    required this.iconBgColor,
    required this.title,
    required this.time,
    required this.status,
    this.attendanceText,
    this.upcomingNotice,
  });
}

class TodaySessionsScreen extends StatefulWidget {
  const TodaySessionsScreen({super.key});

  @override
  State<TodaySessionsScreen> createState() => _TodaySessionsScreenState();
}

class _TodaySessionsScreenState extends State<TodaySessionsScreen> {
  late DateTime _selectedDate;
  List<SessionData> _sessions = [];
  bool _loading = true;
  String? _error;

  static const List<Color> _palette = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFF059669),
    Color(0xFFEA580C),
    Color(0xFF0D9488),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadSessionsForDate(_selectedDate);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _courseCodeAbbrev(String? code, String name) {
    final c = (code ?? '').trim();
    if (c.length >= 2) return c.substring(0, 2).toUpperCase();
    final n = name.trim();
    if (n.length >= 2) return n.substring(0, 2).toUpperCase();
    return '••';
  }

  String _statusFor(
    StudentAttendanceSessionRecord r,
    DateTime dayLocal,
    DateTime now,
  ) {
    final dayStart = _dateOnly(dayLocal);
    final todayStart = _dateOnly(now);
    if (dayStart.isAfter(todayStart)) return 'Upcoming';
    if (dayStart.isBefore(todayStart)) {
      return r.isPresent ? 'Present' : 'Absent';
    }
    final start = r.sessionStartTimeUtc ?? r.sessionDateUtc;
    if (start != null && start.isAfter(now.toUtc())) {
      return 'Upcoming';
    }
    return r.isPresent ? 'Present' : 'Absent';
  }

  Future<void> _loadSessionsForDate(DateTime date) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final y = date.year;
    final m = date.month;
    final dateKey =
        '$y-${m.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final res = await ApiManager.instance.getStudentAttendanceHistory(
        year: y,
        month: m,
        date: dateKey,
      );
      final now = DateTime.now();
      final sorted = List<StudentAttendanceSessionRecord>.from(res.records);
      sorted.sort((a, b) {
        final ta = a.sessionStartTimeUtc ??
            a.sessionDateUtc ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final tb = b.sessionStartTimeUtc ??
            b.sessionDateUtc ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return ta.compareTo(tb);
      });
      final built = <SessionData>[];
      for (var i = 0; i < sorted.length; i++) {
        final r = sorted[i];
        final title = r.courseName ?? r.courseCode ?? 'Session';
        final st = _statusFor(r, date, now);
        final start = r.sessionStartTimeUtc ?? r.sessionDateUtc;
        final time = start != null
            ? formatPktTime12h(start)
            : '—';
        String? att;
        String? upcoming;
        if (st == 'Present' && r.entryTimeUtc != null) {
          att = 'Attendance marked at ${formatPktTime12h(r.entryTimeUtc!)}';
        } else if (st == 'Upcoming' &&
            _sameCalendarDay(date, now) &&
            start != null) {
          upcoming = 'Scheduled ${formatPktTime12h(start)}';
        } else if (st == 'Absent') {
          att = 'Marked absent for this session';
        }
        built.add(
          SessionData(
            iconData: _courseCodeAbbrev(r.courseCode, title),
            iconBgColor: _palette[i % _palette.length],
            title: title,
            time: time,
            status: st,
            attendanceText: att,
            upcomingNotice: upcoming,
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _sessions = built;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _sessions = [];
        _loading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2304AA), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _loadSessionsForDate(picked);
    }
  }

  bool get _isSelectedToday {
    final n = DateTime.now();
    return _selectedDate.year == n.year &&
        _selectedDate.month == n.month &&
        _selectedDate.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    int doneCount = _sessions
        .where((s) => s.status == 'Present' || s.status == 'Absent')
        .length;
    int totalCount = _sessions.length;
    int upcomingCount = _sessions.where((s) => s.status == 'Upcoming').length;
    double progress = totalCount > 0 ? doneCount / totalCount : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF2304AA), // primaryBlue
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom App Bar
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
                      _isSelectedToday
                          ? "Today's Sessions"
                          : "Sessions",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Main Content Area
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
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: _loading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Summary Card
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month,
                                    color: Color(0xFF4F46E5),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, MMM d')
                                            .format(_selectedDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Total $totalCount Sessions",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _selectedDate
                                                .isBefore(DateTime.now()) ||
                                            (_selectedDate.day ==
                                                    DateTime.now().day &&
                                                _selectedDate.month ==
                                                    DateTime.now().month)
                                        ? const Color(0xFFD1FAE5)
                                        : const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                          _selectedDate.isBefore(
                                                      DateTime.now()) ||
                                                  (_selectedDate.day ==
                                                          DateTime.now().day &&
                                                      _selectedDate.month ==
                                                          DateTime.now().month)
                                              ? Icons.check
                                              : Icons.calendar_today,
                                          size: 14,
                                          color: _selectedDate.isBefore(
                                                      DateTime.now()) ||
                                                  (_selectedDate.day ==
                                                          DateTime.now().day &&
                                                      _selectedDate.month ==
                                                          DateTime.now().month)
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF4F46E5)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _selectedDate
                                                    .isBefore(DateTime.now()) ||
                                                (_selectedDate.day ==
                                                        DateTime.now().day &&
                                                    _selectedDate.month ==
                                                        DateTime.now().month)
                                            ? "Present"
                                            : "Upcoming",
                                        style: TextStyle(
                                          color: _selectedDate.isBefore(
                                                      DateTime.now()) ||
                                                  (_selectedDate.day ==
                                                          DateTime.now().day &&
                                                      _selectedDate.month ==
                                                          DateTime.now().month)
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF4F46E5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Progress Bar
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 6,
                              width:
                                  MediaQuery.of(context).size.width * progress,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$doneCount of $totalCount done",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "$upcomingCount upcoming",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Sessions List
                        ..._sessions.map((session) => _buildSessionCard(
                              iconData: session.iconData,
                              iconBgColor: session.iconBgColor,
                              title: session.title,
                              time: session.time,
                              status: session.status,
                              attendanceText: session.attendanceText,
                              upcomingNotice: session.upcomingNotice,
                            )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required String iconData,
    required Color iconBgColor,
    required String title,
    required String time,
    required String status,
    String? attendanceText,
    String? upcomingNotice,
  }) {
    Color statusBgColor;
    Color statusTextColor;
    IconData? statusIcon;

    if (status == "Present") {
      statusBgColor = const Color(0xFFD1FAE5);
      statusTextColor = const Color(0xFF059669);
      statusIcon = Icons.check;
    } else if (status == "Upcoming") {
      statusBgColor = const Color(0xFFEEF2FF);
      statusTextColor = const Color(0xFF4F46E5);
      statusIcon = Icons.remove_circle_outline;
    } else if (status == "Absent") {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
      statusIcon = Icons.close;
    } else {
      statusBgColor = const Color(0xFFF3F4F6);
      statusTextColor = const Color(0xFF6B7280);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    iconData,
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
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (statusIcon != null) ...[
                      Icon(statusIcon, size: 14, color: statusTextColor),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      status,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (attendanceText != null || upcomingNotice != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 64),
                Icon(
                  Icons.circle,
                  size: 6,
                  color: attendanceText != null
                      ? const Color(0xFF059669)
                      : Colors.transparent,
                ),
                if (attendanceText != null) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    attendanceText ?? upcomingNotice!,
                    style: TextStyle(
                      fontSize: 12,
                      color: attendanceText != null
                          ? const Color(0xFF059669)
                          : const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
