import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/assignment_model.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Screen for editing the subject assignments for a specific teacher.
/// All changes (delete, section update, teacher swap) are sent via API.
class EditWorkloadScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final String teacherDesignation;
  final String initials;
  final List<AssignmentModel> assignments;

  const EditWorkloadScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.teacherDesignation,
    required this.initials,
    required this.assignments,
  });

  @override
  State<EditWorkloadScreen> createState() => _EditWorkloadScreenState();
}

class _EditWorkloadScreenState extends State<EditWorkloadScreen> {
  late String currentTeacherId;
  late String currentTeacherName;
  late String currentTeacherDesignation;
  late String currentInitials;

  static const List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    currentTeacherId = widget.teacherId;
    currentTeacherName = widget.teacherName;
    currentTeacherDesignation = widget.teacherDesignation;
    currentInitials = widget.initials;

    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().fetchTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final myAssignments = provider.assignments
            .where((a) => a.teacher.id == currentTeacherId)
            .toList();

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              elevation: 0,
              backgroundColor: ColorPallet.primaryBlue,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text("Edit Teacher Workload",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
            body: Column(
              children: [
                InkWell(
                  onTap: () => _showTeacherPicker(provider, myAssignments),
                  child: _buildTeacherHeader(),
                ),
                Expanded(
                  child: myAssignments.isEmpty
                      ? _buildEmptyState()
                      : _buildSubjectList(myAssignments, provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeacherHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(currentInitials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currentTeacherName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20)),
                Text(currentTeacherDesignation,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.swap_horiz_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  void _showTeacherPicker(
      AdminProvider provider, List<AssignmentModel> myAssignments) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Change Faculty",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: ColorPallet.primaryBlue)),
            const SizedBox(height: 5),
            Text("Select another teacher for this workload",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 20),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: provider.teachers
                    .where((t) => t.id != currentTeacherId)
                    .map((t) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                ColorPallet.primaryBlue.withOpacity(0.1),
                            child: Text(_initials(t.fullName),
                                style: const TextStyle(
                                    color: ColorPallet.primaryBlue,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(t.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Text(t.designation ?? 'Teacher',
                              style: const TextStyle(fontSize: 12)),
                          onTap: () async {
                            Navigator.pop(context);
                            await _reassignAllToTeacher(
                                t, myAssignments, provider);
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Reassigns all current assignments of old teacher to a new teacher
  Future<void> _reassignAllToTeacher(UserModel newTeacher,
      List<AssignmentModel> myAssignments, AdminProvider provider) async {
    for (final a in myAssignments) {
      await provider.updateAssignment(
        assignmentId: a.id,
        teacherId: newTeacher.id,
      );
    }
    if (!mounted) return;
    setState(() {
      currentTeacherId = newTeacher.id;
      currentTeacherName = newTeacher.fullName;
      currentTeacherDesignation = newTeacher.designation ?? 'Teacher';
      currentInitials = _initials(newTeacher.fullName);
    });
    final name = newTeacher.fullName;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reassigned to $name"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSubjectList(
      List<AssignmentModel> myAssignments, AdminProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: myAssignments.length,
      itemBuilder: (context, index) {
        final a = myAssignments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: ColorPallet.primaryBlue.withOpacity(0.08),
                  shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_mosaic_rounded,
                  color: ColorPallet.primaryBlue, size: 20),
            ),
            title: Text(a.course.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF1E293B))),
            subtitle: Text("${a.course.code} • Section ${a.section}",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit section
                PopupMenuButton<String>(
                  icon: const Icon(Icons.edit_rounded,
                      color: Colors.blue, size: 20),
                  tooltip: "Change Section",
                  onSelected: (newSection) async {
                    final ok = await provider.updateAssignment(
                      assignmentId: a.id,
                      section: newSection,
                    );
                    if (!mounted) return;
                    final errMsg = provider.errorMessage ?? "Update failed";
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(errMsg),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  },
                  itemBuilder: (_) => _sections
                      .map((s) =>
                          PopupMenuItem(value: s, child: Text("Section $s")))
                      .toList(),
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 20),
                  onPressed: () => _confirmDelete(a, provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(AssignmentModel a, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove Assignment"),
        content: Text(
            "Remove ${a.course.name} (Section ${a.section}) from $currentTeacherName?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await provider.deleteAssignment(a.id);
              if (!mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(provider.errorMessage ?? "Delete failed"),
                  backgroundColor: Colors.redAccent,
                ));
              }
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 60, color: Colors.grey.shade200),
          const SizedBox(height: 15),
          Text("No subjects assigned",
              style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
