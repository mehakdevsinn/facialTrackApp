import 'dart:io';
import 'dart:typed_data';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DailyAttendanceReportScreen extends StatefulWidget {
  final String semester;
  final String subject;
  final DateTime date;

  const DailyAttendanceReportScreen({
    super.key,
    required this.semester,
    required this.subject,
    required this.date,
  });

  @override
  State<DailyAttendanceReportScreen> createState() =>
      _DailyAttendanceReportScreenState();
}

class _DailyAttendanceReportScreenState
    extends State<DailyAttendanceReportScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    filteredStudents = students;
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = students
          .where(
            (student) =>
                student['name'].toLowerCase().contains(query.toLowerCase()) ||
                student['rollNo'].toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  final List<Map<String, dynamic>> students = [
    {
      "name": "Mehak Fatima",
      "rollNo": "FA21-BCS-001",
      "status": "Present",
      "inTime": "08:30 AM",
      "outTime": "02:30 PM",
      "reason": "",
    },
    {
      "name": "Ali Ahmed",
      "rollNo": "FA21-BCS-045",
      "status": "Absent",
      "inTime": "-",
      "outTime": "-",
      "reason": "",
    },
    {
      "name": "Arooj Malik",
      "rollNo": "FA21-BCS-012",
      "status": "Leave",
      "inTime": "-",
      "outTime": "-",
      "reason": "Medical Emergency",
    },
    {
      "name": "Usman Khan",
      "rollNo": "FA21-BCS-089",
      "status": "Late",
      "inTime": "09:15 AM",
      "outTime": "02:30 PM",
      "reason": "",
    },
    {
      "name": "Saba Qamar",
      "rollNo": "FA21-BCS-022",
      "status": "Left Early",
      "inTime": "08:30 AM",
      "outTime": "12:00 PM",
      "reason": "",
    },
    {
      "name": "Hamza Ali",
      "rollNo": "FA21-BCS-033",
      "status": "Present",
      "inTime": "08:35 AM",
      "outTime": "02:25 PM",
      "reason": "",
    },
  ];

  Future<void> _generatePDFReport() async {
    final pdf = pw.Document();

    // Helvetica font use kar rahe hain taake Unicode/Emoji error na aaye
    final font = pw.Font.helvetica();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Daily Attendance Report",
                style: pw.TextStyle(
                  font: font,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Semester: ${widget.semester}",
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                "Subject: ${widget.subject}",
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                "Date: ${DateFormat('EEEE, dd MMMM yyyy').format(widget.date)}",
                style: pw.TextStyle(font: font),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: pw.TextStyle(font: font, fontSize: 9),
                headers: ['Name', 'Roll No', 'Status', 'In', 'Out', 'Note'],
                data: filteredStudents
                    .map(
                      (item) => [
                        item['name'].toString().replaceAll(
                          RegExp(r'[^\x00-\x7F]+'),
                          '',
                        ), // Sanitize
                        item['rollNo'].toString(),
                        item['status'].toString(),
                        item['inTime'].toString(),
                        item['outTime'].toString(),
                        (item['reason'] ?? "-").toString().replaceAll(
                          RegExp(r'[^\x00-\x7F]+'),
                          '',
                        ), // Sanitize
                      ],
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    try {
      // Direct printing dialog open kar rahe hain
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            "Attendance_${widget.subject}_${DateFormat('dd_MM_yyyy').format(widget.date)}.pdf",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ PDF Processing Complete"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("PDF Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ PDF Error: Please restart the app"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = students.where((s) => s['status'] == 'Present').length;
    int absentCount = students.where((s) => s['status'] == 'Absent').length;
    int leaveCount = students.where((s) => s['status'] == 'Leave').length;
    int lateCount = students.where((s) => s['status'] == 'Late').length;
    int leftEarlyCount = students
        .where((s) => s['status'] == 'Left Early')
        .length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          title: const Text(
            "Day Inspection",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: ColorPallet.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: _generatePDFReport,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                color: ColorPallet.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(widget.date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${widget.subject} • ${widget.semester}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 25),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        "Total",
                        students.length.toString(),
                        Colors.blue.shade100,
                      ),
                      _buildStatItem(
                        "P",
                        presentCount.toString(),
                        Colors.greenAccent,
                      ),
                      _buildStatItem(
                        "A",
                        absentCount.toString(),
                        Colors.redAccent,
                      ),
                      _buildStatItem(
                        "L",
                        leaveCount.toString(),
                        Colors.orangeAccent,
                      ),
                      _buildStatItem(
                        "LT",
                        lateCount.toString(),
                        Colors.amberAccent,
                      ),
                      _buildStatItem(
                        "LE",
                        leftEarlyCount.toString(),
                        Colors.cyanAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterStudents,
                  decoration: InputDecoration(
                    hintText: "Search name or roll no...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: ColorPallet.primaryBlue,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _filterStudents("");
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Student Roll Call",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No students found",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        return _buildStudentCard(filteredStudents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    Color statusColor;
    IconData statusIcon;

    switch (student['status']) {
      case 'Present':
        statusColor = const Color(0xFF10B981); // Emerald Green
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Absent':
        statusColor = const Color(0xFFEF4444); // Rose Red
        statusIcon = Icons.cancel_rounded;
        break;
      case 'Late':
        statusColor = const Color(0xFFF59E0B); // Amber
        statusIcon = Icons.rule_rounded;
        break;
      case 'Left Early':
        statusColor = const Color(0xFF06B6D4); // Cyan
        statusIcon = Icons.logout_rounded;
        break;
      case 'Leave':
        statusColor = const Color(0xFFF97316); // Orange
        statusIcon = Icons.event_note_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: statusColor, width: 6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Info + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: statusColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Text(
                          student['name'][0],
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              student['rollNo'],
                              style: TextStyle(
                                color: Colors.blueGrey.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(
                      student['status'],
                      statusColor,
                      statusIcon,
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Bottom Row: Times
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSection(
                        "IN-TIME",
                        student['inTime'],
                        Icons.login_rounded,
                        const Color(0xFF10B981),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: const Color(0xFFF1F5F9),
                    ),
                    Expanded(
                      child: _buildTimeSection(
                        "OUT-TIME",
                        student['outTime'],
                        Icons.logout_rounded,
                        const Color(0xFFF43F5E),
                      ),
                    ),
                  ],
                ),

                // Leave Reason if exists
                if (student['status'] == 'Leave' &&
                    student['reason'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_rounded,
                          size: 16,
                          color: Color(0xFFF97316),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            student['reason'],
                            style: const TextStyle(
                              color: Color(0xFF9A3412),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(
    String label,
    String time,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.blueGrey.shade300,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
