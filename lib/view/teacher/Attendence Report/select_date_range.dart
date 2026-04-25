import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_report_provider.dart';
import 'package:facialtrackapp/view/teacher/Attendence%20Report/attendence_report_screen.dart';
import 'package:facialtrackapp/view/teacher/Attendence%20Report/date_range.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  DateTime? startDate;
  DateTime? endDate;

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
        final semesterItems = report.semesterOptions;
        final courses = report.filteredCourses;
        final canGenerate = report.selectedSemesterId != null &&
            report.selectedCourseId != null &&
            startDate != null &&
            !report.isGenerating;

        return SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFF),
            appBar: AppBar(
              backgroundColor: ColorPallet.primaryBlue,
              foregroundColor: Colors.white,
              centerTitle: true,
              title: const Text(
                'Academic Selection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analyze Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const Text(
                    'Select details to generate analytics',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  _label('Academic Semester'),
                  _dropdown(
                    value: report.selectedSemesterId,
                    hint: report.isLoadingCourses ? 'Loading...' : 'Choose Semester',
                    items: semesterItems.map((s) => s.id).toList(),
                    labels: {for (final s in semesterItems) s.id: s.label},
                    isLoading: report.isLoadingCourses,
                    emptyMessage:
                        'No course assignments yet. Ask an administrator to assign subjects before you can run reports.',
                    onChanged: report.isLoadingCourses
                        ? null
                        : (v) => report.setSelectedSemester(v),
                  ),
                  const SizedBox(height: 20),
                  _label('Course Subject'),
                  _dropdown(
                    value: report.selectedCourseId,
                    hint: 'Choose Subject',
                    items: courses.map((c) => c.id).toList(),
                    labels: {for (final c in courses) c.id: '${c.code} - ${c.name}'},
                    isLoading: report.isLoadingCourses,
                    emptyMessage: report.selectedSemesterId == null
                        ? 'Choose a semester first.'
                        : 'No subjects for this semester. Check your assignments or pick another semester.',
                    onChanged: report.selectedSemesterId == null ||
                            report.isLoadingCourses
                        ? null
                        : (v) => report.setSelectedCourse(v),
                  ),
                  const SizedBox(height: 20),
                  _label('Time Period'),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TimeframeScreen(),
                        ),
                      );
                      if (result is Map<String, DateTime?>) {
                        setState(() {
                          startDate = result['start'];
                          endDate = result['end'];
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        startDate == null
                            ? 'Select Date Range'
                            : '${startDate!.toIso8601String().split('T').first} - ${(endDate ?? startDate!).toIso8601String().split('T').first}',
                        style: TextStyle(
                          color: startDate == null ? Colors.grey : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (report.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      report.errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canGenerate
                            ? ColorPallet.primaryBlue
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: canGenerate
                          ? () async {
                              final start =
                                  startDate!.toIso8601String().split('T').first;
                              final end = (endDate ?? startDate!)
                                  .toIso8601String()
                                  .split('T')
                                  .first;
                              final ok = await context
                                  .read<TeacherReportProvider>()
                                  .generateDateRangeReport(
                                    startDate: start,
                                    endDate: end,
                                  );
                              if (!mounted) return;
                              if (!ok) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AttendanceReportScreen(
                                    startDate: startDate,
                                    endDate: endDate ?? startDate,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        report.isGenerating ? 'Generating...' : 'Generate Report',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      );

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Map<String, String> labels,
    required ValueChanged<String?>? onChanged,
    bool isLoading = false,
    String? emptyMessage,
  }) {
    Widget inner;
    if (isLoading && items.isEmpty) {
      inner = const Padding(
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
    } else if (items.isEmpty) {
      inner = Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
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
    } else {
      final safeValue = (value != null && items.contains(value)) ? value : null;
      inner = DropdownButtonHideUnderline(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: inner,
    );
  }
}
