import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/widgets/scheme_widgets.dart';
import 'package:flutter/material.dart';

class SchemeOfStudyScreen extends StatefulWidget {
  const SchemeOfStudyScreen({super.key});

  @override
  State<SchemeOfStudyScreen> createState() => _SchemeOfStudyScreenState();
}

class _SchemeOfStudyScreenState extends State<SchemeOfStudyScreen> {
  String selectedDepartment = "Computer Science";
  String selectedSemester = "2nd Sem";
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  final Map<String, List<Map<String, dynamic>>> coursesBySemester = {
    "2nd Sem": [
      {
        "title": "Introduction to Computing",
        "code": "CS-101",
        "credits": "3",
        "outline": "Basics of computers and logic.",
        "attendanceRequired": true,
      },
      {
        "title": "Programming Fundamentals",
        "code": "CS-102",
        "credits": "4",
        "outline": "Introduction to C++ and basic syntax.",
        "attendanceRequired": true,
      },
      {
        "title": "Discrete Structures",
        "code": "CS-201",
        "credits": "3",
        "outline": "Mathematical foundations for CS.",
        "attendanceRequired": false,
      },
    ],
    "4th Sem": [
      {
        "title": "Data Structures",
        "code": "CS-202",
        "credits": "4",
        "outline": "Implementation of lists, stacks, and queues.",
        "attendanceRequired": true,
      },
      {
        "title": "Operating Systems",
        "code": "CS-301",
        "credits": "4",
        "outline": "Kernel basics and process management.",
        "attendanceRequired": true,
      },
      {
        "title": "Database Systems",
        "code": "CS-302",
        "credits": "3",
        "outline": "SQL and relational algebra.",
        "attendanceRequired": true,
      },
    ],
    "6th Sem": [
      {
        "title": "Software Engineering",
        "code": "SE-301",
        "credits": "3",
        "outline": "SDLC and agile methodologies.",
        "attendanceRequired": true,
      },
      {
        "title": "Computer Networks",
        "code": "CS-401",
        "credits": "4",
        "outline": "TCP/IP layers and routing.",
        "attendanceRequired": true,
      },
      {
        "title": "Artificial Intelligence",
        "code": "AI-401",
        "credits": "4",
        "outline": "Search algorithms and neural networks.",
        "attendanceRequired": true,
      },
    ],
    "8th Sem": [
      {
        "title": "Final Year Project",
        "code": "FYP-499",
        "credits": "6",
        "outline": "Practical implementation of a software project.",
        "attendanceRequired": true,
      },
      {
        "title": "Cloud Computing",
        "code": "CS-412",
        "credits": "3",
        "outline": "AWS and distributed systems.",
        "attendanceRequired": true,
      },
      {
        "title": "Professional Ethics",
        "code": "HU-401",
        "credits": "2",
        "outline": "Ethical standards in IT.",
        "attendanceRequired": false,
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Current list based on selection and search
    final allCourses = coursesBySemester[selectedSemester] ?? [];
    final currentCourses = allCourses.where((course) {
      final title = course['title']!.toLowerCase();
      final code = course['code']!.toLowerCase();
      return title.contains(searchQuery.toLowerCase()) ||
          code.contains(searchQuery.toLowerCase());
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Scheme of Study',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: Column(
          children: [
            // Header Selection Section (Animated)
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                decoration: const BoxDecoration(
                  color: ColorPallet.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SchemeInfoCard(
                              label: "Department",
                              value: selectedDepartment,
                              icon: Icons.account_balance_rounded,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: SchemeDropdownCard(
                              label: "Semester",
                              value: selectedSemester,
                              icon: Icons.calendar_today_rounded,
                              items: const [
                                "2nd Sem",
                                "4th Sem",
                                "6th Sem",
                                "8th Sem",
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedSemester = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search subject or code...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: ColorPallet.primaryBlue,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => searchQuery = "");
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$selectedSemester - Course List',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'Manage subjects for this semester',
                        style: TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                    ],
                  ),
                  AnimatedAddButton(
                    onTap: () => SchemeDialogs.showEditDialog(
                      context: context,
                      currentList: coursesBySemester[selectedSemester]!,
                      onUpdate: () => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            // Course List (Animated or Not Found)
            Expanded(
              child: currentCourses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 60,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No subjects found for '$searchQuery'",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Try searching with a different name or code",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: currentCourses.length,
                      itemBuilder: (context, index) {
                        final course = currentCourses[index];
                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          tween: Tween<double>(begin: 0, end: 1),
                          key: ValueKey(
                            "$selectedSemester-${course['code']}-$index",
                          ),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(50 * (1 - value), 0),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: SchemeCourseCard(
                            title: course['title']!,
                            code: course['code']!,
                            credits: course['credits']!,
                            onEdit: () => SchemeDialogs.showEditDialog(
                              context: context,
                              currentList: coursesBySemester[selectedSemester]!,
                              index: index,
                              onUpdate: () => setState(() {}),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
