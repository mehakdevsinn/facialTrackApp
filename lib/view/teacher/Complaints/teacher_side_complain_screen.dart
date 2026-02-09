import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Complaints/teacher_side_complain_detail_screen.dart';
import 'package:flutter/material.dart';

class TeacherComplaintsInbox extends StatefulWidget {
  const TeacherComplaintsInbox({super.key});

  @override
  State<TeacherComplaintsInbox> createState() => _TeacherComplaintsInboxState();
}

class _TeacherComplaintsInboxState extends State<TeacherComplaintsInbox> {
  String selectedFilterStatus = "All";
  String? selectedFilterCourse;

  final List<String> courses = [
    "All Courses",
    "Mobile App Development",
    "Data Science",
    "Software Engineering",
    "Information Technology",
  ];

  final List<Map<String, dynamic>> allComplaints = [
    {
      "id": 1,
      "studentName": "Usman Khan",
      "rollNo": "FA21-BCS-089",
      "date": "Feb 07, 2026",
      "course": "Mobile App Development",
      "type": "Attendance Issue",
      "shortDesc": "Marked absent despite being present.",
      "fullDesc":
          "I was present in the class, sitting in the middle row. The system marked me absent. Probably due to low light near my desk or someone blocking the camera view.",
      "status": "Pending",
      "reportedAt": "10:30 AM",
      "attendanceRecord": {"status": "Absent", "inTime": "--", "outTime": "--"},
    },
    {
      "id": 2,
      "studentName": "Saba Qamar",
      "rollNo": "FA21-BCS-022",
      "date": "Feb 06, 2026",
      "course": "Data Science",
      "type": "Attendance Issue",
      "shortDesc": "Marked late incorrectly.",
      "fullDesc":
          "Marked late even though I entered at 08:35 AM. The buffer is 10 minutes (class starts at 8:30). Please review the logs.",
      "status": "Pending",
      "reportedAt": "02:15 PM",
      "attendanceRecord": {
        "status": "Late",
        "inTime": "08:35 AM",
        "outTime": "11:30 AM",
      },
    },
    {
      "id": 3,
      "studentName": "Ali Ahmed",
      "rollNo": "FA21-BCS-045",
      "date": "Feb 05, 2026",
      "course": "Mobile App Development",
      "type": "Attendance Issue",
      "shortDesc": "System error during check-in.",
      "fullDesc":
          "My face was not being detected promptly, and by the time it did, I was marked late.",
      "status": "Resolved",
      "reportedAt": "09:00 AM",
      "attendanceRecord": {
        "status": "Present",
        "inTime": "08:32 AM",
        "outTime": "11:30 AM",
      },
    },
  ];

  List<Map<String, dynamic>> get filteredComplaints {
    return allComplaints.where((c) {
      bool matchesStatus =
          selectedFilterStatus == "All" || c['status'] == selectedFilterStatus;
      bool matchesCourse =
          selectedFilterCourse == null ||
          selectedFilterCourse == "All Courses" ||
          c['course'] == selectedFilterCourse;
      return matchesStatus && matchesCourse;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text(
            "Complaints Inbox",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: filteredComplaints.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredComplaints.length,
                      itemBuilder: (context, index) {
                        return _buildComplaintCard(filteredComplaints[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Status Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Pending", "Resolved", "Rejected"].map((
                status,
              ) {
                bool isSelected = selectedFilterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) =>
                        setState(() => selectedFilterStatus = status),
                    backgroundColor: Colors.white24,
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? ColorPallet.primaryBlue
                          : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    checkmarkColor: ColorPallet.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Course Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilterCourse ?? "All Courses",
                isExpanded: true,
                dropdownColor: ColorPallet.primaryBlue,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                items: courses
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedFilterCourse = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    Color statusColor = complaint['status'] == "Pending"
        ? Colors.amber
        : (complaint['status'] == "Resolved" ? Colors.green : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComplaintDetailScreen(
                complaint: complaint,
                onUpdate: (newStatus) {
                  setState(() {
                    complaint['status'] = newStatus;
                  });
                },
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        complaint['studentName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        complaint['status'].toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  complaint['course'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      complaint['date'],
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.error_outline,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      complaint['type'],
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Text(
                  complaint['shortDesc'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No $selectedFilterStatus complaints found",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
