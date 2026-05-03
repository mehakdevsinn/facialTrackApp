import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:facialtrackapp/view/student/Dashboard/subject_sessions_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubjectAttendanceData {
  final String? courseId;
  final int reportYear;
  final int reportMonth;
  final List<StudentAttendanceSessionRecord> monthSessions;
  final String code;
  final Color color;
  final String title;
  final String subtitle;
  final double percentage;
  final int totalClasses;
  final int present;
  final int absent;
  final int leave;
  final bool isExpanded;

  SubjectAttendanceData({
    this.courseId,
    required this.reportYear,
    required this.reportMonth,
    this.monthSessions = const [],
    required this.code,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.leave,
    this.isExpanded = false,
  });
}

const List<Color> _subjectPalette = [
  Color(0xFF2304AA),
  Color(0xFF8B5CF6),
  Color(0xFF0D9488),
  Color(0xFFEA580C),
  Color(0xFF6366F1),
  Color(0xFF3B82F6),
];

String _courseCodeAbbrev(String? code, String name) {
  final c = (code ?? '').trim();
  if (c.length >= 2) return c.substring(0, 2).toUpperCase();
  final n = name.trim();
  if (n.length >= 2) return n.substring(0, 2).toUpperCase();
  return '••';
}

String _groupKey(StudentAttendanceSessionRecord r) {
  final id = r.courseId?.trim();
  if (id != null && id.isNotEmpty) return 'id:$id';
  final code = r.courseCode?.trim();
  if (code != null && code.isNotEmpty) return 'code:$code';
  final name = r.courseName?.trim();
  if (name != null && name.isNotEmpty) return 'name:$name';
  return 'unknown';
}

DateTime? _sessionSortInstant(StudentAttendanceSessionRecord r) =>
    r.sessionStartTimeUtc ?? r.sessionDateUtc;

String _sessionRowDateLabel(StudentAttendanceSessionRecord r) {
  final t = _sessionSortInstant(r);
  if (t == null) return '—';
  return DateFormat('MMM d, EEE').format(reportUtcToPktWallForDisplay(t));
}

String _sessionRowTimeLabel(StudentAttendanceSessionRecord r) {
  final start = r.sessionStartTimeUtc ?? r.sessionDateUtc;
  if (start == null) return '—';
  return formatPktEntryExitRange(r.entryTimeUtc, r.exitTimeUtc);
}

List<SubjectAttendanceData> _aggregateMonthSubjects({
  required List<StudentAttendanceSessionRecord> records,
  required int year,
  required int month,
}) {
  final map = <String, List<StudentAttendanceSessionRecord>>{};
  for (final r in records) {
    map.putIfAbsent(_groupKey(r), () => []).add(r);
  }
  var colorIndex = 0;
  final out = <SubjectAttendanceData>[];
  for (final entry in map.entries) {
    final list = entry.value;
    list.sort((a, b) {
      final ta = _sessionSortInstant(a) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final tb = _sessionSortInstant(b) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      return ta.compareTo(tb);
    });
    final first = list.first;
    var present = 0;
    var absent = 0;
    for (final x in list) {
      if (x.isPresent) {
        present++;
      } else {
        absent++;
      }
    }
    final total = present + absent;
    final pct = total == 0 ? 0.0 : (present * 100.0 / total);
    final title = first.courseName ?? first.courseCode ?? 'Course';
    final codeStr = first.courseCode ?? '';
    final teacher = (first.teacherName ?? '').trim();
    final subtitle = [
      if (teacher.isNotEmpty) teacher,
      if (codeStr.isNotEmpty) codeStr,
    ].join(' · ');
    out.add(
      SubjectAttendanceData(
        courseId: first.courseId,
        reportYear: year,
        reportMonth: month,
        monthSessions: List<StudentAttendanceSessionRecord>.from(list),
        code: _courseCodeAbbrev(first.courseCode, title),
        color: _subjectPalette[colorIndex % _subjectPalette.length],
        title: title,
        subtitle: subtitle,
        percentage: pct,
        totalClasses: total,
        present: present,
        absent: absent,
        leave: 0,
      ),
    );
    colorIndex++;
  }
  out.sort((a, b) => b.percentage.compareTo(a.percentage));
  return out;
}

class MonthlyAttendanceScreen extends StatefulWidget {
  const MonthlyAttendanceScreen({super.key});

  @override
  State<MonthlyAttendanceScreen> createState() =>
      _MonthlyAttendanceScreenState();
}

class _MonthlyAttendanceScreenState extends State<MonthlyAttendanceScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: At Risk, 2: Good

  final List<String> _filters = ["All", "At Risk", "Good"];

  List<({int year, int month, String label})> _monthOptions = [];
  int _monthIndex = 0;
  List<SubjectAttendanceData> _subjects = [];
  bool _loading = true;
  String? _error;
  int _thresholdPercent = 75;

  List<SubjectAttendanceData> get _filteredSubjects {
    final t = _thresholdPercent.toDouble();
    if (_selectedFilterIndex == 1) {
      return _subjects.where((s) => s.percentage < t).toList();
    }
    if (_selectedFilterIndex == 2) {
      return _subjects.where((s) => s.percentage >= t).toList();
    }
    return _subjects;
  }

  String get _selectedMonthLabel =>
      _monthOptions.isEmpty ? '—' : _monthOptions[_monthIndex].label;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final criteria =
          await ApiManager.instance.getStudentAttendanceCriteria();
      final bounds = await ApiManager.instance.getStudentHistoryMonthBounds();
      final months = monthRangeInclusive(
        bounds.monthPickerStart,
        bounds.monthPickerEnd,
      );
      if (!mounted) return;
      setState(() {
        _thresholdPercent = criteria.attendanceThresholdPercent;
        _monthOptions = months;
        if (months.isEmpty) {
          _monthIndex = 0;
        } else {
          final now = currentYearMonthPkt();
          var idx = -1;
          for (var i = 0; i < months.length; i++) {
            if (months[i].year == now.year && months[i].month == now.month) {
              idx = i;
              break;
            }
          }
          _monthIndex = idx >= 0 ? idx : months.length - 1;
        }
      });
      await _loadMonth();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMonth() async {
    if (_monthOptions.isEmpty) {
      if (!mounted) return;
      setState(() {
        _subjects = [];
        _loading = false;
      });
      return;
    }
    final y = _monthOptions[_monthIndex].year;
    final m = _monthOptions[_monthIndex].month;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiManager.instance.getStudentAttendanceHistory(
        year: y,
        month: m,
      );
      if (!mounted) return;
      setState(() {
        _subjects = _aggregateMonthSubjects(
          records: res.records,
          year: y,
          month: m,
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _subjects = [];
        _loading = false;
      });
    }
  }

  void _showMonthPicker() {
    if (_monthOptions.isEmpty) return;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _monthOptions.length,
            itemBuilder: (context, index) {
              final opt = _monthOptions[index];
              return ListTile(
                title: Text(opt.label, textAlign: TextAlign.center),
                onTap: () async {
                  Navigator.pop(context);
                  if (index == _monthIndex) return;
                  setState(() => _monthIndex = index);
                  await _loadMonth();
                },
              );
            },
          ),
        );
      },
    );
  }

  List<StudentAttendanceSessionRecord> _recentSessionsForCard(
      SubjectAttendanceData subject) {
    final copy = List<StudentAttendanceSessionRecord>.from(
        subject.monthSessions);
    copy.sort((a, b) {
      final ta = _sessionSortInstant(a) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final tb = _sessionSortInstant(b) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      return tb.compareTo(ta);
    });
    if (copy.length <= 3) return copy;
    return copy.sublist(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalClasses = 0;

    for (var subject in _subjects) {
      totalPresent += subject.present;
      totalAbsent += subject.absent;
      totalClasses += subject.totalClasses;
    }

    int overallPercentage =
        totalClasses > 0 ? ((totalPresent / totalClasses) * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF2304AA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
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
                  const Expanded(
                    child: Text(
                      "Monthly Attendance",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Month Selector Button
                  GestureDetector(
                    onTap: _showMonthPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedMonthLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header Stats
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("$overallPercentage%",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Icon(
                              overallPercentage >= _thresholdPercent
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: overallPercentage >= _thresholdPercent
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              size: 30),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Overall - ${_subjects.length} subjects",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _buildStatBox(
                          "$totalPresent", "Present", const Color(0xFF3B1DBC)),
                      const SizedBox(height: 8),
                      _buildStatBox(
                          "$totalAbsent", "Absent", const Color(0xFF3B1DBC)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Body Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xFF6B7280)),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _bootstrap,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _monthOptions.isEmpty
                            ? const Center(
                                child: Text(
                                  'No attendance months available yet.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 10),
                                    child: Row(
                                      children: List.generate(_filters.length,
                                          (index) {
                                        final isSelected =
                                            _selectedFilterIndex == index;
                                        return GestureDetector(
                                          onTap: () => setState(
                                              () => _selectedFilterIndex =
                                                  index),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            padding: const EdgeInsets
                                                .symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF2304AA)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: isSelected
                                                  ? null
                                                  : Border.all(
                                                      color: Colors
                                                          .grey.shade300),
                                            ),
                                            child: Text(
                                              _filters[index],
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  Expanded(
                                    child: _filteredSubjects.isEmpty
                                        ? Center(
                                            child: Text(
                                              _subjects.isEmpty
                                                  ? 'No sessions recorded for this month.'
                                                  : 'No subjects found for this filter.',
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        : ListView.builder(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                            itemCount:
                                                _filteredSubjects.length,
                                            itemBuilder: (context, index) {
                                              return _buildSubjectCard(
                                                  _filteredSubjects[index]);
                                            },
                                          ),
                                  ),
                                ],
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String count, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SubjectAttendanceData subject) {
    final recent = _recentSessionsForCard(subject);
    final threshold = _thresholdPercent.toDouble();
    Color percentageColor = subject.percentage >= threshold
        ? const Color(0xFF10B981)
        : const Color(0xFFEA580C);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        trailing: const SizedBox
            .shrink(), // Hiding default arrow to match your design
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: subject.color,
              radius: 22,
              child: Text(subject.code,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937))),
                  Text(subject.subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${subject.percentage.toInt()}%",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: percentageColor)),
                Text("${subject.present}/${subject.totalClasses} classes",
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9CA3AF))),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: subject.percentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(percentageColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat(Icons.circle, const Color(0xFF10B981),
                      "${subject.present} Present"),
                  _buildMiniStat(Icons.circle, const Color(0xFFEF4444),
                      "${subject.absent} Absent"),
                  _buildMiniStat(Icons.circle, const Color(0xFFF59E0B),
                      "${subject.leave} Leave"),
                ],
              ),
            ],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: const Color(0xFFF9FAFB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("RECENT SESSIONS",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF))),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'No sessions this month.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  )
                else
                  ...recent.map((r) {
                    final status = r.isPresent ? 'Present' : 'Absent';
                    final statusColor = r.isPresent
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444);
                    return _buildRecentSessionRow(
                      _sessionRowDateLabel(r),
                      _sessionRowTimeLabel(r),
                      status,
                      statusColor,
                    );
                  }),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SubjectSessionsHistoryScreen(subject: subject)),
                      );
                    },
                    child: const Text("View all sessions",
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2304AA),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, size: 8, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRecentSessionRow(
      String date, String time, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
              Text(time,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
          Text(status,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor)),
        ],
      ),
    );
  }
}
