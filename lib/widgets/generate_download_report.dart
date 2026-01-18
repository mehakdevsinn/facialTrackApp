import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// ... class ke andar ...

void _generateAndDownloadReport(BuildContext context) async {
  // 1. Loading dikhayen
   String selectedMonth = "October 2025";

String selectedSubject = "Computer Science";
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
  );

  try {
    // 2. Data tayyar karein (Comma Separated Values - CSV)
    String csvData = "Student Name, Present, Absent, Percentage\n";
    csvData += "Jane Doe, 22, 2, 91%\n";
    csvData += "Lisa Davis, 18, 6, 75%\n";
    csvData += "Mike King, 15, 9, 62%\n";
    csvData += "Alex Smith, 24, 0, 100%\n";

    // 3. Storage path dhoonden
    final directory = await getApplicationDocumentsDirectory();
    final fileName = "Attendance_${selectedSubject}_${selectedMonth.replaceAll(' ', '_')}.csv";
    final path = "${directory.path}/$fileName";
    final file = File(path);

    // 4. File write karein
    await file.writeAsString(csvData);

    // Loading band karein
    Navigator.pop(context);

    // 5. Success Message dikhayen aur OPEN button kaam karega
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Saved: $fileName"),
        backgroundColor: const Color(0xFF1A4B8F),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "OPEN",
          textColor: Colors.white,
          onPressed: () async {
            // YE LINE FILE OPEN KAREGI
            // final result = await OpenFile.open(path);
            // if (result.type != ResultType.done) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text("Could not open file: ${result.message}")),
            //   );
            // }
          },
        ),
      ),
    );
  } catch (e) {
    Navigator.pop(context);
    print("Error: $e");
  }
}