import 'package:facialtrackapp/constants/color_pallet.dart';
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
      "studentName": "Zain Ali",
      "rollNo": "FA21-BCS-102",
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
      "studentName": "Amna Sheikh",
      "rollNo": "FA21-BCS-056",
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
      "id": 3,
      "studentName": "Hassan Raza",
      "rollNo": "FA21-BCS-012",
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

class TechnicalComplaintDetailScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final Function(String) onUpdate;

  const TechnicalComplaintDetailScreen({
    super.key,
    required this.complaint,
    required this.onUpdate,
  });

  @override
  State<TechnicalComplaintDetailScreen> createState() =>
      _TechnicalComplaintDetailScreenState();
}

class _TechnicalComplaintDetailScreenState
    extends State<TechnicalComplaintDetailScreen> {
  final TextEditingController _noteController = TextEditingController();

  void _handleStatusUpdate(String status) {
    widget.onUpdate(status);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🛠️ Tech issue marked as $status"),
        backgroundColor: status == "Resolved" ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: const Text(
          "Issue Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    child: const Icon(
                      Icons.engineering_rounded,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.complaint['studentName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.complaint['rollNo'],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              "TECHNICAL INFO",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Category", widget.complaint['category']),
                  _buildDetailRow("Device", widget.complaint['deviceInfo']),
                  _buildDetailRow(
                    "App Version",
                    widget.complaint['appVersion'],
                  ),
                  _buildDetailRow("Reported", widget.complaint['reportedAt']),
                  const Divider(height: 30),
                  const Text(
                    "Problem Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.complaint['fullDesc'],
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            if (widget.complaint['status'] == "Pending") ...[
              const Text(
                "ADMIN RESPONSE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Add technical notes or response...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleStatusUpdate("Resolved"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Fix Implemented",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleStatusUpdate("Rejected"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Dismiss Issue",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.complaint['status'] == "Resolved"
                          ? Colors.green
                          : Colors.red,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.complaint['status'].toUpperCase(),
                    style: TextStyle(
                      color: widget.complaint['status'] == "Resolved"
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: ColorPallet.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
