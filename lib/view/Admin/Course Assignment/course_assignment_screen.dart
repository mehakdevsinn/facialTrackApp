import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/course_model.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:facialtrackapp/utils/widgets/course_assignment_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourseAssignmentScreen extends StatefulWidget {
  const CourseAssignmentScreen({super.key});

  @override
  State<CourseAssignmentScreen> createState() => _CourseAssignmentScreenState();
}

class _CourseAssignmentScreenState extends State<CourseAssignmentScreen> {
  int currentStep = 1;
  UserModel? selectedTeacher;

  SemesterModel? selectedSemester;
  CourseModel? selectedCourse;
  String? selectedSection;

  static const List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final p = context.read<AdminProvider>();
      p.fetchTeachers();
      p.fetchSemesters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: Column(
              children: [
                AssignmentHeader(
                  currentStep: currentStep,
                  title: "Course Assignment",
                  onBack: () {
                    if (currentStep > 1) {
                      setState(() => currentStep--);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentStep == 1) _buildTeacherStep(provider),
                        if (currentStep == 2) _buildCourseStep(provider),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: currentStep == 1
                ? AssignmentBottomButton(
                    label: "Confirm Teacher",
                    isEnabled: selectedTeacher != null,
                    onTap: () => setState(() => currentStep = 2),
                  )
                : AssignmentBottomButton(
                    label: provider.isLoading
                        ? "Saving..."
                        : "Finalize Assignment",
                    isEnabled: selectedCourse != null &&
                        selectedSection != null &&
                        !provider.isLoading,
                    onTap: () => _handleFinalize(provider),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handleFinalize(AdminProvider provider) async {
    if (selectedTeacher == null ||
        selectedCourse == null ||
        selectedSection == null) return;

    final success = await provider.createAssignment(
      courseId: selectedCourse!.id,
      teacherId: selectedTeacher!.id,
      section: selectedSection!,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Assignment created successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Failed to create assignment"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildTeacherStep(AdminProvider provider) {
    if (provider.isTeachersLoading) {
      return const Center(heightFactor: 5, child: CircularProgressIndicator());
    }
    if (provider.teachers.isEmpty) {
      return const Center(
          heightFactor: 5, child: Text("No teachers available."));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Faculty Members",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5)),
        Text("Select a teacher to assign courses",
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.teachers.length,
          itemBuilder: (context, index) {
            final teacher = provider.teachers[index];
            final isSelected = selectedTeacher?.id == teacher.id;
            return TeacherSelectionCard(
              teacher: {
                'name': teacher.fullName,
                'designation': teacher.designation ?? 'Teacher',
                'initials': _initials(teacher.fullName),
              },
              isSelected: isSelected,
              onTap: () => setState(() => selectedTeacher = teacher),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCourseStep(AdminProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Assign Courses to ${selectedTeacher?.fullName ?? ''}",
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B)),
        ),
        Text("Pick semester → course → section",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        const SizedBox(height: 24),

        // SEMESTER DROPDOWN
        _sectionLabel("Semester"),
        if (provider.isSemestersLoading)
          const CircularProgressIndicator()
        else
          _dropdownCard<SemesterModel>(
            value: selectedSemester,
            hint: "Choose Semester",
            icon: Icons.calendar_today_rounded,
            items: provider.semesters,
            displayText: (s) => s.displayName,
            onChanged: (s) {
              setState(() {
                selectedSemester = s;
                selectedCourse = null;
              });
              if (s != null) provider.fetchCourses(s.id);
            },
          ),

        if (selectedSemester != null) ...[
          const SizedBox(height: 16),
          _sectionLabel("Course"),
          if (provider.isCoursesLoading(selectedSemester!.id))
            const CircularProgressIndicator()
          else
            _dropdownCard<CourseModel>(
              value: selectedCourse,
              hint: "Choose Course",
              icon: Icons.menu_book_rounded,
              items: provider.getCoursesForSemester(selectedSemester!.id),
              displayText: (c) => "${c.code} — ${c.name}",
              onChanged: (c) => setState(() => selectedCourse = c),
            ),
        ],

        if (selectedCourse != null) ...[
          const SizedBox(height: 16),
          _sectionLabel("Section"),
          _dropdownCard<String>(
            value: selectedSection,
            hint: "Choose Section",
            icon: Icons.school_rounded,
            items: _sections,
            displayText: (s) => "Section $s",
            onChanged: (s) => setState(() => selectedSection = s),
          ),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              color: ColorPallet.primaryBlue.withOpacity(0.6),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5)),
    );
  }

  Widget _dropdownCard<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<T> items,
    required String Function(T) displayText,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Row(children: [
            Icon(icon, color: Colors.grey.shade400, size: 18),
            const SizedBox(width: 10),
            Text(hint,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ]),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(displayText(item),
                        style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: ColorPallet.primaryBlue),
        ),
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
