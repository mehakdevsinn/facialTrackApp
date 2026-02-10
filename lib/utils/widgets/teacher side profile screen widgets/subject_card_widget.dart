import 'package:flutter/material.dart';

class SubjectsCard extends StatelessWidget {
  const SubjectsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          
          // Subject 1
          _subjectTile(
            Icons.book,
            "Computer Science",
            "BSCS - Semester 5",
            Colors.blue,
          ),
          const Divider(),
          
          // Subject 2
          _subjectTile(
            Icons.menu_book,
            "Data Structures",
            "BSCS - Semester 5",
            Colors.green,
          ),
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