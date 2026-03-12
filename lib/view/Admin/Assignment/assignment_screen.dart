import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/assignment_model.dart';
import 'package:facialtrackapp/view/Admin/Assignment/edit_workload_screen.dart';
import 'package:facialtrackapp/view/Admin/Course%20Assignment/course_assignment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final p = context.read<AdminProvider>();
      p.fetchAssignments();
      p.fetchAllCoursesCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Group assignments by teacher id
  List<Map<String, dynamic>> _groupByTeacher(
      List<AssignmentModel> assignments) {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final a in assignments) {
      final tid = a.teacher.id;
      if (!grouped.containsKey(tid)) {
        grouped[tid] = {
          'teacherId': tid,
          'teacherName': a.teacher.fullName,
          'teacherDesignation': a.teacher.designation,
          'initials': a.teacher.initials,
          'assignments': <AssignmentModel>[],
        };
      }
      (grouped[tid]!['assignments'] as List<AssignmentModel>).add(a);
    }
    return grouped.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final allAssignments = provider.assignments;
        final filtered = allAssignments.where((a) {
          final name = a.teacher.fullName.toLowerCase();
          final course = a.course.name.toLowerCase();
          return name.contains(_searchQuery.toLowerCase()) ||
              course.contains(_searchQuery.toLowerCase());
        }).toList();
        final grouped = _groupByTeacher(filtered);

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 230,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: ColorPallet.primaryBlue,
                  title: const Text(
                    "Course Allotment",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        color: ColorPallet.primaryBlue,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStat("Staff", grouped.length.toString(),
                                      Icons.people_rounded),
                                  Container(
                                      width: 1.5,
                                      height: 18,
                                      color: Colors.white.withOpacity(0.1)),
                                  _buildStat(
                                      "Courses",
                                      provider.isAllCoursesCountLoading
                                          ? '…'
                                          : provider.allCoursesCount.toString(),
                                      Icons.book_rounded),
                                  Container(
                                      width: 1.5,
                                      height: 18,
                                      color: Colors.white.withOpacity(0.1)),
                                  _buildStat("Term", "2024",
                                      Icons.calendar_month_rounded),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5))
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) =>
                                    setState(() => _searchQuery = value),
                                decoration: InputDecoration(
                                  hintText: 'Search teacher or subject...',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14),
                                  prefixIcon: const Icon(Icons.search,
                                      color: ColorPallet.primaryBlue),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon:
                                              const Icon(Icons.close, size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = "");
                                          })
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (provider.isAssignmentsLoading)
                  const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()))
                else if (provider.assignmentsError != null)
                  SliverFillRemaining(
                      child: Center(
                          child: Text(provider.assignmentsError!,
                              style: const TextStyle(color: Colors.redAccent))))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: grouped.isEmpty
                        ? SliverFillRemaining(child: _buildEmptyState())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildTeacherCard(grouped[index], provider),
                              childCount: grouped.length,
                            ),
                          ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    child: _buildManageButton(provider),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900)),
        Text(label.toUpperCase(),
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8)),
      ],
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> data, AdminProvider provider) {
    final teacherAssignments = data['assignments'] as List<AssignmentModel>;
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: ColorPallet.primaryBlue.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditWorkloadScreen(
                    teacherId: data['teacherId'],
                    teacherName: data['teacherName'],
                    teacherDesignation: data['teacherDesignation'],
                    initials: data['initials'],
                    assignments: teacherAssignments,
                  ),
                ),
              );
              if (mounted) {
                context.read<AdminProvider>().fetchAssignments(force: true);
              }
            },
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: ColorPallet.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(data['initials'],
                              style: const TextStyle(
                                  color: ColorPallet.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['teacherName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                    color: Color(0xFF1E293B))),
                            Text(data['teacherDesignation'],
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: ColorPallet.primaryBlue.withOpacity(0.05),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.edit_note_rounded,
                            size: 20, color: ColorPallet.primaryBlue),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Column(
                    children: teacherAssignments.map((a) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_mosaic_rounded,
                                color: ColorPallet.primaryBlue, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.course.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: Color(0xFF334155))),
                                  Text(
                                    "Section ${a.section}",
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Text(a.course.code,
                                  style: const TextStyle(
                                      color: ColorPallet.primaryBlue,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageButton(AdminProvider provider) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)), child: child)),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: ColorPallet.primaryBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: ColorPallet.primaryBlue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CourseAssignmentScreen()),
              );
              if (mounted) {
                context.read<AdminProvider>().fetchAssignments(force: true);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_task_outlined, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text("MANAGE ALLOTMENT",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_ind_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text("No Workloads Assigned",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text("Tap MANAGE ALLOTMENT to add a new one",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
