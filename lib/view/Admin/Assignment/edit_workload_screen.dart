import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/assignment_data_service.dart';
import 'package:facialtrackapp/view/Admin/Course%20Assignment/assign_subject_screen.dart';
import 'package:flutter/material.dart';

class EditWorkloadScreen extends StatefulWidget {
  final Map<String, dynamic> teacherData;
  const EditWorkloadScreen({super.key, required this.teacherData});

  @override
  State<EditWorkloadScreen> createState() => _EditWorkloadScreenState();
}

class _EditWorkloadScreenState extends State<EditWorkloadScreen> {
  late List<Map<String, dynamic>> assignedSubjects;
  late Map<String, dynamic> currentTeacher;

  @override
  void initState() {
    super.initState();
    assignedSubjects = List<Map<String, dynamic>>.from(
      widget.teacherData['subjects'],
    );
    currentTeacher = Map<String, dynamic>.from(widget.teacherData);
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Edit Teacher Workload",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          actions: [
            IconButton(
              onPressed: () => _openAssignScreen(),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            InkWell(
              onTap: _showTeacherSelectionDialog,
              child: _buildTeacherHeader(),
            ),
            Expanded(
              child: assignedSubjects.isEmpty
                  ? _buildEmptyState()
                  : _buildSubjectList(),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
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
            child: Text(
              currentTeacher['initials'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTeacher['teacherName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                Text(
                  currentTeacher['teacherDesignation'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showTeacherSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Change Faculty",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: ColorPallet.primaryBlue,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Select another teacher for this workload",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: AssignmentDataService.availableTeachers.map((t) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: ColorPallet.primaryBlue.withOpacity(0.1),
                      child: Text(
                        t['initials']!,
                        style: const TextStyle(
                          color: ColorPallet.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      t['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      t['designation']!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      setState(() {
                        currentTeacher['teacherName'] = t['name'];
                        currentTeacher['teacherDesignation'] = t['designation'];
                        currentTeacher['initials'] = t['initials'];
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: assignedSubjects.length,
      itemBuilder: (context, index) {
        final sub = assignedSubjects[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorPallet.primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_mosaic_rounded,
                color: ColorPallet.primaryBlue,
                size: 20,
              ),
            ),
            title: Text(
              sub['course'],
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              "${sub['semester']} • ${sub['section']}",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                  onPressed: () => _openAssignScreen(index: index),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => assignedSubjects.removeAt(index)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAssignScreen({int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignSubjectScreen(
          teacherName: currentTeacher['teacherName'],
          initialData: index != null ? assignedSubjects[index] : null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (index != null) {
          assignedSubjects[index] = result;
        } else {
          assignedSubjects.add(result);
        }
      });
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 60, color: Colors.grey.shade200),
          const SizedBox(height: 15),
          Text(
            "No subjects assigned",
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPallet.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 8,
          ),
          onPressed: () {
            final updatedData = {
              ...currentTeacher,
              "subjects": assignedSubjects,
            };

            // Save to central memory
            AssignmentDataService.updateAssignment(
              updatedData,
              originalTeacherName: widget.teacherData['teacherName'],
            );

            // Give visual feedback to the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Workload Updated Successfully!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            // Small delay to let user see the message before closing
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) Navigator.pop(context, true);
            });
          },
          child: const Text(
            "SAVE CHANGES",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
