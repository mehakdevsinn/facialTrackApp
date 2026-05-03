import 'package:facialtrackapp/core/utils/teacher_session_display.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// ASCII-safe for basic PDF fonts.
String _ascii(String s) => s.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');

/// Session attendance log export (after session ends).
/// Heading: date, semester number, subject, session start/end (PKT).
/// Table: Student name, Status, In time, Method.
Future<void> exportSessionAttendanceLogsPdf({
  required String dateDisplay,
  required int? semesterNumber,
  required String subjectName,
  required String sessionStartPkt,
  required String sessionEndPkt,
  required List<Map<String, dynamic>> rows,
  String? fileNameDate,
}) async {
  final font = pw.Font.helvetica();
  final titleStyle = pw.TextStyle(
    font: font,
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
  );
  final body = pw.TextStyle(font: font, fontSize: 10);
  final small = pw.TextStyle(font: font, fontSize: 9);

  final semLine = semesterNumber != null
      ? 'Semester number: $semesterNumber'
      : 'Semester number: —';
  final startLine =
      sessionStartPkt.isEmpty ? '—' : _ascii('$sessionStartPkt PKT');
  final endLine = sessionEndPkt.isEmpty ? '—' : _ascii('$sessionEndPkt PKT');

  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        pw.Text('OFFICIAL ATTENDANCE LOG', style: titleStyle),
        pw.SizedBox(height: 10),
        pw.Text('Date: ${_ascii(dateDisplay)}', style: body),
        pw.Text(semLine, style: body),
        pw.Text('Subject: ${_ascii(subjectName)}', style: body),
        pw.Text('Session start: $startLine', style: small),
        pw.Text('Session end: $endLine', style: small),
        pw.SizedBox(height: 14),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const [
            'Student name',
            'Status',
            'In time',
            'Method',
          ],
          data: rows
              .map(
                (r) => [
                  _ascii((r['name'] ?? '').toString()),
                  _ascii((r['status'] ?? '').toString()),
                  _ascii((r['inTime'] ?? '-').toString()),
                  _ascii((r['method'] ?? '-').toString()),
                ],
              )
              .toList(),
          headerStyle: pw.TextStyle(
            font: font,
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
          cellStyle: pw.TextStyle(font: font, fontSize: 8),
        ),
      ],
    ),
  );

  final iso = (fileNameDate != null && fileNameDate.isNotEmpty)
      ? fileNameDate.replaceAll(RegExp(r'[^\d\-]'), '')
      : formatTeacherSessionDateIsoPkt(DateTime.now().toUtc());
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: 'Attendance_Logs_$iso.pdf',
  );
}
