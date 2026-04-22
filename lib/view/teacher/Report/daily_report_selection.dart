import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_report_provider.dart';
import 'package:facialtrackapp/view/teacher/Report/daily_attendance_report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DailyReportSelectionScreen extends StatefulWidget {
  const DailyReportSelectionScreen({super.key});

  @override
  State<DailyReportSelectionScreen> createState() =>
      _DailyReportSelectionScreenState();
}

class _DailyReportSelectionScreenState extends State<DailyReportSelectionScreen> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<TeacherReportProvider>().loadCourses();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherReportProvider>(
      builder: (context, report, _) {
        final semesterItems = report.semesterOptions;
        final courses = report.filteredCourses;
        final isReady = report.selectedSemesterId != null &&
            report.selectedCourseId != null &&
            selectedDate != null &&
            !report.isGenerating;

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Specific Date Report',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              backgroundColor: ColorPallet.primaryBlue,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Report Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select semester, subject and date to generate the daily report.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 35),
                  _buildLabel('Select Semester'),
                  _buildDropdown(
                    hint: report.isLoadingCourses ? 'Loading...' : 'Choose Semester',
                    value: report.selectedSemesterId,
                    items: semesterItems.map((s) => s.id).toList(),
                    labelsByValue: {for (final s in semesterItems) s.id: s.label},
                    icon: Icons.school_outlined,
                    onChanged: report.isLoadingCourses
                        ? null
                        : (value) => report.setSelectedSemester(value),
                  ),
                  const SizedBox(height: 25),
                  _buildLabel('Select Subject'),
                  _buildDropdown(
                    hint: 'Choose Subject',
                    value: report.selectedCourseId,
                    items: courses.map((c) => c.id).toList(),
                    labelsByValue: {
                      for (final c in courses) c.id: '${c.code} - ${c.name}',
                    },
                    icon: Icons.auto_stories_outlined,
                    onChanged: (value) => report.setSelectedCourse(value),
                  ),
                  const SizedBox(height: 25),
                  _buildLabel('Select Date'),
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
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
                          Icon(
                            Icons.calendar_today_outlined,
                            color: ColorPallet.primaryBlue.withOpacity(0.7),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('dd MMMM, yyyy').format(selectedDate!),
                              style: TextStyle(
                                color: selectedDate == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
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
                  const SizedBox(height: 45),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isReady
                            ? ColorPallet.primaryBlue
                            : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: isReady
                          ? () async {
                              final reportDate =
                                  DateFormat('yyyy-MM-dd').format(selectedDate!);
                              final ok = await context
                                  .read<TeacherReportProvider>()
                                  .generateDailyReport(reportDate: reportDate);
                              if (!mounted) return;
                              if (!ok) {
                                final message = context
                                        .read<TeacherReportProvider>()
                                        .errorMessage ??
                                    'Failed to generate report.';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const DailyAttendanceReportScreen(),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        report.isGenerating ? 'Generating...' : 'Generate Report',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Map<String, String> labelsByValue,
    required IconData icon,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: ColorPallet.primaryBlue,
          ),
          items: items
              .map(
                (id) => DropdownMenuItem<String>(
                  value: id,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: ColorPallet.primaryBlue.withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          labelsByValue[id] ?? id,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
