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
  final List<Map<String, dynamic>> students = [
    {"name": "Mehak Fatima", "status": "Present", "reason": ""},
    {"name": "Ali Ahmed", "status": "Absent", "reason": ""},
    {"name": "Arooj Malik", "status": "Leave", "reason": "Medical Emergency"},
    {"name": "Usman Khan", "status": "Present", "reason": ""},
    {"name": "Saba Qamar", "status": "Leave", "reason": "Family Function"},
    {"name": "Hamza Ali", "status": "Present", "reason": ""},
    {"name": "Zainab Bibi", "status": "Absent", "reason": ""},
  ];

  Future<void> _generatePDFReport() async {
    final pdf = pw.Document();

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
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Semester: ${widget.semester}"),
              pw.Text("Subject: ${widget.subject}"),
              pw.Text(
                "Date: ${DateFormat('EEEE, dd MMMM yyyy').format(widget.date)}",
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Student Name', 'Status', 'Reason (if any)'],
                data: students
                    .map(
                      (item) => [
                        item['name'],
                        item['status'],
                        item['reason'] ?? "-",
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
      final Uint8List bytes = await pdf.save();

      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
          "${directory.path}/Attendance_${widget.subject}_${DateFormat('dd_MM_yyyy').format(widget.date)}.pdf",
        );
        await file.writeAsBytes(bytes);
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ PDF Generated Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("PDF Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = students.where((s) => s['status'] == 'Present').length;
    int absentCount = students.where((s) => s['status'] == 'Absent').length;
    int leaveCount = students.where((s) => s['status'] == 'Leave').length;

    return Scaffold(
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
                      "Present",
                      presentCount.toString(),
                      Colors.greenAccent,
                    ),
                    _buildStatItem(
                      "Absent",
                      absentCount.toString(),
                      Colors.redAccent,
                    ),
                    _buildStatItem(
                      "Leave",
                      leaveCount.toString(),
                      Colors.orangeAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Search / Filter Row (Optional placeholder for now)
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 14,
                        color: ColorPallet.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Filter",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ColorPallet.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              physics: const BouncingScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return _buildStudentCard(students[index]);
              },
            ),
          ),
        ],
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
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Absent':
        statusColor = Colors.red;
        statusIcon = Icons.highlight_off;
        break;
      case 'Leave':
        statusColor = Colors.orange;
        statusIcon = Icons.info_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Text(
                        student['name'][0],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        student['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        student['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (student['status'] == 'Leave' && student['reason'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 14,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Reason: ${student['reason']}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
