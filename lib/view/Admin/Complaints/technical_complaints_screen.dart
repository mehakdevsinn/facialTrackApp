import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Admin/Complaints/technical_complaints_detail_screen.dart';
import 'package:flutter/material.dart';

class AdminTechnicalComplaintsScreen extends StatefulWidget {
  const AdminTechnicalComplaintsScreen({super.key});

  @override
  State<AdminTechnicalComplaintsScreen> createState() =>
      _AdminTechnicalComplaintsScreenState();
}

class _AdminTechnicalComplaintsScreenState
    extends State<AdminTechnicalComplaintsScreen> {
  String selectedFilterStatus = "All";
  String? selectedFilterCategory;

  final List<String> categories = [
    "All Categories",
    "Face Recognition Error",
    "App Crash",
    "Login Issue",
    "Sync Problem",
    "Other",
  ];

  final List<Map<String, dynamic>> technicalComplaints = [
    {
      "id": 1,
      "userName": "Zain Ali",
      "userRole": "Student",
      "idNumber": "FA21-BCS-102",
      "semester": "6th Semester",
      "category": "Face Recognition Error",
      "date": "Feb 08, 2026",
      "shortDesc": "Face not detected in outdoors.",
      "fullDesc":
          "I tried to mark my attendance while standing near the department entrance, but the camera was too bright and it didn't recognize my face. Tried 5 times.",
      "status": "Pending",
      "reportedAt": "08:45 AM",
      "deviceInfo": "Samsung S21 • Android 13",
      "appVersion": "v1.0.4",
    },
    {
      "id": 2,
      "userName": "Dr. Saima Kamran",
      "userRole": "Teacher",
      "idNumber": "TCH-2025-014",
      "category": "Schedule Problem",
      "date": "Feb 09, 2026",
      "shortDesc": "Monday's lab not showing in schedule.",
      "fullDesc":
          "I have a Mobile App Dev lab scheduled for Monday at 11:30 AM, but it is not appearing in my 'Assigned Subjects' or 'Start Session' list.",
      "status": "Pending",
      "reportedAt": "10:15 AM",
      "deviceInfo": "iPhone 14 • iOS 17",
      "appVersion": "v1.0.5",
    },
    {
      "id": 3,
      "userName": "Amna Sheikh",
      "userRole": "Student",
      "idNumber": "FA21-BCS-056",
      "semester": "4th Semester",
      "category": "App Crash",
      "date": "Feb 07, 2026",
      "shortDesc": "App closes when opening logs.",
      "fullDesc":
          "Every time I click on 'My Attendance History', the app immediately shuts down. This started happening after the last update.",
      "status": "Pending",
      "reportedAt": "01:20 PM",
      "deviceInfo": "iPhone 13 • iOS 16",
      "appVersion": "v1.0.4",
    },
    {
      "id": 4,
      "userName": "Hassan Raza",
      "userRole": "Student",
      "idNumber": "FA21-BCS-012",
      "semester": "8th Semester",
      "category": "Sync Problem",
      "date": "Feb 06, 2026",
      "shortDesc": "Attendance not updating.",
      "fullDesc":
          "The teacher marked me present, and it shows on her screen, but my dashboard still says 'Absent'. I re-logged but no change.",
      "status": "Resolved",
      "reportedAt": "11:10 AM",
      "deviceInfo": "Xiaomi Redmi Note 11",
      "appVersion": "v1.0.3",
    },
  ];

  List<Map<String, dynamic>> get filteredComplaints {
    return technicalComplaints.where((c) {
      bool matchesStatus =
          selectedFilterStatus == "All" || c['status'] == selectedFilterStatus;
      bool matchesCategory =
          selectedFilterCategory == null ||
          selectedFilterCategory == "All Categories" ||
          c['category'] == selectedFilterCategory;
      return matchesStatus && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text(
            "Technical Complaints",
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilterCategory ?? "All Categories",
                isExpanded: true,
                dropdownColor: ColorPallet.primaryBlue,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                items: categories
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
                onChanged: (val) =>
                    setState(() => selectedFilterCategory = val),
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
              builder: (_) => TechnicalComplaintDetailScreen(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint['userName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "${complaint['userRole']}${complaint['userRole'] == "Student" ? " • ${complaint['semester']}" : ""}",
                            style: TextStyle(
                              color: complaint['userRole'] == "Teacher"
                                  ? Colors.deepPurple
                                  : Colors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                  complaint['category'],
                  style: TextStyle(
                    color: ColorPallet.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
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
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      complaint['reportedAt'],
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
          Icon(
            Icons.build_circle_outlined,
            size: 70,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No technical issues found",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
