import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Dashborad/add_subject_screen.dart';
import 'package:flutter/material.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  // Variable to keep track of selected filter
  String selectedFilter = "All";

  // Data List (Easily manageable)
  final List<Map<String, dynamic>> allSubjects = [
    {
      "title": "Computer Science - CS101",
      "assigned": "Grade 10-B",
      "syllabus": 0.75,
      "avg": "88%",
      "icon": Icons.laptop_mac_rounded,
      "grade": "Grade 10"
    },
    {
      "title": "Mathematics - MA102",
      "assigned": "Grade 10-A",
      "syllabus": 0.60,
      "avg": "92%",
      "icon": Icons.calculate_rounded,
      "percentCircle": 83,
      "grade": "Grade 10"
    },
    {
      "title": "Physics - PH103",
      "assigned": "Grade 11-B",
      "syllabus": 0.50,
      "avg": "80%",
      "icon": Icons.science_rounded,
      "percentCircle": 92,
      "grade": "Grade 11"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filtering logic
    List<Map<String, dynamic>> displayedSubjects = selectedFilter == "All"
        ? allSubjects
        : allSubjects.where((s) => s['grade'] == selectedFilter).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorPallet.primaryBlue,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 23),
            onPressed: () => Navigator.pop(context),
          ),        
          title: const Text("Subjects", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,fontSize: 18)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 1. Search Bar
          // --- Search Bar Section Fix ---
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: Container(
      height: 50, // Fixed height alignment ke liye behtar hai
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center, // Text aur icon ko center karne ke liye
        style: TextStyle(color: ColorPallet.deepBlue, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search subjects...',
          hintStyle: TextStyle(color: ColorPallet.primaryBlue.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: ColorPallet.primaryBlue, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10), // Inner padding alignment fix
        ),
      ),
        ),
      ),
            // 2. Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: [
                  _buildFilterButton("All"),
                  const SizedBox(width: 10),
                  _buildFilterButton("Grade 11"),
                  const Spacer(),
                  // Add Button
                 // Filter & Add Button Row mein Add button ka code:
      GestureDetector(
        onTap: () async {
      // Naye screen par jana aur wahan se data wapis lena
      final newSubject = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddSubjectScreen()),
      );
      
      if (newSubject != null) {
        setState(() {
          allSubjects.add(newSubject);
        });
      }
        },
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF42A5F5), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.add, color: Colors.white, size: 18),
          Text(" Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
        ),
      ),  ],
              ),
            ),
      
            const SizedBox(height: 15),
      
            // 3. White Container for Cards
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 25),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: displayedSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = displayedSubjects[index];
                    return _buildSubjectCard(
                      title: subject['title'],
                      assigned: subject['assigned'],
                      syllabus: subject['syllabus'],
                      avg: subject['avg'],
                      icon: subject['icon'],
                      percentCircle: subject['percentCircle'],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter Button Widget
  Widget _buildFilterButton(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? ColorPallet.primaryBlue : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? ColorPallet.primaryBlue : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Subject Card Widget
  Widget _buildSubjectCard({
    required String title,
    required String assigned,
    required double syllabus,
    required String avg,
    required IconData icon,
    int? percentCircle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2196F3), size: 24),
          ),
          const SizedBox(width: 15),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: ColorPallet.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("Assigned: $assigned", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                // Syllabus Progress
                Row(
                  children: [
                    const Text("Syllabus", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: syllabus,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("${(syllabus * 100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          // Circular Progress for Attendance
          if (percentCircle != null) ...[
            const SizedBox(width: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 35,
                  width: 35,
                  child: CircularProgressIndicator(
                    value: percentCircle / 100,
                    strokeWidth: 3,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                  ),
                ),
                Text("$percentCircle%", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            )
          ]
        ],
      ),
    );
  }
}