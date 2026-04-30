import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/student_reports_provider.dart';
import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:facialtrackapp/view/student/Attendence%20History/attendence-detail-screen.dart';
import 'package:facialtrackapp/view/student/Complaint/attendance_complaint_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final p = context.read<StudentReportsProvider>();
    await p.loadBootstrap();
    if (!mounted) return;
    if (p.canLoadHistory) await p.loadHistory();
  }

  Future<void> _onMonthChanged(StudentReportsProvider p, String? label) async {
    if (label == null) return;
    for (final e in p.selectableMonths) {
      if (e.label == label) {
        p.selectMonth(e.year, e.month);
        await p.loadHistory();
        break;
      }
    }
  }

  Future<void> _onCourseChipTap(StudentReportsProvider p, int index) async {
    if (index == 0) {
      p.selectCourseFilter(null);
    } else {
      final courses = p.enrolledCourses;
      if (index - 1 < courses.length) {
        p.selectCourseFilter(courses[index - 1].courseId);
      }
    }
    await p.loadHistory();
  }

  int _selectedChipIndex(StudentReportsProvider p) {
    final id = p.selectedCourseId;
    if (id == null || id.isEmpty) return 0;
    final idx = p.enrolledCourses.indexWhere((c) => c.courseId == id);
    return idx < 0 ? 0 : idx + 1;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: ColorPallet.primaryBlue,
          elevation: 0,
          title: const Text(
            'Attendance History',
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<StudentReportsProvider>(
          builder: (context, p, _) {
            if (p.loadingBootstrap && p.bounds == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (p.errorMessage != null &&
                p.bounds == null &&
                !p.loadingBootstrap) {
              return _errorBody(p.errorMessage!, () => _bootstrap());
            }

            final bounds = p.bounds;
            if (bounds == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final noRange = !bounds.hasEnrolledCourses ||
                p.selectableMonths.isEmpty ||
                p.selectedYear == null;

            return Column(
              children: [
                _courseChipsRow(p),
                const SizedBox(height: 16),
                _monthDropdown(p, noRange),
                const SizedBox(height: 12),
                if (!noRange) _summaryRow(p),
                const SizedBox(height: 8),
                Expanded(child: _listSection(p, noRange, bounds)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _errorBody(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _courseChipsRow(StudentReportsProvider p) {
    final labels = <String>['All'];
    for (final c in p.enrolledCourses) {
      labels.add(c.courseCode.isNotEmpty ? c.courseCode : c.courseName);
    }
    final chipIndex = _selectedChipIndex(p);

    return Container(
      color: ColorPallet.white,
      padding: const EdgeInsets.only(top: 13, bottom: 13),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Row(
            children: List.generate(labels.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: p.loadingBootstrap
                      ? null
                      : () => _onCourseChipTap(p, index),
                  child: _filterChip(
                    labels[index],
                    selected: chipIndex == index,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _monthDropdown(StudentReportsProvider p, bool noRange) {
    final months = p.selectableMonths.map((e) => e.label).toList();
    final currentLabel = p.selectedMonthLabel();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (currentLabel != null && months.contains(currentLabel))
              ? currentLabel
              : null,
          hint: const Text('No month available'),
          dropdownColor: const Color.fromARGB(255, 235, 235, 235),
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          items: months
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m)),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: noRange || p.loadingBootstrap
              ? null
              : (v) => _onMonthChanged(p, v),
        ),
      ),
    );
  }

  Widget _summaryRow(StudentReportsProvider p) {
    final h = p.history;
    final total = h?.totalSessions ?? 0;
    final att = h?.sessionsAttended ?? 0;
    final abs = h?.sessionsAbsent ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 2,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: p.loadingHistory
            ? const Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryCell('Sessions', '$total'),
                  _summaryCell('Present', '$att', Colors.green),
                  _summaryCell('Absent', '$abs', Colors.red),
                ],
              ),
      ),
    );
  }

  Widget _summaryCell(String label, String value, [Color? valueColor]) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _listSection(
    StudentReportsProvider p,
    bool noRange,
    StudentMonthPickerBounds bounds,
  ) {
    if (noRange) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            bounds.hasEnrolledCourses == false
                ? 'No subjects assigned. Attendance history is available once you are enrolled in courses.'
                : 'No valid date range for attendance history.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    if (p.errorMessage != null && p.history == null && !p.loadingHistory) {
      return _errorBody(p.errorMessage!, () => p.loadHistory());
    }

    if (p.loadingHistory && (p.history == null || p.history!.records.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    final records = p.history?.records ?? [];
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'No attendance records for this month.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return AttendanceCard(record: records[index]);
      },
    );
  }

  Widget _filterChip(String text, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? ColorPallet.primaryBlue
            : const Color.fromARGB(255, 185, 183, 183),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? ColorPallet.white : ColorPallet.black,
          fontSize: 12,
        ),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final StudentAttendanceSessionRecord record;

  const AttendanceCard({super.key, required this.record});

  DateTime _complaintDate() {
    final u = record.sessionDateUtc;
    if (u == null) return DateTime.now();
    final iso = formatPktDateIso(u);
    return DateTime.parse(iso);
  }

  @override
  Widget build(BuildContext context) {
    final u = record.sessionDateUtc;
    final dateStr = u != null ? formatPktDateCard(u) : '—';
    final dayStr = u != null ? formatPktDayName(u) : '';
    final present = record.isPresent;
    final subject = record.courseName ?? '—';
    final teacher = record.teacherName ?? '';
    final verify = verificationMethodLabel(record.verificationMethod);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: present ? Colors.green : Colors.red,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (dayStr.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          dayStr,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (verify != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text(verify, style: const TextStyle(fontSize: 10)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: present
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    present ? 'Present' : 'Absent',
                    style: TextStyle(
                      color: present ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            _infoRow(Icons.book, subject),
            if (teacher.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.person, teacher),
            ],
            const SizedBox(height: 5),
            const Divider(),
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceComplaintScreen(
                          sessionId: record.sessionId,
                          courseName: subject,
                          teacherName: teacher.isEmpty ? '—' : teacher,
                          date: _complaintDate(),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Report Issue',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (record.sessionId.isEmpty) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceDetailScreen(
                          sessionId: record.sessionId,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: ColorPallet.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}
