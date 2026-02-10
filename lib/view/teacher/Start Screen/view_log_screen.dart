import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/utils/widgets/export_pdf.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/edit_attendence_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceLogsScreen extends StatefulWidget {
  const AttendanceLogsScreen({super.key});

  @override
  State<AttendanceLogsScreen> createState() => _AttendanceLogsScreenState();
}

class _AttendanceLogsScreenState extends State<AttendanceLogsScreen> {
  // Sample data
  late String selectedDate;
  String selectedSubject = "Computer Science";

  String displayDate = DateFormat('MMMM d, y').format(DateTime.now());
  void initState() {
    super.initState();
    // Screen load hote hi aaj ki date set ho jayegi
    DateTime now = DateTime.now();
    selectedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  final List<String> subjects = [
    "Computer Science",
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "English Literature",
    "History",
    "Geography",
    "Economics",
    "Business Studies",
    "Art & Design",
    "Physical Education",
  ];

  final List<Map<String, dynamic>> students = [
    {
      "name": "Ahmed Khan",
      "time": "09:02 AM - 10:30 AM",
      "status": "Present",
      "color": Colors.green,
    },
    {
      "name": "Sara Malik",
      "time": "09:02 AM - 10:30 AM",
      "status": "Present",
      "color": Colors.grey,
    },
    {
      "name": "Ali Raza",
      "time": "09:02 AM - 10:30 AM",
      "status": "Absent",
      "color": Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: ColorPallet.primaryBlue,
          // leading: const Icon(Icons.arrow_back, color: Colors.white),
          title: const Text(
            "Today's Attendance Logs",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildSummarySection(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: students.length,
                itemBuilder: (context, index) =>
                    _buildStudentCard(students[index]),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Session Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildFunctionalDropdown(
                  "Subject",
                  selectedSubject,
                  subjects,
                  Icons.auto_stories,
                  (val) => setState(() => selectedSubject = val!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                "Total Students: ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                "25",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 15),
              Text("Present: ", style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                "23",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 15),
              Text("Absent: ", style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                "2",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "$displayDate - Information Security - Semester 8",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> data) {
    bool isPresent = data['status'] == "Present";
    bool isOff = data['status'] == "off";

    return Opacity(
      opacity: isOff ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: isOff ? Colors.grey : data['color'],
                child: Text(
                  data['name'].substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
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
                      data['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: isOff ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      data['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.grey,
                        ),
                        // onPressed: () async {
                        //   // <-- async lazmi lagayein
                        //   // Edit screen par data bhejein aur wapis aane ka intezar karein
                        //   final result = await Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //           EditAttendanceScreen(studentData: data),
                        //     ),
                        //   );

                        //   // Jab Edit screen se 'Save' dabakar wapis aayein
                        //   if (result != null) {
                        //     setState(() {
                        //       // Yeh line screen ko refresh karti hai
                        //       data['entryTime'] = result['entryTime'];
                        //       data['exitTime'] = result['exitTime'];
                        //       // Time string ko bhi update karein jo card par dikh raha hai
                        //       data['time'] =
                        //           "${result['entryTime']} - ${result['exitTime']}";
                        //     });
                        //   }
                        // },
                        // AttendanceLogsScreen ke andar IconButton (Edit) ka logic
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditAttendanceScreen(studentData: data),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              data['entryTime'] = result['entryTime'];
                              data['exitTime'] = result['exitTime'];
                              data['time'] = result['time'];
                              data['leaveReason'] = result['leaveReason'];

                              data['status'] = result['status'];
                            });
                          }
                        },
                      ),
                      _buildStatusBadge(data['status']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isPresent || isOff,
                      onChanged: (bool value) {
                        setState(() {
                          data['status'] = value ? "Present" : "Absent";
                        });
                      },
                      activeTrackColor: isOff
                          ? Colors.blueGrey.shade200
                          : const Color(0xFF4CAF50),
                      inactiveTrackColor: const Color(0xFFFF7043),
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color mainColor;
    Color bgColor;
    IconData icon;

    if (status == "Present") {
      mainColor = const Color(0xFF4CAF50);
      bgColor = const Color(0xFFE8F5E9);
      icon = Icons.check_box;
    } else if (status == "Leave") {
      mainColor = Colors.amber.shade800; // Dark Yellow/Amber for text
      bgColor = const Color(0xFFFFFDE7); // Light Yellow for background
      icon = Icons.event_note;
    } else {
      mainColor = const Color(0xFFFF7043); // Orange/Red for Absent
      bgColor = const Color(0xFFFBE9E7);
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: mainColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: mainColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildStatusChip(String status) {
  //   Color bgColor = status == "Present"
  //       ? Colors.green
  //       : (status == "Absent" ? Colors.orange : Colors.deepOrangeAccent);
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //     decoration: BoxDecoration(
  //       color: bgColor,
  //       borderRadius: BorderRadius.circular(5),
  //     ),
  //     child: Text(
  //       status,
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 10,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showSuccessDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPallet.primaryBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "This will finalize attendance",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          OutlinedButton(
            onPressed: () {
              exportToPDF(displayDate, selectedDate, students);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Export Logs",
              style: TextStyle(color: Colors.green),
            ), //
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Success!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Attendance for $displayDate has been saved successfully.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(100, 40),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFunctionalDropdown(
    String label,
    String currentValue,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF1A4B8F).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A4B8F).withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Subject",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 80),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                isExpanded: true,
                icon: const Icon(
                  Icons.unfold_more,
                  size: 14,
                  color: Colors.grey,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(icon, size: 14, color: const Color(0xFF1A4B8F)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(value, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
