import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Parameters add karein: displayDate, selectedDate, aur students list
Future<void> exportToPDF(
  String displayDate, 
  String selectedDate, 
  List<Map<String, dynamic>> students
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("OFFICIAL ATTENDANCE REPORT", 
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            // Ab ye variables error nahi denge
            pw.Text("Date: $displayDate"), 
            pw.SizedBox(height: 20),

            pw.TableHelper.fromTextArray(
              headers: ['Student Name', 'Status', 'Entry', 'Exit', 'Date'],
              data: students.map((s) {
                List<String> times = s['time'].split(' - ');
                return [
                  s['name'], 
                  s['status'], 
                  times[0], 
                  times.length > 1 ? times[1] : "-", 
                  selectedDate //
                ];
              }).toList(),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: 'Attendance_$selectedDate.pdf',
  );
}
