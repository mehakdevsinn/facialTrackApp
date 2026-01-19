import 'dart:io';

import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Report/view_full_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AttendanceReport extends StatefulWidget {
  final bool showBackButton;
  const AttendanceReport({super.key, this.showBackButton = false});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  final Color primaryDark = const Color(0xFF1A4B8F);

  final Color accentTeal = const Color(0xFF26A69A);

  final Color accentOrange = const Color(0xFFFF8A65);
  bool showOnlyLow = false;
  String selectedMonth = "October 2025";

  String selectedSubject = "Computer Science";

  // Full list of 12 Months
  final List<String> months = [
    "January 2025",
    "February 2025",
    "March 2025",
    "April 2025",
    "May 2025",
    "June 2025",
    "July 2025",
    "August 2025",
    "September 2025",
    "October 2025",
    "November 2025",
    "December 2025",
  ];

  // Expanded List of Subjects
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
  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Agar dashboard se aaye hain toh pop hona chahiye (true)
      // Agar bottom nav se aaye hain toh pop nahi hona chahiye (false)
      canPop: widget.showBackButton,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },

      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            foregroundColor: ColorPallet.white,
            automaticallyImplyLeading: false,

            backgroundColor: ColorPallet.primaryBlue,
            leading: widget.showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: const Text(
              'Monthly Report',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            // actions: [
            //   IconButton(
            //     icon: const Icon(
            //       Icons.download_for_offline_outlined,
            //       color: Colors.white,
            //     ),
            //     onPressed: () => _generateAndDownloadReport(context),
            //   ),
            //   const SizedBox(width: 15),
            // ],
            centerTitle: true,
          ),

          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Month & Subject Selectors
                Row(
                  children: [
                    Expanded(
                      child: _buildFunctionalDropdown(
                        "Month",
                        selectedMonth,
                        months,
                        Icons.calendar_month,
                        (val) => setState(() => selectedMonth = val!),
                      ),
                    ),
                    const SizedBox(width: 15),
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
                SizedBox(height: 16),

                // Main Attendance Card
                _buildMainAttendanceCard(),

                SizedBox(height: 16),

                // Low Attendance Students List
                _buildStudentListCard(),

                SizedBox(height: 16),

                // Monthly Trend Chart
                _buildTrendCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function for Dropdown UI
  Widget _buildDropdownCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          Row(
            children: [
              Icon(icon, size: 16, color: Color(0xFF1A4B8F)),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  // void _generateAndDownloadReport(BuildContext context) async {
  //   // Loading Start
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(child: CircularProgressIndicator()),
  //   );

  //   try {
  //     // 1. Data string banayein
  //     String csvData =
  //         "Name,Present,Absent,Percentage\nJane Doe,22,2,91%\nLisa Davis,18,6,75%\nMike King,15,9,62%";

  //     // 2. Phone ki storage mein jagah dhoonden
  //     final directory = await getApplicationDocumentsDirectory();
  //     final path = "${directory.path}/Attendance_Report.csv";
  //     final file = File(path);

  //     // 3. File Save karein
  //     await file.writeAsString(csvData);

  //     Navigator.pop(context); // Loading khatam

  //     // 4. Notification dikhayen
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text("✅ Report Downloaded"),
  //         action: SnackBarAction(
  //           label: "OPEN",
  //           textColor: Colors.white,
  //           onPressed: () async {
  //             // YE LINE FILE KO EXCEL YA OFFICE MEIN KHOLY GI
  //             // await OpenFile.open(path);
  //           },
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     Navigator.pop(context);
  //     print("Download Error: $e");
  //   }
  // }

  Widget _buildMainAttendanceCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 10.0,
                percent: 0.82,
                center: Text(
                  "82%",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                progressColor: Colors.teal,
                backgroundColor: Colors.grey[200]!,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              // Update this part in _buildMainAttendanceCard
              GestureDetector(
                onTap: () {
                  setState(() {
                    showOnlyLow = !showOnlyLow; // Toggle filter
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    // Color change logic for toggle effect
                    color: showOnlyLow
                        ? Colors.orange[800]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange[800]!),
                  ),
                  child: Text(
                    "Low Attendance",
                    style: TextStyle(
                      color: showOnlyLow ? Colors.white : Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Present: 85 days - Absent: 15 days",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _indicatorLabel(Colors.teal, "Present"),
              SizedBox(width: 20),
              _indicatorLabel(Colors.orange, "Absent"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicatorLabel(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStudentListCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Class Performance",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                "Sorted by %",
                style: TextStyle(
                  color: primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // In _buildStudentListCard inside Column children:
          const SizedBox(height: 15),
          if (!showOnlyLow)
            _studentRowUnique("Jane Doe", 90), // Show only if filter is OFF
          _studentRowUnique("Lisa Davis", 70),
          _studentRowUnique("Mike King", 72),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullReportScreen(
                      month: selectedMonth,
                      subject: selectedSubject,
                    ),
                  ),
                );
              },
              child: Text(
                "View Complete Report",
                style: TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentRowUnique(String name, int percentage) {
    bool isLow = percentage < 75;
    Color statusColor = isLow ? accentOrange : accentTeal;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.withOpacity(0.02) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: primaryDark.withOpacity(0.1),
            child: Text(
              name[0],
              style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            "$percentage%",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                isLow ? "LOW" : "OKAY",
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    const double maxChartHeight =
        150.0; // Height thodi badha di hai taaki overflow na ho

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monthly Trend",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 25),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-Axis Labels
              Container(
                height: maxChartHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ["100%", "80%", "60%", "40%", "20%", "0%"]
                      .map(
                        (label) => Text(
                          label,
                          style: TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(width: 10),

              // Grid and Bars
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none, // Taaki labels overflow na karein
                  children: [
                    // Background Grid Lines
                    Container(
                      height: maxChartHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey[200],
                          ),
                        ),
                      ),
                    ),

                    // Bars Area
                    Container(
                      height: maxChartHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // In _buildTrendCard inside Row children:
                          _buildScaledBar(
                            85,
                            0,
                            0,
                            "Week 1",
                            maxChartHeight,
                            isHighlighted: !showOnlyLow,
                          ),
                          _buildScaledBar(
                            10,
                            20,
                            45,
                            "Week 2",
                            maxChartHeight,
                            isHighlighted: true,
                          ), // Always show low
                          _buildScaledBar(
                            20,
                            15,
                            30,
                            "Week 3",
                            maxChartHeight,
                            isHighlighted: !showOnlyLow,
                          ),
                          _buildScaledBar(
                            0,
                            35,
                            50,
                            "Week 4",
                            maxChartHeight,
                            isHighlighted: !showOnlyLow,
                          ),
                          _buildScaledBar(
                            0,
                            10,
                            15,
                            "Week 5",
                            maxChartHeight,
                            isHighlighted: true,
                          ), // Always show low
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Niche thoda extra space taaki labels cut na jayein
          SizedBox(height: 20),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              isExpanded: true,
              icon: const Icon(Icons.unfold_more, size: 14, color: Colors.grey),
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
                      const SizedBox(width: 6),
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
        ],
      ),
    );
  }

  Widget _buildScaledBar(
    double bluePct,
    double orangePct,
    double tealPct,
    String label,
    double maxHeight, {
    bool isHighlighted = true,
  }) {
    double bH = (bluePct / 100) * maxHeight;
    double oH = (orangePct / 100) * maxHeight;
    double tH = (tealPct / 100) * maxHeight;

    return Opacity(
      opacity: isHighlighted
          ? 1.0
          : 0.2, // Low click karne par baki bars fade ho jayengi
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 25,
            child: Column(
              children: [
                if (tealPct > 0)
                  Container(
                    height: tH,
                    decoration: BoxDecoration(
                      color: Color(0xFF26A69A),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                  ),
                if (orangePct > 0)
                  Container(height: oH, color: Color(0xFFFF8A65)),
                if (bluePct > 0)
                  Container(height: bH, color: Color(0xFF1A4B8F)),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _bar(int index) {
    double height = [80.0, 40.0, 50.0, 60.0, 30.0][index];
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 25,
          height: height,
          decoration: BoxDecoration(
            color: index == 0 ? Color(0xFF1A4B8F) : Colors.teal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 4),
        Text("W${index + 1}", style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
