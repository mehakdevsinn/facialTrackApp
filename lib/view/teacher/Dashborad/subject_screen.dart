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
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = "All";
  String searchQuery = "";

  // Data List (Easily manageable)
  final List<Map<String, dynamic>> allSubjects = [
    {
      "title": "Computer Science - CS101",
      "assigned": "Semester 2",
      "icon": Icons.laptop_mac_rounded,
            "percentCircle": 83,
      "avg": "92%",

      "grade": "Semester 2"
      
    },
    {
      "title": "Mathematics - MA102",
      "assigned": "Semester 4",
      "syllabus": 0.60,
      "avg": "92%",
      "icon": Icons.calculate_rounded,
      "percentCircle": 83,
      "grade": "Semester 4"
    },
    {
      "title": "Physics - PH103",
      "assigned": "Semester 6",
      "syllabus": 0.50,
      "avg": "80%",
      "icon": Icons.science_rounded,
      "percentCircle": 92,
      "grade": "Semester 6"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filtering logic
   List<Map<String, dynamic>> displayedSubjects = allSubjects.where((subject) {
    // Grade check: Agar "All" hai toh true, warna grade match honi chahiye
    bool matchesGrade = selectedFilter == "All" || subject['grade'] == selectedFilter;

    bool matchesSearch = subject['title'].toLowerCase().contains(searchQuery) || 
                         subject['assigned'].toLowerCase().contains(searchQuery);

    return matchesGrade && matchesSearch;
  }).toList();

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
  controller: _searchController, // Controller add kiya
  onChanged: (value) {
    setState(() {
      searchQuery = value.toLowerCase(); // Search query update ki
    });
  },
  textAlignVertical: TextAlignVertical.center,
  style: TextStyle(color: ColorPallet.deepBlue, fontSize: 16),
  decoration: InputDecoration(
    hintText: 'Search subjects...',
    hintStyle: TextStyle(color: ColorPallet.primaryBlue.withOpacity(0.5)),
    prefixIcon: Icon(Icons.search, color: ColorPallet.primaryBlue, size: 22),
    // Clear button agar user search khatam karna chahe
    suffixIcon: searchQuery.isNotEmpty 
        ? IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () {
              _searchController.clear();
              setState(() => searchQuery = "");
            },
          ) 
        : null,
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
                  _buildFilterButton("Semester 2"),
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
                child: 
                displayedSubjects.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  "No subjects found for '$searchQuery'",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          )
        :
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: displayedSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = displayedSubjects[index];
                    return _buildSubjectCard(
                      title: subject['title'],
                      assigned: subject['assigned'],
                      // syllabus: subject['syllabus'],
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
    // required double syllabus,
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
                // Row(
                //   children: [
                //     const Text("Syllabus", style: TextStyle(fontSize: 10, color: Colors.grey)),
                //     const SizedBox(width: 8),
                //     Expanded(
                //       child: ClipRRect(
                //         borderRadius: BorderRadius.circular(5),
                //         child: LinearProgressIndicator(
                //           value: syllabus,
                //           backgroundColor: Colors.grey.shade100,
                //           valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                //           minHeight: 5,
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 8),
                //     Text("${(syllabus * 100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                //   ],
                // ),
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