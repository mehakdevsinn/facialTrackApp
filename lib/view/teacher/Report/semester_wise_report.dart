import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_report_provider.dart';
import 'package:facialtrackapp/core/models/report_models.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:facialtrackapp/services/teacher_report_pdf_service.dart';
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

  String? _semesterPdfLabel(TeacherReportProvider report) {
    final n = report.selectedCourse?.semester?.semesterNumber;
    if (n == null) return null;
    return 'Semester $n';
  }

  String _coursePeriodLabel(CourseReportResponse data) {
    final dr = data.dateRange;
    if (dr == null) return 'Full semester (server scope)';
    final a = dr.start == null || dr.start!.isEmpty
        ? ''
        : formatPktDateLineFromApiString(dr.start);
    final b = dr.end == null || dr.end!.isEmpty
        ? ''
        : formatPktDateLineFromApiString(dr.end);
    if (a.isEmpty && b.isEmpty) return 'Full semester (server scope)';
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;
    return '$a - $b';
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
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Text('Semester Report'),
              centerTitle: true,
              backgroundColor: ColorPallet.primaryBlue,
              foregroundColor: Colors.white,
              actions: [
                if (data != null) ...[
                  IconButton(
                    icon: const Icon(Icons.warning_amber_outlined),
                    tooltip: 'Export low attendance list (PDF)',
                    onPressed: () async {
                      final low = data.students
                          .where(
                            (s) =>
                                s.attendancePercentage <
                                report.attendanceThreshold,
                          )
                          .toList();
                      if (low.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No students below the attendance threshold.',
                            ),
                          ),
                        );
                        return;
                      }
                      try {
                        await TeacherReportPdfService
                            .layoutLowAttendanceStudentsPdf(
                          reportTitle: 'Low attendance — semester / course',
                          courseName: data.courseName,
                          semesterLabel: _semesterPdfLabel(report),
                          periodOrRangeDescription: _coursePeriodLabel(data),
                          thresholdPercent: report.attendanceThreshold,
                          lowStudents: low,
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF export failed: $e')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export PDF',
                    onPressed: () async {
                      try {
                        await TeacherReportPdfService.layoutCourseReportPdf(
                          data: data,
                          highlightStudent: selectedStudent,
                          semesterLabel: _semesterPdfLabel(report),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF export failed: $e')),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _dropdownCard(
                    title: 'Semester',
                    child: _dropdown(
                      value: report.selectedSemesterId,
                      hint: report.isLoadingCourses ? 'Loading...' : 'Select',
                      items: semesters.map((s) => s.id).toList(),
                      labels: {for (final s in semesters) s.id: s.label},
                      isLoading: report.isLoadingCourses,
                      emptyMessage:
                          'No course assignments yet. Ask an administrator to assign subjects before you can run reports.',
                      onChanged: report.isLoadingCourses
                          ? null
                          : (v) {
                              report.setSelectedSemester(v);
                              setState(() => _selectedStudentId = null);
                            },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _dropdownCard(
                    title: 'Subject',
                    child: _dropdown(
                      value: report.selectedCourseId,
                      hint: 'Select',
                      items: courses.map((c) => c.id).toList(),
                      labels: {
                        for (final c in courses) c.id: '${c.code} - ${c.name}',
                      },
                      isLoading: report.isLoadingCourses,
                      emptyMessage: report.selectedSemesterId == null
                          ? 'Choose a semester first.'
                          : 'No subjects for this semester. Check your assignments or pick another semester.',
                      onChanged: report.selectedSemesterId == null ||
                              report.isLoadingCourses
                          ? null
                          : (v) {
                              report.setSelectedCourse(v);
                              setState(() => _selectedStudentId = null);
                            },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _dropdownCard(
                    title: 'Student filter',
                    child: _dropdown(
                      value: data == null ? null : (_selectedStudentId ?? 'all'),
                      hint: 'Select',
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
                        setState(
                            () => _selectedStudentId = v == 'all' ? null : v);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallet.primaryBlue,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white70,
                        disabledBackgroundColor:
                            ColorPallet.primaryBlue.withOpacity(0.45),
                        surfaceTintColor: Colors.transparent,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (report.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      report.errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                  if (data != null) ...[
                    const SizedBox(height: 16),
                    _statsCard(selectedStudent ?? _aggregate(data)),
                  ],
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
      verificationMethod: null,
    );
  }

  Widget _statsCard(CourseReportStudent stats) {
    final absent = stats.totalSessions - stats.sessionsAttended;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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

  Widget _dropdownCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          child,
        ],
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Map<String, String> labels,
    required ValueChanged<String?>? onChanged,
    bool isLoading = false,
    String? emptyMessage,
  }) {
    if (isLoading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading…', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.blueGrey.shade400, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                emptyMessage ?? 'Nothing to select yet.',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final safeValue = (value != null && items.contains(value)) ? value : null;
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: safeValue,
        hint: Text(hint),
        items: items
            .map(
              (id) => DropdownMenuItem<String>(
                value: id,
                child: Text(
                  labels[id] ?? id,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
