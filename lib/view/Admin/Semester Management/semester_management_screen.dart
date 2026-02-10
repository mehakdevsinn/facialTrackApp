import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Admin/Semester Management/add_edit_semester_screen.dart';
import 'package:flutter/material.dart';

class SemesterManagementScreen extends StatefulWidget {
  const SemesterManagementScreen({super.key});

  @override
  State<SemesterManagementScreen> createState() =>
      _SemesterManagementScreenState();
}

class _SemesterManagementScreenState extends State<SemesterManagementScreen> {
  final List<Map<String, dynamic>> _semesters = [
    {
      "name": "Spring 2026",
      "type": "Spring",
      "year": "2024",
      "startDate": "2024-02-01",
      "endDate": "2024-06-15",
      "status": "Active",
      "activeSemesters": [2, 4, 6, 8],
    },
    {
      "name": "Fall 2025",
      "type": "Fall",
      "year": "2023",
      "startDate": "2023-09-01",
      "endDate": "2024-01-15",
      "status": "Completed",
      "activeSemesters": [1, 3, 5, 7],
    },
  ];

  Future<void> _navigateToEditScreen({
    Map<String, dynamic>? semester,
    int? index,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSemesterScreen(
          semester: semester,
          isEditing: semester != null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (semester != null && index != null) {
          _semesters[index] = result;
        } else {
          if (result['status'] == "Active") {
            for (var sem in _semesters) {
              if (sem['status'] == "Active") sem['status'] = "Completed";
            }
          }
          _semesters.insert(0, result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Semester Management",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToEditScreen(),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: ColorPallet.white,
          icon: const Icon(Icons.add),
          label: const Text("New Semester"),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _semesters.length,
          itemBuilder: (context, index) {
            final sem = _semesters[index];
            final bool isActive = sem['status'] == 'Active';
            final List<int> activeSems = List<int>.from(
              sem['activeSemesters'] ?? [],
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: isActive
                    ? Border.all(color: ColorPallet.primaryBlue, width: 2)
                    : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        sem['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Active",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (sem['status'] == "Completed")
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Completed",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (sem['status'] == "Upcoming")
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Upcoming",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${sem['startDate']} - ${sem['endDate']}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          Icons.school,
                          size: 14,
                          color: ColorPallet.primaryBlue,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Study Semesters: ${activeSems.join(', ')}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColorPallet.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: ColorPallet.primaryBlue,
                  ),
                  onPressed: () =>
                      _navigateToEditScreen(semester: sem, index: index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
