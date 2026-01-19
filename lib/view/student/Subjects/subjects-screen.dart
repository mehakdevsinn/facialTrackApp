import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/student/Subjects/subject-detail.dart';
import 'package:flutter/material.dart';

class Subject {
  final String subject;
  final String teacher;
  final String code;
  final int attendance;
  final int presentDays;
  final int absentDays;
  final Color color;

  Subject({
    required this.subject,
    required this.teacher,
    required this.code,
    required this.attendance,
    required this.presentDays,
    required this.absentDays,
    required this.color,
  });
}

class MySubjectsScreen extends StatefulWidget {
  const MySubjectsScreen({super.key});

  @override
  State<MySubjectsScreen> createState() => _MySubjectsScreenState();
}

class _MySubjectsScreenState extends State<MySubjectsScreen> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  List<Subject> allSubjects = [
    Subject(
      subject: "Computer Science",
      teacher: "Prof. Ahmed Khan",
      code: "CS101",
      attendance: 92,
      presentDays: 23,
      absentDays: 2,
      color: Colors.blue,
    ),
    Subject(
      subject: "Physics",
      teacher: "Mr. Hassan",
      code: "PHY101",
      attendance: 65,
      presentDays: 13,
      absentDays: 7,
      color: Colors.green,
    ),
    Subject(
      subject: "Chemistry",
      teacher: "Dr. Usman",
      code: "CHEM101",
      attendance: 78,
      presentDays: 14,
      absentDays: 4,
      color: Colors.orange,
    ),
  ];

  late List<Subject> filteredSubjects;

  @override
  void initState() {
    super.initState();
    filteredSubjects = List.from(allSubjects);

    searchController.addListener(() {
      filterSubjects();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 243, 243),

        body: Stack(
          children: [
            Container(
              height: isSearching ? 80 : 108,
              color: ColorPallet.primaryBlue,

              // child: Padding(
              //   padding: const EdgeInsets.only(top: 22, left: 18, right: 18),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,

              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         "My Subjects",
              //         style: TextStyle(color: ColorPallet.white, fontSize: 20),
              //       ),

              //       Icon(Icons.search, size: 30, color: ColorPallet.white),
              //     ],
              //   ),
              // ),
            ),

            Positioned(
              top: isSearching ? 18 : 22,
              left: 18,
              right: 18,
              child: isSearching ? buildSearchField() : buildHeader(),
            ),

            // Stats Card (hide during search)
            if (!isSearching) ...[
              // Positioned(top: 70, left: 16, right: 16, child: buildHeader()),
              Positioned(
                top: 70,
                left: 16,
                right: 16,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, right: 22),
                  child: Container(
                    width: double.infinity,

                    padding: EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: 14,
                      bottom: 15,
                    ),
                    decoration: BoxDecoration(
                      color: ColorPallet.white,

                      borderRadius: BorderRadius.all(Radius.circular(16)),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.withOpacity(0.15),
                              child: Icon(Icons.menu_book, color: Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "5 Subjects",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                          child: VerticalDivider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),

                        Column(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.withOpacity(0.15),
                              child: Icon(Icons.menu_book, color: Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "5 Subjects",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                          child: VerticalDivider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),

                        Column(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue.withOpacity(0.15),
                              child: Icon(Icons.menu_book, color: Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "5 Subjects",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            Padding(
              padding: EdgeInsets.only(top: isSearching ? 120 : 180),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredSubjects.length,
                itemBuilder: (context, index) {
                  final sub = filteredSubjects[index];
                  return SubjectCard(
                    subject: sub.subject,
                    teacher: sub.teacher,
                    code: sub.code,
                    attendance: sub.attendance,
                    presentDays: sub.presentDays,
                    absentDays: sub.absentDays,
                    color: sub.color,
                  );
                },
              ),
            ),

            // Padding(
            //   padding: EdgeInsets.only(top: isSearching ? 120 : 180),
            //   child: ListView(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     children: const [
            //       SubjectCard(
            //         subject: "Computer Science",
            //         teacher: "Prof. Ahmed Khan",
            //         code: "CS101",
            //         attendance: 92,
            //         presentDays: 23,
            //         absentDays: 2,
            //         color: Colors.blue,
            //       ),
            //       SubjectCard(
            //         subject: "Physics",
            //         teacher: "Mr. Hassan",
            //         code: "PHY101",
            //         attendance: 65,
            //         presentDays: 13,
            //         absentDays: 7,
            //         color: Colors.green,
            //       ),
            //       SubjectCard(
            //         subject: "Chemistry",
            //         teacher: "Dr. Usman",
            //         code: "CHEM101",
            //         attendance: 78,
            //         presentDays: 14,
            //         absentDays: 4,
            //         color: Colors.orange,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void filterSubjects() {
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredSubjects = List.from(allSubjects);
      } else {
        filteredSubjects = allSubjects.where((subject) {
          return subject.subject.toLowerCase().contains(query) ||
              subject.teacher.toLowerCase().contains(query) ||
              subject.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Widget buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search subjects...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              isSearching = false;
              searchController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "My Subjects",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search, size: 30, color: Colors.white),
          onPressed: () {
            setState(() => isSearching = true);
          },
        ),
      ],
    );
  }
}

class SubjectCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String code;
  final int attendance;
  final int presentDays;
  final int absentDays;
  final Color color;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.teacher,
    required this.code,
    required this.attendance,
    required this.presentDays,
    required this.absentDays,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailScreen(
              color: color,
              subject: subject,
              teacher: teacher,
              attendance: attendance,
              presentDays: presentDays,
              absentDays: absentDays,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color,
                  child: Text(
                    subject.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Attendance Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 54,
                      width: 54,
                      child: CircularProgressIndicator(
                        value: attendance / 100,
                        strokeWidth: 6,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$attendance%",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Attendance",
                          style: TextStyle(fontSize: 8, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    teacher,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      _infoDot(
                        Colors.green,
                        "$presentDays days",
                        "Present",
                        context,
                      ),
                      const SizedBox(width: 16),

                      _infoDot(
                        Colors.red,
                        "$absentDays days",
                        "Absent",
                        context,
                      ),
                      Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoDot(Color color, String value, String label, context) {
    Size size = MediaQuery.of(context).size;
    return size.width <= 350
        ? Column(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 4),
              Text(value, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          )
        : Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 4),
              Text(value, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          );
  }
}
