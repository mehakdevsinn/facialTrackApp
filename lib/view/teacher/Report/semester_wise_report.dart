import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_report_provider.dart';
import 'package:facialtrackapp/core/models/report_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SemesterWiseReportScreen extends StatefulWidget {
  const SemesterWiseReportScreen({super.key});

  @override
  State<SemesterWiseReportScreen> createState() => _SemesterWiseReportScreenState();
}

class _SemesterWiseReportScreenState extends State<SemesterWiseReportScreen> {
  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<TeacherReportProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherReportProvider>(
      builder: (context, report, _) {
        final semesters = report.semesterOptions;
        final courses = report.filteredCourses;
        final data = report.courseReport;
        CourseReportStudent? selectedStudent;
        if (_selectedStudentId != null && data != null) {
          for (final s in data.students) {
            if (s.studentId == _selectedStudentId) {
              selectedStudent = s;
              break;
            }
          }
        }

        return SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FE),
            appBar: AppBar(
              title: const Text('Semester Report'),
              backgroundColor: ColorPallet.primaryBlue,
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    decoration: const BoxDecoration(
                      color: ColorPallet.primaryBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        _dropdown(
                          title: 'Academic Semester',
                          value: report.selectedSemesterId,
                          items: semesters.map((s) => s.id).toList(),
                          labels: {for (final s in semesters) s.id: s.label},
                          onChanged: (v) {
                            report.setSelectedSemester(v);
                            setState(() => _selectedStudentId = null);
                          },
                        ),
                        const SizedBox(height: 12),
                        _dropdown(
                          title: 'Target Course',
                          value: report.selectedCourseId,
                          items: courses.map((c) => c.id).toList(),
                          labels: {for (final c in courses) c.id: '${c.code} - ${c.name}'},
                          onChanged: (v) {
                            report.setSelectedCourse(v);
                            setState(() => _selectedStudentId = null);
                          },
                        ),
                        const SizedBox(height: 12),
                        _dropdown(
                          title: 'Student Filter',
                          value: data == null ? null : (_selectedStudentId ?? 'all'),
                          items: [
                            'all',
                            ...(data?.students.map((s) => s.studentId) ?? []),
                          ],
                          labels: {
                            'all': 'All Students',
                            for (final s in data?.students ?? [])
                              s.studentId: '${s.studentName} (${s.rollNumber})',
                          },
                          onChanged: (v) {
                            setState(() => _selectedStudentId = v == 'all' ? null : v);
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: ColorPallet.primaryBlue,
                            ),
                            onPressed: report.selectedCourseId == null ||
                                    report.isGenerating
                                ? null
                                : () async {
                                    await report.generateSemesterReport();
                                    if (!mounted) return;
                                    setState(() => _selectedStudentId = null);
                                  },
                            child: Text(
                              report.isGenerating ? 'Generating...' : 'Generate',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (report.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        report.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  if (data != null)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _statsCard(
                        selectedStudent ?? _aggregate(data),
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

  CourseReportStudent _aggregate(CourseReportResponse data) {
    final present = data.students.fold<int>(0, (sum, s) => sum + s.sessionsAttended);
    final total = data.students.fold<int>(0, (sum, s) => sum + s.totalSessions);
    final double percent = total == 0 ? 0.0 : (present / total) * 100.0;
    return CourseReportStudent(
      studentId: 'all',
      studentName: 'All Students',
      rollNumber: '-',
      sessionsAttended: present,
      totalSessions: total,
      attendancePercentage: percent,
      lateCount: 0,
    );
  }

  Widget _statsCard(CourseReportStudent stats) {
    final absent = stats.totalSessions - stats.sessionsAttended;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stats.studentName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _line('Total Classes', '${stats.totalSessions}'),
          _line('Present', '${stats.sessionsAttended}'),
          _line('Absent', '$absent'),
          _line('Attendance %', '${stats.attendancePercentage.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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

  Widget _dropdown({
    required String title,
    required String? value,
    required List<String> items,
    required Map<String, String> labels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text('Select'),
              items: items
                  .map(
                    (id) => DropdownMenuItem<String>(
                      value: id,
                      child: Text(labels[id] ?? id, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
