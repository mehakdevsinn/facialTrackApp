import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class AddEditSemesterScreen extends StatefulWidget {
  final Map<String, dynamic>? semester;
  final bool isEditing;

  const AddEditSemesterScreen({
    super.key,
    this.semester,
    this.isEditing = false,
  });

  @override
  State<AddEditSemesterScreen> createState() => _AddEditSemesterScreenState();
}

class _AddEditSemesterScreenState extends State<AddEditSemesterScreen> {
  late TextEditingController nameController;
  late String selectedType;
  late DateTime startDate;
  late DateTime endDate;
  late String status;
  late List<int> activeSemesters;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.isEditing ? widget.semester!['name'] : "",
    );
    selectedType = widget.isEditing ? widget.semester!['type'] : "Spring";
    startDate = widget.isEditing
        ? DateTime.parse(widget.semester!['startDate'])
        : DateTime.now();
    endDate = widget.isEditing
        ? DateTime.parse(widget.semester!['endDate'])
        : DateTime.now().add(const Duration(days: 120));
    status = widget.isEditing ? widget.semester!['status'] : "Upcoming";

    // Default: Spring -> Evens, Fall -> Odds
    activeSemesters = widget.isEditing
        ? List<int>.from(widget.semester!['activeSemesters'] ?? [])
        : [2, 4, 6, 8];

    // Initial sync if new
    if (!widget.isEditing) {
      updateSemestersBasedOnType(selectedType);
    }
  }

  void updateSemestersBasedOnType(String type) {
    if (type == "Spring") {
      activeSemesters = [2, 4, 6, 8];
    } else if (type == "Fall") {
      activeSemesters = [1, 3, 5, 7];
    } else {
      activeSemesters = [];
    }
    setState(() {});
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: Text(
          widget.isEditing ? "Edit Semester" : "Add New Semester",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Semester Name
            const Text(
              "Semester Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
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
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Semester Name (e.g. Spring 2024)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: "Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: const [
                      DropdownMenuItem(value: "Spring", child: Text("Spring")),
                      DropdownMenuItem(value: "Fall", child: Text("Fall")),
                      DropdownMenuItem(value: "Summer", child: Text("Summer")),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedType = val!;
                        updateSemestersBasedOnType(selectedType);
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              "Duration & Status",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
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
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => startDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Start Date",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            child: Text(
                              "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => endDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "End Date",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            child: Text(
                              "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: const [
                      DropdownMenuItem(value: "Active", child: Text("Active")),
                      DropdownMenuItem(
                        value: "Upcoming",
                        child: Text("Upcoming"),
                      ),
                      DropdownMenuItem(
                        value: "Completed",
                        child: Text("Completed"),
                      ),
                    ],
                    onChanged: (val) => setState(() => status = val!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              "Active Study Semesters",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select the semesters that are currently in session for this term.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              ),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.center,
                children: List.generate(8, (index) {
                  int semesterNum = index + 1;
                  bool isSelected = activeSemesters.contains(semesterNum);
                  return FilterChip(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    label: Text("${semesterNum}th Semester"),
                    selected: isSelected,
                    selectedColor: ColorPallet.primaryBlue,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          activeSemesters.add(semesterNum);
                          activeSemesters.sort();
                        } else {
                          activeSemesters.remove(semesterNum);
                        }
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPallet.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: ColorPallet.primaryBlue.withOpacity(0.4),
                ),
                onPressed: () {
                  final newSemester = {
                    "name": nameController.text,
                    "type": selectedType,
                    "year": startDate.year.toString(),
                    "startDate": startDate.toString().split(' ')[0],
                    "endDate": endDate.toString().split(' ')[0],
                    "status": status,
                    "activeSemesters": activeSemesters,
                  };
                  Navigator.pop(context, newSemester);
                },
                child: Text(
                  widget.isEditing ? "Update Semester" : "Create Semester",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
