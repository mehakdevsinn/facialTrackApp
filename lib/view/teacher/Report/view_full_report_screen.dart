import 'dart:io';
import 'dart:typed_data';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart'
    as pw; // PDF widgets ko 'pw' prefix dena zaroori hai
import 'package:printing/printing.dart';

class FullReportScreen extends StatefulWidget {
  final String month;
  final String subject;
  final String semester;

  const FullReportScreen({
    super.key,
    required this.month,
    required this.subject,
    required this.semester,
  });

  @override
  State<FullReportScreen> createState() => _FullReportScreenState();
}

class _FullReportScreenState extends State<FullReportScreen> {
  final List<Map<String, dynamic>> students = [
    {
      "name": "Jane Doe",
      "rollNo": "2021-CS-01",
      "total": 24,
      "present": 22,
      "absent": 2,
      "percent": 91,
    },
    {
      "name": "Lisa Davis",
      "rollNo": "2021-CS-02",
      "total": 24,
      "present": 18,
      "absent": 6,
      "percent": 75,
    },
    {
      "name": "Mike King",
      "rollNo": "2021-CS-03",
      "total": 24,
      "present": 15,
      "absent": 9,
      "percent": 62,
    },
    {
      "name": "Alex Smith",
      "rollNo": "2021-CS-04",
      "total": 24,
      "present": 24,
      "absent": 0,
      "percent": 100,
    },
    {
      "name": "John Wick",
      "rollNo": "2021-CS-05",
      "total": 24,
      "present": 20,
      "absent": 4,
      "percent": 83,
    },
    {
      "name": "Sarah Connor",
      "rollNo": "2021-CS-06",
      "total": 24,
      "present": 12,
      "absent": 12,
      "percent": 50,
    },
    {
      "name": "Peter Parker",
      "rollNo": "2021-CS-07",
      "total": 24,
      "present": 21,
      "absent": 3,
      "percent": 87,
    },
  ];

  String searchQuery = "";

  Future<void> _generatePDFReport(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();

    final font = pw.Font.helvetica();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Monthly Attendance Report",
                style: pw.TextStyle(
                  font: font,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Subject: ${widget.subject}",
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                "Semester: ${widget.semester}",
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                "Month: ${widget.month}",
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
                headers: [
                  'Student Name',
                  'Roll No',
                  'Total',
                  'Presents',
                  'Absents',
                  'Att %',
                ],
                data: data
                    .map(
                      (item) => [
                        item['name'].toString().replaceAll(
                          RegExp(r'[^\x00-\x7F]+'),
                          '',
                        ),
                        item['rollNo'].toString(),
                        item['total'].toString(),
                        item['present'].toString(),
                        item['absent'].toString(),
                        "${item['percent']}%",
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
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: "Attendance_${widget.subject}.pdf",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ PDF Processing Complete"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("PDF Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ PDF Error: Please restart the app"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredStudents = students
        .where(
          (s) => s['name'].toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          foregroundColor: ColorPallet.white,
          backgroundColor: ColorPallet.primaryBlue,
          elevation: 0,
          title: Column(
            children: [
              const Text(
                "Complete Report",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                "${widget.subject} • ${widget.semester} • ${widget.month}",
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: () {
                if (filteredStudents.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ No data available to download"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  _generatePDFReport(filteredStudents);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search student name...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1A4B8F),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A4B8F),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            _buildTableHeader(),

            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 80,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No student found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Try searching with a different name",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) =>
                          _buildStudentRow(filteredStudents[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A4B8F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              "NAME",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "ROLL NO",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "TOT",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "P",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "A",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "%",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> student) {
    bool isLow = student['percent'] < 75;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              student['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              student['rollNo'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "${student['total']}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "${student['present']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "${student['absent']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "${student['percent']}%",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLow ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
