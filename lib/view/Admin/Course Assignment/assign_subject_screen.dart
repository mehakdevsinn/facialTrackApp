import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/utils/widgets/course_assignment_widgets.dart';
import 'package:flutter/material.dart';

class AssignSubjectScreen extends StatefulWidget {
  final String teacherName;
  final Map<String, dynamic>? initialData;
  const AssignSubjectScreen({
    super.key,
    required this.teacherName,
    this.initialData,
  });

  @override
  State<AssignSubjectScreen> createState() => _AssignSubjectScreenState();
}

class _AssignSubjectScreenState extends State<AssignSubjectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String? selectedSemester;
  String? selectedCourse;
  String? selectedSection;
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();

  final List<String> semesters = ["2nd Sem", "4th Sem", "6th Sem", "8th Sem"];
  final List<String> sections = ["Section A", "Section B", "Section C"];

  final Map<String, List<Map<String, String>>> semesterSubjects = {
    "2nd Sem": [
      {"name": "Introduction to Computing", "code": "CS-101", "credits": "3"},
      {"name": "Programming Fundamentals", "code": "CS-102", "credits": "4"},
      {"name": "Discrete Structures", "code": "CS-201", "credits": "3"},
    ],
    "4th Sem": [
      {"name": "Data Structures", "code": "CS-202", "credits": "4"},
      {"name": "Operating Systems", "code": "CS-301", "credits": "4"},
      {"name": "Database Systems", "code": "CS-302", "credits": "3"},
    ],
    "6th Sem": [
      {"name": "Software Engineering", "code": "SE-301", "credits": "3"},
      {"name": "Computer Networks", "code": "CS-401", "credits": "4"},
      {"name": "Artificial Intelligence", "code": "AI-401", "credits": "4"},
    ],
    "8th Sem": [
      {"name": "Final Year Project", "code": "FYP-499", "credits": "6"},
      {"name": "Cloud Computing", "code": "CS-412", "credits": "3"},
      {"name": "Professional Ethics", "code": "HU-401", "credits": "2"},
    ],
  };

  List<String> get currentCourses {
    if (selectedSemester == null) return [];
    return semesterSubjects[selectedSemester]
            ?.map((e) => e['name']!)
            .toList() ??
        [];
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      selectedSemester = widget.initialData!['semester'];
      selectedCourse = widget.initialData!['course'];
      selectedSection = widget.initialData!['section'];
      _codeController.text = widget.initialData!['code'] ?? "";
      _creditsController.text = widget.initialData!['credits'] ?? "";
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorPallet.primaryBlue,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.initialData != null ? "Edit Allotment" : "Assign Subject",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AssignmentLabel(text: "Assign To"),
                        AssignmentInfoDisplay(
                          text: widget.teacherName,
                          icon: Icons.person_outline_rounded,
                        ),

                        const AssignmentLabel(text: "Select Semester"),
                        AssignmentDropdownField(
                          value: selectedSemester,
                          hint: "Choose Semester",
                          icon: Icons.calendar_today_rounded,
                          items: semesters,
                          onChanged: (val) {
                            setState(() {
                              selectedSemester = val;
                              selectedCourse = null;
                              _codeController.clear();
                              _creditsController.clear();
                            });
                          },
                        ),

                        if (selectedSemester != null) ...[
                          const AssignmentLabel(text: "Select Course"),
                          AssignmentDropdownField(
                            value: selectedCourse,
                            hint: "Choose Subject",
                            icon: Icons.menu_book_rounded,
                            items: currentCourses,
                            onChanged: (val) {
                              setState(() {
                                selectedCourse = val;
                                final details =
                                    semesterSubjects[selectedSemester!]
                                        ?.firstWhere((e) => e['name'] == val);
                                if (details != null) {
                                  _codeController.text = details['code']!;
                                  _creditsController.text = details['credits']!;
                                }
                              });
                            },
                          ),
                        ],

                        const AssignmentLabel(text: "Select Section"),
                        AssignmentDropdownField(
                          value: selectedSection,
                          hint: "Choose Section",
                          icon: Icons.school_rounded,
                          items: sections,
                          onChanged: (val) =>
                              setState(() => selectedSection = val),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AssignmentLabel(text: "Course Code"),
                                  AssignmentReadOnlyField(
                                    controller: _codeController,
                                    icon: Icons.code_rounded,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AssignmentLabel(text: "Credits"),
                                  AssignmentReadOnlyField(
                                    controller: _creditsController,
                                    icon: Icons.stars_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 50),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPallet.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 8,
                              shadowColor: ColorPallet.primaryBlue.withOpacity(
                                0.4,
                              ),
                            ),
                            onPressed: _handleSave,
                            child: Text(
                              widget.initialData != null
                                  ? "UPDATE ALLOTMENT"
                                  : "CONFIRM ALLOTMENT",
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (selectedSemester == null ||
        selectedCourse == null ||
        selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select semester, subject and section"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      "semester": selectedSemester,
      "course": selectedCourse,
      "section": selectedSection,
      "code": _codeController.text,
      "credits": _creditsController.text,
    });
  }
}
