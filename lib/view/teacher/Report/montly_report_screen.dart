import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_report_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthlyAttendanceReport extends StatefulWidget {
  final bool showBackButton;
  const MonthlyAttendanceReport({super.key, this.showBackButton = false});

  @override
  State<MonthlyAttendanceReport> createState() => _MonthlyAttendanceReportState();
}

class _MonthlyAttendanceReportState extends State<MonthlyAttendanceReport> {
  bool showOnlyLow = false;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

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
        final data = report.monthlyReport;
        final threshold = report.attendanceThreshold.toDouble();
        final students = (showOnlyLow && data != null)
            ? data.students
                .where((s) => s.attendancePercentage < threshold)
                .toList()
            : (data?.students ?? []);

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: ColorPallet.primaryBlue,
              leading: widget.showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: const Text('Monthly Report'),
              centerTitle: true,
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
                      onChanged: (v) => report.setSelectedSemester(v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _dropdownCard(
                    title: 'Subject',
                    child: _dropdown(
                      value: report.selectedCourseId,
                      hint: 'Select',
                      items: courses.map((c) => c.id).toList(),
                      labels: {for (final c in courses) c.id: '${c.code} - ${c.name}'},
                      onChanged: (v) => report.setSelectedCourse(v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownCard(
                          title: 'Month',
                          child: _dropdown(
                            value: selectedMonth.toString(),
                            hint: 'Month',
                            items: List.generate(12, (i) => '${i + 1}'),
                            labels: {
                              for (int i = 1; i <= 12; i++)
                                '$i': DateFormat('MMMM').format(DateTime(0, i)),
                            },
                            onChanged: (v) =>
                                setState(() => selectedMonth = int.parse(v!)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dropdownCard(
                          title: 'Year',
                          child: _dropdown(
                            value: selectedYear.toString(),
                            hint: 'Year',
                            items: List.generate(6, (i) => '${DateTime.now().year - 2 + i}'),
                            labels: {
                              for (int i = 0; i < 6; i++)
                                '${DateTime.now().year - 2 + i}':
                                    '${DateTime.now().year - 2 + i}',
                            },
                            onChanged: (v) =>
                                setState(() => selectedYear = int.parse(v!)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallet.primaryBlue,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white70,
                      ),
                      onPressed: report.selectedCourseId == null || report.isGenerating
                          ? null
                          : () {
                              report.generateMonthlyReport(
                                year: selectedYear,
                                month: selectedMonth,
                              );
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
                  const SizedBox(height: 16),
                  if (data != null) ...[
                    _summaryCard(data, report.attendanceThreshold),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilterChip(
                        selected: showOnlyLow,
                        label: Text(
                            'Low Attendance (<${report.attendanceThreshold}%)'),
                        onSelected: (v) => setState(() => showOnlyLow = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _sectionTitle('Class Performance'),
                    const SizedBox(height: 8),
                    if (students.isEmpty)
                      const _EmptyBox(message: 'No students match this filter.')
                    else
                      ...students.map(
                        (s) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.studentName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      s.rollNumber,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${s.attendancePercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: s.attendancePercentage < threshold
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
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

  Widget _summaryCard(data, int threshold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            data.courseName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('MMMM').format(DateTime(0, data.month))} ${data.year}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            'Current criterion: $threshold%',
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metric('Overall', '${data.overallAttendancePercentage.toStringAsFixed(1)}%'),
              _metric('Present', '${data.totalPresentAcrossSessions}'),
              _metric('Absent', '${data.totalAbsentAcrossSessions}'),
              _metric('Sessions', '${data.totalSessions}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;
  const _EmptyBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
