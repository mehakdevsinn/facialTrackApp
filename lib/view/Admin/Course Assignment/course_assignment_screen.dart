import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/assignment_data_service.dart';
import 'package:facialtrackapp/utils/widgets/course_assignment_widgets.dart';
import 'package:flutter/material.dart';

class CourseAssignmentScreen extends StatefulWidget {
  final String? initialTeacher;
  final List<Map<String, dynamic>>? initialSubjects;
  const CourseAssignmentScreen({
    super.key,
    this.initialTeacher,
    this.initialSubjects,
  });

  @override
  State<CourseAssignmentScreen> createState() => _CourseAssignmentScreenState();
}

class _CourseAssignmentScreenState extends State<CourseAssignmentScreen> {
  int currentStep = 1;
  String? selectedTeacher;
  List<Map<String, dynamic>> assignedSubjects = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialTeacher != null) {
      currentStep = 2;
      selectedTeacher = widget.initialTeacher;
    }
    if (widget.initialSubjects != null) {
      assignedSubjects = List.from(widget.initialSubjects!);
    }
  }

  final List<Map<String, String>> teachers = [
    {
      "name": "Dr. Sarah Ahmed",
      "designation": "Associate Professor",
      "initials": "SA",
    },
    {
      "name": "Prof. Usman Khan",
      "designation": "Head of Department",
      "initials": "UK",
    },
    {"name": "Engr. Maria Ali", "designation": "Lecturer", "initials": "MA"},
    {
      "name": "Dr. Ahmed Hassan",
      "designation": "Assistant Professor",
      "initials": "AH",
    },
    {"name": "Ms. Zainab Bibi", "designation": "Instructor", "initials": "ZB"},
  ];

  @override
  Widget build(BuildContext context) {
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
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentStep == 1) _buildTeacherStep(),
                    if (currentStep == 2) _buildSubjectStep(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: currentStep == 1
            ? AssignmentBottomButton(
                label: "Confirm Teacher",
                isEnabled: selectedTeacher != null,
                onTap: () => setState(() => currentStep = 2),
              )
            : AssignmentBottomButton(
                label: "Finalize Assignment",
                isEnabled: assignedSubjects.isNotEmpty,
                onTap: () {
                  final teacherData = teachers.firstWhere(
                    (t) => t['name'] == selectedTeacher,
                  );
                  final result = {
                    "teacherName": selectedTeacher,
                    "teacherDesignation": teacherData['designation'],
                    "initials": teacherData['initials'],
                    "subjects": assignedSubjects,
                  };

                  AssignmentDataService.updateAssignment(result);

                  Navigator.pop(context, result);
                },
              ),
      ),
    );
  }

  Widget _buildTeacherStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Faculty Members",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        Text(
          "Select a teacher to assign courses",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            final isSelected = selectedTeacher == teacher['name'];
            return TeacherSelectionCard(
              teacher: teacher,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  selectedTeacher = teacher['name'];
                  final existing = AssignmentDataService.allAssignments
                      .firstWhere(
                        (a) => a['teacherName'] == selectedTeacher,
                        orElse: () => {},
                      );
                  if (existing.isNotEmpty && existing['subjects'] != null) {
                    assignedSubjects = List<Map<String, dynamic>>.from(
                      existing['subjects'],
                    );
                  } else {
                    assignedSubjects = [];
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubjectStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Assigned Subjects",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  "Courses assigned to $selectedTeacher",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
            IconButton(
              onPressed: () => AssignmentDialogs.openAssignScreen(
                context: context,
                selectedTeacher: selectedTeacher!,
                onResult: (result, isEdit) {
                  setState(() => assignedSubjects.add(result));
                },
              ),
              icon: const Icon(
                Icons.add_circle_rounded,
                color: ColorPallet.primaryBlue,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        if (assignedSubjects.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.menu_book_rounded,
                  size: 60,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 20),
                Text(
                  "No subjects assigned yet",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Click + to start allotting courses",
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignedSubjects.length,
            itemBuilder: (context, index) {
              final sub = assignedSubjects[index];
              return BlueAssignedSubjectCard(
                title: sub['course'],
                code: sub['code'],
                credits: sub['credits'],
                semester: "${sub['semester']} • ${sub['section']}",
                onEdit: () => AssignmentDialogs.openAssignScreen(
                  context: context,
                  selectedTeacher: selectedTeacher!,
                  initialData: sub,
                  index: index,
                  onResult: (result, isEdit) {
                    setState(() => assignedSubjects[index] = result);
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
