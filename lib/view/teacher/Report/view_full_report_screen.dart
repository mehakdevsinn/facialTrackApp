import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class FullReportScreen extends StatefulWidget {
  final String month;
  final String subject;

  const FullReportScreen({super.key, required this.month, required this.subject});

  @override
  State<FullReportScreen> createState() => _FullReportScreenState();
}

class _FullReportScreenState extends State<FullReportScreen> {
  // Dummy data for the list
  final List<Map<String, dynamic>> students = [
    {"name": "Jane Doe", "present": 22, "absent": 2, "percent": 91},
    {"name": "Lisa Davis", "present": 18, "absent": 6, "percent": 75},
    {"name": "Mike King", "present": 15, "absent": 9, "percent": 62},
    {"name": "Alex Smith", "present": 24, "absent": 0, "percent": 100},
    {"name": "John Wick", "present": 20, "absent": 4, "percent": 83},
    {"name": "Sarah Connor", "present": 12, "absent": 12, "percent": 50},
    {"name": "Peter Parker", "present": 21, "absent": 3, "percent": 87},
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Filter logic
    List<Map<String, dynamic>> filteredStudents = students
        .where((s) => s['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
                  backgroundColor: ColorPallet.primaryBlue,
      
          title: Column(
            children: [
              const Text("Detailed Attendance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              Text("${widget.subject} • ${widget.month}", style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // 1. Search Bar Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search student name...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF1A4B8F)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
      
            // 2. Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: const [
                  Expanded(flex: 3, child: Text("STUDENT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 1, child: Text("P", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal))),
                  Expanded(flex: 1, child: Text("A", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange))),
                  Expanded(flex: 2, child: Text("STATUS", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                ],
              ),
            ),
      
            // 3. Main List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  bool isLow = student['percent'] < 75;
      
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar & Name
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF1A4B8F).withOpacity(0.1),
                                child: Text(student['name'][0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A4B8F))),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, overflow: TextOverflow.ellipsis)),
                              ),
                            ],
                          ),
                        ),
                        // Present count
                        Expanded(child: Text("${student['present']}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
                        // Absent count
                        Expanded(child: Text("${student['absent']}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                        // Percent Badge
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isLow ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${student['percent']}%",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isLow ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}