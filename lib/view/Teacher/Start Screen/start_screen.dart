import 'package:flutter/material.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  String? selectedClass;
  String? selectedSubject;

  final List<String> classes = [
    'Class 10A',
    'Class 10B',
    'Class 11A',
    'Class 11B',
  ];

  final List<String> subjects = [
    'Mathematics',
    'Computer Science',
    'Physics',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xff1F5EFF),
        elevation: 0,
        title: const Text(
          'Start Attendance Session',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        leading: const Icon(Icons.arrow_back),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.settings),
          )
        ],
      ),

      /// BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Start New Session',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select class and subject to begin attendance',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// SELECT CLASS
            const Text('Select Class'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Class 10A'),
                  value: selectedClass,
                  isExpanded: true,
                  items: classes
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              const Icon(Icons.class_, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(e),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedClass = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// SELECT SUBJECT
            const Text('Select Subject'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Choose subject'),
                  value: selectedSubject,
                  isExpanded: true,
                  items: subjects
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedSubject = value);
                  },
                ),
              ),
            ),

            const Spacer(),

            /// START BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Start Session',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM BAR (STATIC LOOK)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.play_circle), label: 'Start Session'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
