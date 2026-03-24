import 'package:facialtrackapp/core/models/timetable_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SchedulePdfService {
  static Future<void> exportToPDF(Timetable timetable) async {
    final pdf = pw.Document();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final periods = timetable.periods;

    const headerHeight = 35.0;
    const cellHeight = 35.0;

    pw.Widget buildCell({
      double? w,
      required double h,
      required pw.Widget child,
      bool isHeader = false,
    }) {
      return pw.Container(
        width: w,
        height: h,
        alignment: isHeader ? pw.Alignment.center : pw.Alignment.topLeft,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(width: 0.8),
            right: pw.BorderSide(width: 0.8),
          ),
        ),
        child: child,
      );
    }

    final columns = <pw.Widget>[];

    // Day Column (Fixed Width)
    columns.add(
      pw.Column(
        children: [
          buildCell(
            w: 50,
            h: headerHeight,
            isHeader: true,
            child: pw.Text('Mon-to-\nFri',
                style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic, fontSize: 9),
                textAlign: pw.TextAlign.center),
          ),
          ...days.map((d) => buildCell(
                w: 50,
                h: cellHeight,
                isHeader: true,
                child: pw.Text(d,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
              )),
        ],
      ),
    );

    // Period Columns (Expanded)
    for (final p in periods) {
      if (p.isBreak) {
        // Break column - narrower, fixed width, 5-row span cell
        columns.add(
          pw.Column(
            children: [
              buildCell(
                w: 55, // wider break column
                h: headerHeight,
                isHeader: true,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('Break',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      p.timeRange.replaceAll(RegExp(r'\s*[-–—]\s*'), ' - '),
                      style: pw.TextStyle(
                          fontStyle: pw.FontStyle.italic, fontSize: 8),
                    ),
                  ],
                ),
              ),
              buildCell(
                w: 55,
                h: cellHeight * 5, // spanning exactly all 5 day cells!
                isHeader: true,
                child: pw.Center(
                  child: pw.Text(
                    'Break',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Regular period column - flexible width
        columns.add(
          pw.Expanded(
            child: pw.Column(
              children: [
                buildCell(
                  w: double.infinity,
                  h: headerHeight,
                  isHeader: true,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        p.label,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        p.timeRange.replaceAll(RegExp(r'\s*[-–—]\s*'), ' - '),
                        style: pw.TextStyle(
                            fontStyle: pw.FontStyle.italic, fontSize: 8),
                      ),
                    ],
                  ),
                ),
                ...days.map((day) {
                  final entry = timetable.entryFor(day, p.id);
                  if (entry == null) {
                    return buildCell(
                        w: double.infinity,
                        h: cellHeight,
                        child: pw.SizedBox());
                  }
                  return buildCell(
                    w: double.infinity,
                    h: cellHeight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          entry.courseCode,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            decoration: pw.TextDecoration.underline, // Exactly like image
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          entry.teacherName,
                          style: const pw.TextStyle(fontSize: 9),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Academic/Official Centered Header exactly like reference
              pw.Text(
                'Timetable',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Department of Computer Science',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Semester-${timetable.semesterNumber}   Session: ${timetable.academicSession.replaceAll(RegExp(r'[-–—]'), '-')}',
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Section: ${timetable.section}',
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),

              // The Custom Grid Table mapping the exact image style
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(width: 0.8),
                    left: pw.BorderSide(width: 0.8),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: columns,
                ),
              ),
              pw.Spacer(),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('________________________\nHead of Department',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center),
                  pw.Text('________________________\nTimetable Incharge',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey400),
              pw.Center(
                child: pw.Text(
                  'Generated by FacialTrack Admin System - ${DateTime.now().toString().substring(0, 16)}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Timetable_Sem${timetable.semesterNumber}_Sec${timetable.section}.pdf',
    );
  }
}
