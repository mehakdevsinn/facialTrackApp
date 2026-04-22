import 'package:flutter/material.dart';
import 'package:facialtrackapp/core/models/teacher_profile_summary_model.dart';

class SubjectsCard extends StatelessWidget {
  final List<TeacherAssignedSubject> subjects;
  const SubjectsCard({super.key, required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Subjects Assigned",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          if (subjects.isEmpty)
            Text(
              'No subjects assigned yet.',
              style: TextStyle(color: Colors.grey.shade600),
            )
          else
            ...List.generate(subjects.length, (index) {
              final subject = subjects[index];
              final palette = [
                Colors.blue,
                Colors.green,
                Colors.deepPurple,
                Colors.orange,
                Colors.teal,
              ];
              final color = palette[index % palette.length];
              return Column(
                children: [
                  _subjectTile(
                    Icons.book,
                    '${subject.courseCode} - ${subject.courseName}',
                    'Section ${subject.section} • ${subject.semesterLabel} • ${subject.academicSession}',
                    color,
                  ),
                  if (index != subjects.length - 1) const Divider(),
                ],
              );
            }),
        ],
      ),
    );
  }

  // Helper widget jo sirf is file ke andar use hoga
  Widget _subjectTile(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title, 
        style: const TextStyle(fontWeight: FontWeight.bold)
      ),
      subtitle: Text(subtitle),
    );
  }
}
