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
    {"name": "Jane Doe", "present": 22, "absent": 2, "percent": 91},
    {"name": "Lisa Davis", "present": 18, "absent": 6, "percent": 75},
    {"name": "Mike King", "present": 15, "absent": 9, "percent": 62},
    {"name": "Alex Smith", "present": 24, "absent": 0, "percent": 100},
    {"name": "John Wick", "present": 20, "absent": 4, "percent": 83},
    {"name": "Sarah Connor", "present": 12, "absent": 12, "percent": 50},
    {"name": "Peter Parker", "present": 21, "absent": 3, "percent": 87},
  ];

  String searchQuery = "";

  // PDF Generate aur Download karne ka function
  Future<void> _generatePDFReport(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();

    // PDF UI Layout
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Attendance Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Subject: ${widget.subject}"),
              pw.Text("Month: ${widget.month}"),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Table for PDF
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Student Name', 'Present', 'Absent', 'Percentage'],
                data: data
                    .map(
                      (item) => [
                        item['name'],
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

    // Save PDF
    try {
      final Uint8List bytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/Attendance_${widget.subject}.pdf");
      await file.writeAsBytes(bytes);

      // PDF Share/Print option dikhane ke liye (Optional but Recommended)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ PDF Downloaded Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("PDF Error: $e");
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
          title: Column(
            children: [
              const Text(
                "Detailed Attendance",
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
              onPressed: () => _generatePDFReport(filteredStudents),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar (same as before)
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Header Row
            _buildTableHeader(),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) =>
                    _buildStudentCard(filteredStudents[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              "STUDENT",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "P",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "A",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "STATUS",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    bool isLow = student['percent'] < 75;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              student['name'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              "${student['present']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "${student['absent']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isLow
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
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
          ),
        ],
      ),
    );
  }
}
