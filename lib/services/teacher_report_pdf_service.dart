import 'package:facialtrackapp/core/models/report_models.dart';
import 'package:facialtrackapp/core/utils/attendance_display.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// PDF export for teacher-side attendance reports (printing package preview/share).
class TeacherReportPdfService {
  TeacherReportPdfService._();

  static final pw.Font _font = pw.Font.helvetica();

  static String _ascii(String s) =>
      s.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');

  static pw.TextStyle _titleStyle() => pw.TextStyle(
        font: _font,
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
      );

  static pw.TextStyle _bodyStyle({double size = 10}) =>
      pw.TextStyle(font: _font, fontSize: size);

  static String _policyFootnotePw() => _ascii(kAttendancePolicyBShort);

  static String _dailyStatusLine(DailyReportStudent s) {
    if (s.isPresent) return 'Present';
    if (s.isOnLeave) {
      final r = (s.leaveReason ?? '').trim();
      if (r.isEmpty) return 'On leave';
      final short = r.length > 60 ? '${r.substring(0, 57)}...' : r;
      return 'On leave — $short';
    }
    return 'Absent (unexcused)';
  }

  static String _methodFromRaw(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    return _ascii(verificationMethodLabel(raw) ?? raw);
  }

  static String _methodCell(CourseReportStudent s) =>
      _methodFromRaw(s.verificationMethod);

  static String? _semesterSubtitle(String? semesterLabel) {
    if (semesterLabel == null || semesterLabel.isEmpty) return null;
    return 'Semester: ${_ascii(semesterLabel)}';
  }

  static Future<void> layoutMonthlyReportPdf({
    required MonthlyReportResponse data,
    required int attendanceThresholdPercent,
    required List<CourseReportStudent> studentRows,
    String? semesterLabel,
  }) async {
    final monthLabel =
        DateFormat('MMMM yyyy').format(DateTime(data.year, data.month));
    final semSub = _semesterSubtitle(semesterLabel);
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text('Monthly Attendance Report', style: _titleStyle()),
          pw.SizedBox(height: 6),
          pw.Text(_policyFootnotePw(), style: _bodyStyle(size: 8)),
          pw.SizedBox(height: 4),
          pw.Text('Course: ${_ascii(data.courseName)}', style: _bodyStyle()),
          if (semSub != null) pw.Text(semSub, style: _bodyStyle(size: 9)),
          pw.Text('Period: $monthLabel', style: _bodyStyle()),
          pw.Text(
            'Low-attendance criterion: $attendanceThresholdPercent%',
            style: _bodyStyle(),
          ),
          pw.Text(
            'Absent (unexcused) counts only students not on excused leave.',
            style: _bodyStyle(size: 8),
          ),
          pw.Text(
            'Overall: ${data.overallAttendancePercentage.toStringAsFixed(1)}% | '
            'Sessions: ${data.totalSessions} | '
            'Present (slot sum): ${data.totalPresentAcrossSessions} | '
            'Absent (slot sum): ${data.totalAbsentAcrossSessions}',
            style: _bodyStyle(size: 9),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          if (data.sessions.isNotEmpty) ...[
            pw.Text('Sessions', style: _bodyStyle(size: 11)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: const [
                'Session date',
                'Present',
                'Absent (unexc.)',
                'On leave',
                'Enrolled',
              ],
              data: data.sessions
                  .map(
                    (e) => [
                      _ascii(formatPktDateLineFromApiString(e.sessionDate)),
                      '${e.presentCount}',
                      '${e.absentCount}',
                      '${e.onLeaveCount}',
                      '${e.totalEnrolled}',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                font: _font,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: _bodyStyle(size: 8),
            ),
            pw.SizedBox(height: 14),
          ],
          pw.Text(
            'Students (${studentRows.length})',
            style: _bodyStyle(size: 11),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Name',
              'Roll',
              'Attended',
              'Total',
              'On leave',
              'Unexcused',
              'Method',
              'Att %',
            ],
            data: studentRows
                .map(
                  (s) => [
                    _ascii(s.studentName),
                    _ascii(s.rollNumber),
                    '${s.sessionsAttended}',
                    '${s.totalSessions}',
                    '${s.sessionsOnLeave}',
                    '${s.sessionsMissedUnexcused}',
                    _methodCell(s),
                    '${s.attendancePercentage.toStringAsFixed(1)}%',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              font: _font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: _bodyStyle(size: 8),
          ),
        ],
      ),
    );
    final safeName = _ascii(data.courseName).replaceAll(RegExp(r'\s+'), '_');
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Monthly_${safeName}_$monthLabel.pdf',
    );
  }

  static Future<void> layoutLowAttendanceStudentsPdf({
    required String reportTitle,
    required String courseName,
    String? semesterLabel,
    required String periodOrRangeDescription,
    required int thresholdPercent,
    required List<CourseReportStudent> lowStudents,
  }) async {
    final pdf = pw.Document();
    final semSub = _semesterSubtitle(semesterLabel);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(_ascii(reportTitle), style: _titleStyle()),
          pw.SizedBox(height: 6),
          pw.Text(_policyFootnotePw(), style: _bodyStyle(size: 8)),
          pw.SizedBox(height: 4),
          pw.Text('Course: ${_ascii(courseName)}', style: _bodyStyle()),
          if (semSub != null) pw.Text(semSub, style: _bodyStyle(size: 9)),
          pw.Text(
            'Period: ${_ascii(periodOrRangeDescription)}',
            style: _bodyStyle(),
          ),
          pw.Text(
            'Criterion: attendance strictly below $thresholdPercent%',
            style: _bodyStyle(size: 9),
          ),
          pw.Text(
            'Missed column = unexcused absences only (Policy B).',
            style: _bodyStyle(size: 8),
          ),
          pw.Text('Students below threshold: ${lowStudents.length}',
              style: _bodyStyle(size: 9)),
          pw.Divider(),
          pw.SizedBox(height: 8),
          if (lowStudents.isEmpty)
            pw.Text('No students match this criterion.', style: _bodyStyle())
          else
            pw.TableHelper.fromTextArray(
              headers: const [
                'Name',
                'Roll',
                'Att %',
                'Present',
                'Total',
                'On leave',
                'Unexcused',
              ],
              data: lowStudents
                  .map(
                    (s) => [
                      _ascii(s.studentName),
                      _ascii(s.rollNumber),
                      '${s.attendancePercentage.toStringAsFixed(1)}%',
                      '${s.sessionsAttended}',
                      '${s.totalSessions}',
                      '${s.sessionsOnLeave}',
                      '${s.sessionsMissedUnexcused}',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                font: _font,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: _bodyStyle(size: 8),
            ),
        ],
      ),
    );
    final safeName = _ascii(courseName).replaceAll(RegExp(r'\s+'), '_');
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'LowAttendance_$safeName.pdf',
    );
  }

  static Future<void> layoutCourseReportPdf({
    required CourseReportResponse data,
    String? dateRangeLabel,
    CourseReportStudent? highlightStudent,
    String? semesterLabel,
  }) async {
    final pdf = pw.Document();
    final range = dateRangeLabel ?? _courseDateRangeLine(data.dateRange);
    final presentSum =
        data.students.fold<int>(0, (a, s) => a + s.sessionsAttended);
    final missedSum = data.students
        .fold<int>(0, (a, s) => a + s.sessionsMissedUnexcused);
    final leaveSum =
        data.students.fold<int>(0, (a, s) => a + s.sessionsOnLeave);
    final semSub = _semesterSubtitle(semesterLabel);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text(
            highlightStudent == null
                ? 'Semester / Course Report'
                : 'Student focus (semester report)',
            style: _titleStyle(),
          ),
          pw.SizedBox(height: 6),
          pw.Text(_policyFootnotePw(), style: _bodyStyle(size: 8)),
          pw.SizedBox(height: 4),
          pw.Text('Course: ${_ascii(data.courseName)}', style: _bodyStyle()),
          if (semSub != null) pw.Text(semSub, style: _bodyStyle(size: 9)),
          if (range.isNotEmpty)
            pw.Text('Date range: $range', style: _bodyStyle()),
          pw.Text(
            'Class avg: ${data.courseAveragePercentage.toStringAsFixed(1)}% | '
            'Scheduled sessions: ${data.totalSessions} | '
            'Present (sum): $presentSum | unexcused missed (sum): $missedSum | '
            'on leave sessions (sum): $leaveSum',
            style: _bodyStyle(size: 9),
          ),
          if (highlightStudent != null) ...[
            pw.SizedBox(height: 10),
            pw.Text('Selected student summary', style: _bodyStyle(size: 11)),
            pw.SizedBox(height: 4),
            pw.Bullet(
              text:
                  '${_ascii(highlightStudent.studentName)} (${_ascii(highlightStudent.rollNumber)}) — '
                  '${highlightStudent.sessionsAttended}/${highlightStudent.totalSessions} present, '
                  '${highlightStudent.attendancePercentage.toStringAsFixed(1)}%',
              style: _bodyStyle(size: 9),
            ),
          ],
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text('All students', style: _bodyStyle(size: 11)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Name',
              'Roll',
              'Present',
              'Total',
              'On leave',
              'Unexcused',
              'Method',
              'Att %',
            ],
            data: data.students
                .map(
                  (s) => [
                    _ascii(s.studentName),
                    _ascii(s.rollNumber),
                    '${s.sessionsAttended}',
                    '${s.totalSessions}',
                    '${s.sessionsOnLeave}',
                    '${s.sessionsMissedUnexcused}',
                    _methodCell(s),
                    '${s.attendancePercentage.toStringAsFixed(1)}%',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              font: _font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: _bodyStyle(size: 8),
          ),
        ],
      ),
    );
    final safeName = _ascii(data.courseName).replaceAll(RegExp(r'\s+'), '_');
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Course_$safeName.pdf',
    );
  }

  static String _courseDateRangeLine(CourseDateRangeModel? dr) {
    if (dr == null) return '';
    final a = dr.start == null || dr.start!.isEmpty
        ? ''
        : _ascii(formatPktDateLineFromApiString(dr.start));
    final b = dr.end == null || dr.end!.isEmpty
        ? ''
        : _ascii(formatPktDateLineFromApiString(dr.end));
    if (a.isEmpty && b.isEmpty) return '';
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;
    return '$a - $b';
  }

  static Future<void> layoutDailyRollCallPdf({
    required DailyReportResponse data,
    required String titleDateLine,
    String? semesterLabel,
  }) async {
    final semSub = _semesterSubtitle(semesterLabel);
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Text('Daily Attendance (Day Inspection)', style: _titleStyle()),
          pw.SizedBox(height: 6),
          pw.Text(_policyFootnotePw(), style: _bodyStyle(size: 8)),
          pw.SizedBox(height: 4),
          pw.Text('Date: ${_ascii(titleDateLine)}', style: _bodyStyle()),
          pw.Text('Course: ${_ascii(data.courseName)}', style: _bodyStyle()),
          if (semSub != null) pw.Text(semSub, style: _bodyStyle(size: 9)),
          pw.Text(
            'Enrolled: ${data.totalEnrolled} | Present: ${data.presentCount} | '
            'Absent (unexcused): ${data.absentCount} | Rate: '
            '${data.attendancePercentage.toStringAsFixed(1)}%',
            style: _bodyStyle(size: 9),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Name',
              'Roll',
              'Status',
              'In time (PKT)',
              'Method',
            ],
            data: data.students
                .map(
                  (s) => [
                    _ascii(s.studentName),
                    _ascii(s.rollNumber),
                    _ascii(_dailyStatusLine(s)),
                    s.markedAt == null || s.markedAt!.isEmpty
                        ? '-'
                        : _ascii(
                            formatPktTimeLineFromApiString(s.markedAt),
                          ),
                    _methodFromRaw(s.verificationMethod),
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              font: _font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: _bodyStyle(size: 8),
          ),
        ],
      ),
    );
    final safeName = _ascii(data.courseName).replaceAll(RegExp(r'\s+'), '_');
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Daily_$safeName.pdf',
    );
  }

  static Future<void> layoutStudentAttendanceSummaryPdf({
    required CourseReportStudent student,
    required int courseTotalSessions,
    required String rangeLabel,
    String? courseName,
  }) async {
    final absentU = student.sessionsMissedUnexcused;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Student attendance summary', style: _titleStyle()),
            pw.SizedBox(height: 12),
            if (courseName != null && courseName.isNotEmpty)
              pw.Text('Course: ${_ascii(courseName)}', style: _bodyStyle()),
            pw.Text('Range: ${_ascii(rangeLabel)}', style: _bodyStyle()),
            pw.SizedBox(height: 16),
            pw.Text(
              '${_ascii(student.studentName)} (${_ascii(student.rollNumber)})',
              style: pw.TextStyle(
                font: _font,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Present: ${student.sessionsAttended}', style: _bodyStyle()),
            pw.Text('Unexcused absent: $absentU', style: _bodyStyle()),
            pw.Text('On leave (sessions): ${student.sessionsOnLeave}', style: _bodyStyle()),
            pw.Text('Total classes: ${student.totalSessions}', style: _bodyStyle()),
            pw.Text(
              'Attendance %: ${student.attendancePercentage.toStringAsFixed(2)}%',
              style: _bodyStyle(),
            ),
            pw.Text('Late count: ${student.lateCount}', style: _bodyStyle()),
            pw.SizedBox(height: 8),
            pw.Text(_policyFootnotePw(), style: _bodyStyle(size: 9)),
            pw.SizedBox(height: 20),
            pw.Text(
              'Per-day logs are not included; figures reflect the selected '
              'analytics range from the server.',
              style: _bodyStyle(size: 9),
            ),
          ],
        ),
      ),
    );
    final safe =
        _ascii(student.studentName).replaceAll(RegExp(r'\s+'), '_');
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Student_${safe}_summary.pdf',
    );
  }
}
