// import 'package:facialtrackapp/constants/color_pallet.dart';
// import 'package:flutter/material.dart';

// // 1. Create a Teacher model to handle data easily
// class Teacher {
//   final String name, dept, email, initials, status;
//   final Color statusColor;

//   Teacher({
//     required this.name,
//     required this.dept,
//     required this.email,
//     required this.initials,
//     required this.status,
//     required this.statusColor,
//   });
// }

// class ManageTeachersScreen extends StatefulWidget {
//   const ManageTeachersScreen({super.key});

//   @override
//   State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
// }

// class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
//   // Full list of teachers
//   final List<Teacher> allTeachers = [
//     Teacher(
//       name: "Dr. Sarah Ahmed",
//       dept: "Computer Science",
//       email: "sarah.a@uni.edu",
//       initials: "DS",
//       status: "Active",
//       statusColor: Colors.green,
//     ),
//     Teacher(
//       name: "Prof. Usman Khan",
//       dept: "Software Engineering",
//       email: "usman.k@uni.edu",
//       initials: "PU",
//       status: "Active",
//       statusColor: Colors.green,
//     ),
//     Teacher(
//       name: "Engr. Maria Ali",
//       dept: "Information Tech",
//       email: "maria.a@uni.edu",
//       initials: "EM",
//       status: "On Leave",
//       statusColor: Colors.orange,
//     ),
//   ];

//   // List that will be displayed (filtered)
//   List<Teacher> displayedTeachers = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     displayedTeachers = allTeachers; // Initial state shows everyone
//   }

//   // Logic for searching
//   void _runFilter(String enteredKeyword) {
//     List<Teacher> results = [];
//     if (enteredKeyword.isEmpty) {
//       results = allTeachers;
//     } else {
//       results = allTeachers
//           .where(
//             (teacher) =>
//                 teacher.name.toLowerCase().contains(
//                   enteredKeyword.toLowerCase(),
//                 ) ||
//                 teacher.dept.toLowerCase().contains(
//                   enteredKeyword.toLowerCase(),
//                 ),
//           )
//           .toList();
//     }

//     setState(() {
//       displayedTeachers = results;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Column(
//         children: [
//           _buildHeader(context),
//           Expanded(
//             child: displayedTeachers.isNotEmpty
//                 ? ListView.builder(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 20,
//                     ),
//                     itemCount: displayedTeachers.length,
//                     itemBuilder: (context, index) {
//                       final teacher = displayedTeachers[index];
//                       return TeacherCard(teacher: teacher);
//                     },
//                   )
//                 : const Center(child: Text("No teachers found.")),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             ColorPallet.primaryBlue,
//             //  Color(0xFF5C6BC0)
//             ColorPallet.primaryBlue,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Icon(Icons.arrow_back, color: Colors.white, size: 20),
//               const Text(
//                 "Manage Teachers",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(
//                   Icons.person_add_alt_1,
//                   size: 18,
//                   color: ColorPallet.primaryBlue,
//                 ),
//                 label: const Text(
//                   "Add New",
//                   style: TextStyle(color: ColorPallet.primaryBlue),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 25),
//           TextField(
//             controller: _searchController,
//             onChanged: (value) =>
//                 _runFilter(value), // Triggers filter on every keystroke
//             cursorColor: Colors.white,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white.withOpacity(0.2),
//               prefixIcon: const Icon(Icons.search, color: Colors.white70),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear, color: Colors.white70),
//                       onPressed: () {
//                         _searchController.clear();
//                         _runFilter('');
//                       },
//                     )
//                   : null,
//               hintText: "Search by name or department...",
//               hintStyle: const TextStyle(color: Colors.white70),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TeacherCard extends StatelessWidget {
//   final Teacher teacher;

//   const TeacherCard({super.key, required this.teacher});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 28,
//             backgroundColor: const Color(0xFFE8EAF6),
//             child: Text(
//               teacher.initials,
//               style: const TextStyle(
//                 color: Color(0xFF3F51B5),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   teacher.name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Icon(Icons.business, size: 14, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text(
//                       teacher.dept,
//                       style: const TextStyle(color: Colors.grey, fontSize: 13),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.email_outlined,
//                       size: 14,
//                       color: Colors.grey,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       teacher.email,
//                       style: const TextStyle(color: Colors.grey, fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: teacher.statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   teacher.status,
//                   style: TextStyle(
//                     color: teacher.statusColor,
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Icon(Icons.more_vert, color: Colors.grey),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class Teacher {
  final String name, dept, email, initials, status;
  final Color statusColor;

  Teacher({
    required this.name,
    required this.dept,
    required this.email,
    required this.initials,
    required this.status,
    required this.statusColor,
  });
}

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  // Initial Data
  final List<Teacher> allTeachers = [
    Teacher(
      name: "Dr. Sarah Ahmed",
      dept: "Computer Science",
      email: "sarah.a@uni.edu",
      initials: "DS",
      status: "Active",
      statusColor: Colors.green,
    ),
    Teacher(
      name: "Prof. Usman Khan",
      dept: "Software Engineering",
      email: "usman.k@uni.edu",
      initials: "PU",
      status: "Active",
      statusColor: Colors.green,
    ),
    Teacher(
      name: "Engr. Maria Ali",
      dept: "Information Tech",
      email: "maria.a@uni.edu",
      initials: "EM",
      status: "On Leave",
      statusColor: Colors.orange,
    ),
  ];

  List<Teacher> displayedTeachers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedTeachers = List.from(allTeachers);
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      displayedTeachers = allTeachers
          .where(
            (t) =>
                t.name.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
                t.dept.toLowerCase().contains(enteredKeyword.toLowerCase()),
          )
          .toList();
    });
  }

  // --- THE NEW DIALOG FUNCTION ---
  void _showAddTeacherSheet() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final deptController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows keyboard to push the sheet up
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 20, // Keyboard padding
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add New Teacher",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel("FULL NAME"),
              _buildTextField(
                nameController,
                "Dr. John Doe",
                Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _buildLabel("EMAIL ADDRESS"),
              _buildTextField(
                emailController,
                "john.doe@university.edu",
                Icons.email_outlined,
              ),
              const SizedBox(height: 15),
              _buildLabel("DEPARTMENT"),
              _buildTextField(
                deptController,
                "Computer Science",
                Icons.business_outlined,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty) {
                      _addNewTeacher(
                        nameController.text,
                        deptController.text,
                        emailController.text,
                      );
                      Navigator.pop(context); // Close sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Teacher Added Successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Register Teacher",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPallet.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewTeacher(String name, String dept, String email) {
    String initials = name
        .trim()
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    final newTeacher = Teacher(
      name: name,
      dept: dept,
      email: email,
      initials: initials,
      status: "Active",
      statusColor: Colors.green,
    );

    setState(() {
      allTeachers.insert(0, newTeacher); // Add to main list
      displayedTeachers = List.from(allTeachers); // Update search list
    });
  }

  Widget _buildLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: displayedTeachers.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: displayedTeachers.length,
                    itemBuilder: (context, index) =>
                        TeacherCard(teacher: displayedTeachers[index]),
                  )
                : const Center(child: Text("No teachers found.")),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              const Text(
                "Manage Teachers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddTeacherSheet, // Triggering the dialog
                icon: const Icon(
                  Icons.person_add_alt_1,
                  size: 16,
                  color: ColorPallet.primaryBlue,
                ),
                label: const Text(
                  "Add New",
                  style: TextStyle(
                    color: ColorPallet.primaryBlue,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: _runFilter,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              hintText: "Search by name...",
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TeacherCard remains the same as your provided code
class TeacherCard extends StatelessWidget {
  final Teacher teacher;
  const TeacherCard({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFE8EAF6),
            child: Text(
              teacher.initials,
              style: const TextStyle(
                color: ColorPallet.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  teacher.dept,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  teacher.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: teacher.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              teacher.status,
              style: TextStyle(
                color: teacher.statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
