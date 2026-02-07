import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class SemesterWiseReportScreen extends StatefulWidget {
  const SemesterWiseReportScreen({super.key});

  @override
  State<SemesterWiseReportScreen> createState() =>
      _SemesterWiseReportScreenState();
}

class _SemesterWiseReportScreenState extends State<SemesterWiseReportScreen> {
  String? selectedCourse;
  String? selectedSemester;
  String? selectedStudent;

  final List<String> courses = [
    "Software Engineering",
    "Computer Science",
    "Information Technology",
    "Data Science",
  ];

  final List<String> semesters = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6",
    "Semester 7",
    "Semester 8",
  ];

  final List<Map<String, dynamic>> studentData = [
    {
      "name": "All Students",
      "totalClasses": 45,
      "presents": 40,
      "absents": 3,
      "leaves": 2,
    },
    {
      "name": "Mehak Fatima (FA21-BCS-001)",
      "totalClasses": 45,
      "presents": 42,
      "absents": 1,
      "leaves": 2,
    },
    {
      "name": "Ali Ahmed (FA21-BCS-045)",
      "totalClasses": 45,
      "presents": 35,
      "absents": 10,
      "leaves": 0,
    },
    {
      "name": "Arooj Malik (FA21-BCS-012)",
      "totalClasses": 45,
      "presents": 38,
      "absents": 2,
      "leaves": 5,
    },
    {
      "name": "Usman Khan (FA21-BCS-089)",
      "totalClasses": 45,
      "presents": 30,
      "absents": 15,
      "leaves": 0,
    },
  ];

  Map<String, dynamic> currentStats = {
    "totalClasses": 45,
    "presents": 40,
    "absents": 3,
    "leaves": 2,
    "percentage": 88.8,
  };

  void _updateStats(String? studentName) {
    if (studentName == null) return;

    final data = studentData.firstWhere(
      (s) => s['name'] == studentName,
      orElse: () => studentData[0],
    );

    setState(() {
      selectedStudent = studentName;
      currentStats = {
        "totalClasses": data['totalClasses'],
        "presents": data['presents'],
        "absents": data['absents'],
        "leaves": data['leaves'],
        "percentage": double.parse(
          ((data['presents'] / data['totalClasses']) * 100).toStringAsFixed(1),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          title: const Text(
            "Semester Report",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: ColorPallet.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Filters Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: const BoxDecoration(
                  color: ColorPallet.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    _buildFilterLabel("Target Course"),
                    _buildDropdown("Select Course", selectedCourse, courses, (
                      val,
                    ) {
                      setState(() => selectedCourse = val);
                    }),
                    const SizedBox(height: 18),
                    _buildFilterLabel("Academic Semester"),
                    _buildDropdown(
                      "Select Semester",
                      selectedSemester,
                      semesters,
                      (val) {
                        setState(() => selectedSemester = val);
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildFilterLabel("Student Filter"),
                    _buildDropdown(
                      "Select Student (Optional)",
                      selectedStudent,
                      studentData.map((e) => e['name'] as String).toList(),
                      _updateStats,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              if (selectedCourse != null && selectedSemester != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Overall Performance",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          if (selectedStudent != null &&
                              selectedStudent != "All Students")
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ColorPallet.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Individual",
                                style: TextStyle(
                                  color: ColorPallet.primaryBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Main Stats Card
                      _buildStatsCard(),

                      const SizedBox(height: 25),

                      // Visual Indicators
                      _buildConsistencySection(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Please select course and semester to view the report",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ColorPallet.primaryBlue.withOpacity(0.7),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ColorPallet.primaryBlue.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatMetric(
                "Total Classes",
                currentStats['totalClasses'].toString(),
                Colors.indigo,
              ),
              _buildStatMetric(
                "Attendance %",
                "${currentStats['percentage']}%",
                ColorPallet.primaryBlue,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatMetric(
                "Presents",
                currentStats['presents'].toString(),
                const Color(0xFF10B981),
              ),
              _buildStatMetric(
                "Absents",
                currentStats['absents'].toString(),
                const Color(0xFFEF4444),
              ),
              _buildStatMetric(
                "Leaves",
                currentStats['leaves'].toString(),
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildConsistencySection() {
    double progress = currentStats['percentage'] / 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Semester Consistency",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                "${currentStats['percentage']}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: ColorPallet.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.75
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            progress > 0.75
                ? "Excellent consistency! Keep it up."
                : "Attendance is slightly below average.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.blueGrey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
