import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/course_model.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/utils/widgets/scheme_widgets.dart';
import 'package:facialtrackapp/view/Admin/Scheme%20of%20Study/add_edit_subject_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SchemeOfStudyScreen extends StatefulWidget {
  const SchemeOfStudyScreen({super.key});

  @override
  State<SchemeOfStudyScreen> createState() => _SchemeOfStudyScreenState();
}

class _SchemeOfStudyScreenState extends State<SchemeOfStudyScreen> {
  SemesterModel? selectedSemester;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final provider = context.read<AdminProvider>();
      provider.fetchSemesters().then((_) {
        if (provider.semesters.isNotEmpty && mounted) {
          setState(() {
            selectedSemester = provider.semesters.first;
          });
          provider.fetchCourses(selectedSemester!.id);
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSemesterChanged(String? newDisplayName, AdminProvider provider) {
    if (newDisplayName == null) return;
    final newSem =
        provider.semesters.firstWhere((s) => s.displayName == newDisplayName);
    setState(() {
      selectedSemester = newSem;
    });
    provider.fetchCourses(newSem.id);
  }

  void _navigateToAddEdit({CourseModel? course}) {
    if (selectedSemester == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSubjectScreen(
          semesterId: selectedSemester!.id,
          initialCourse: course,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        body: Consumer<AdminProvider>(
          builder: (context, provider, child) {
            if (provider.isSemestersLoading && provider.semesters.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.semesters.isEmpty) {
              return const Center(child: Text("No semesters available."));
            }

            // Fallback if not set
            selectedSemester ??= provider.semesters.first;

            final allCourses =
                provider.getCoursesForSemester(selectedSemester!.id);
            final isLoadingCourses =
                provider.isCoursesLoading(selectedSemester!.id);

            final currentCourses = allCourses.where((course) {
              final title = course.name.toLowerCase();
              final code = course.code.toLowerCase();
              return title.contains(searchQuery.toLowerCase()) ||
                  code.contains(searchQuery.toLowerCase());
            }).toList();

            return Column(
              children: [
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
                              const Expanded(
                                child: SchemeInfoCard(
                                  label: "Department",
                                  value: "Computer Science",
                                  icon: Icons.account_balance_rounded,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: SchemeDropdownCard(
                                  label: "Semester",
                                  value: selectedSemester!.displayName,
                                  icon: Icons.calendar_today_rounded,
                                  items: provider.semesters
                                      .map((s) => s.displayName)
                                      .toList(),
                                  onChanged: (val) =>
                                      _onSemesterChanged(val, provider),
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
                            'Course List',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            'Manage subjects for this semester',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      AnimatedAddButton(
                        onTap: () => _navigateToAddEdit(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoadingCourses
                      ? const Center(child: CircularProgressIndicator())
                      : currentCourses.isEmpty
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
                                    searchQuery.isEmpty
                                        ? "No courses found."
                                        : "No subjects found for '$searchQuery'",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: currentCourses.length,
                              itemBuilder: (context, index) {
                                final course = currentCourses[index];
                                return TweenAnimationBuilder(
                                  duration: Duration(
                                      milliseconds: 400 + (index * 100)),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  key: ValueKey(course.id),
                                  builder: (context, double value, child) {
                                    return Transform.translate(
                                      offset: Offset(50 * (1 - value), 0),
                                      child:
                                          Opacity(opacity: value, child: child),
                                    );
                                  },
                                  child: SchemeCourseCard(
                                    title: course.name,
                                    code: course.code,
                                    credits: course.creditHours.toString(),
                                    onEdit: () =>
                                        _navigateToAddEdit(course: course),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
