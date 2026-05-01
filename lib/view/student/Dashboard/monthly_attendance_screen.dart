import 'package:flutter/material.dart';
// Note: Ensure this import path is correct for your project
import 'package:facialtrackapp/view/student/Dashboard/subject_sessions_history_screen.dart';

class SubjectAttendanceData {
  final String code;
  final Color color;
  final String title;
  final String subtitle;
  final double percentage;
  final int totalClasses;
  final int present;
  final int absent;
  final int leave;
  final bool isExpanded;

  SubjectAttendanceData({
    required this.code,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.leave,
    this.isExpanded = false,
  });
}

class MonthlyAttendanceScreen extends StatefulWidget {
  const MonthlyAttendanceScreen({super.key});

  @override
  State<MonthlyAttendanceScreen> createState() =>
      _MonthlyAttendanceScreenState();
}

class _MonthlyAttendanceScreenState extends State<MonthlyAttendanceScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: At Risk, 2: Good
  String _selectedMonth = "Dec 2025";

  final List<String> _filters = ["All", "At Risk", "Good"];
  final List<String> _months = ["Oct 2025", "Nov 2025", "Dec 2025", "Jan 2026"];

  final List<SubjectAttendanceData> _subjects = [
    SubjectAttendanceData(
      code: "CS",
      color: const Color(0xFF2304AA),
      title: "Computer Science",
      subtitle: "Prof. Ahmed Khan - CS101",
      percentage: 92,
      totalClasses: 25,
      present: 23,
      absent: 2,
      leave: 0,
    ),
    SubjectAttendanceData(
      code: "MA",
      color: const Color(0xFF8B5CF6),
      title: "Mathematics",
      subtitle: "Prof. Ayesha - MATH101",
      percentage: 89,
      totalClasses: 20,
      present: 18,
      absent: 2,
      leave: 0,
    ),
    SubjectAttendanceData(
      code: "UR",
      color: const Color(0xFF0D9488),
      title: "Urdu",
      subtitle: "Prof. Nadia - URD101",
      percentage: 85,
      totalClasses: 20,
      present: 17,
      absent: 3,
      leave: 0,
    ),
    SubjectAttendanceData(
      code: "CH",
      color: const Color(0xFFEA580C),
      title: "Chemistry",
      subtitle: "Dr. Usman - CHEM101",
      percentage: 78,
      totalClasses: 18,
      present: 14,
      absent: 4,
      leave: 0,
    ),
  ];

  // Helper to filter the list based on selection
  List<SubjectAttendanceData> get _filteredSubjects {
    if (_selectedFilterIndex == 1) {
      // At Risk: Percentage < 80
      return _subjects.where((s) => s.percentage < 80).toList();
    } else if (_selectedFilterIndex == 2) {
      // Good: Percentage >= 80
      return _subjects.where((s) => s.percentage >= 80).toList();
    }
    return _subjects;
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _months.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_months[index], textAlign: TextAlign.center),
                onTap: () {
                  setState(() => _selectedMonth = _months[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2304AA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Monthly Attendance",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Month Selector Button
                  GestureDetector(
                    onTap: _showMonthPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedMonth,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header Stats
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text("82%",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_drop_up,
                              color: Color(0xFF10B981), size: 30),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Overall - ${_filteredSubjects.length} subjects",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _buildStatBox("90", "Present", const Color(0xFF3B1DBC)),
                      const SizedBox(height: 8),
                      _buildStatBox("18", "Absent", const Color(0xFF3B1DBC)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Body Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Filters Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          bool isSelected = _selectedFilterIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFilterIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2304AA)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? null
                                    : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                _filters[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // List View
                    Expanded(
                      child: _filteredSubjects.isEmpty
                          ? const Center(
                              child: Text("No subjects found for this filter."))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              itemCount: _filteredSubjects.length,
                              itemBuilder: (context, index) {
                                return _buildSubjectCard(
                                    _filteredSubjects[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String count, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SubjectAttendanceData subject) {
    Color percentageColor = subject.percentage >= 80
        ? const Color(0xFF10B981)
        : const Color(0xFFEA580C);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        trailing: const SizedBox
            .shrink(), // Hiding default arrow to match your design
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: subject.color,
              radius: 22,
              child: Text(subject.code,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937))),
                  Text(subject.subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${subject.percentage.toInt()}%",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: percentageColor)),
                Text("${subject.present}/${subject.totalClasses} classes",
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9CA3AF))),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: subject.percentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(percentageColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat(Icons.circle, const Color(0xFF10B981),
                      "${subject.present} Present"),
                  _buildMiniStat(Icons.circle, const Color(0xFFEF4444),
                      "${subject.absent} Absent"),
                  _buildMiniStat(Icons.circle, const Color(0xFFF59E0B),
                      "${subject.leave} Leave"),
                ],
              ),
            ],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: const Color(0xFFF9FAFB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("RECENT SESSIONS",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF))),
                const SizedBox(height: 12),
                _buildRecentSessionRow("Dec 10, Wed", "09:00 - 10:30 AM",
                    "Present", const Color(0xFF10B981)),
                _buildRecentSessionRow("Dec 09, Tue", "09:00 - 10:30 AM",
                    "Present", const Color(0xFF10B981)),
                _buildRecentSessionRow("Dec 05, Fri", "09:00 - 10:30 AM",
                    "Absent", const Color(0xFFEF4444)),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SubjectSessionsHistoryScreen(subject: subject)),
                      );
                    },
                    child: const Text("View all sessions",
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2304AA),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, size: 8, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRecentSessionRow(
      String date, String time, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
              Text(time,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
          Text(status,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor)),
        ],
      ),
    );
  }
}
