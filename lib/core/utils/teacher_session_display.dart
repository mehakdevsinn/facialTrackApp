import 'package:facialtrackapp/core/models/session_model.dart';
import 'package:intl/intl.dart';

/// Asia/Karachi offset from UTC (no DST).
const Duration _pktOffsetFromUtc = Duration(hours: 5);

/// Wall clock in PKT as a UTC [DateTime] (shifted +5h from real UTC) for formatting only.
DateTime teacherSessionUtcToPktWall(DateTime utcInstant) {
  return DateTime.fromMillisecondsSinceEpoch(
    utcInstant.toUtc().millisecondsSinceEpoch + _pktOffsetFromUtc.inMilliseconds,
    isUtc: true,
  );
}

String formatTeacherSessionDatePkt(DateTime? utc,
    {String pattern = 'MMMM d, y'}) {
  if (utc == null) return '';
  return DateFormat(pattern).format(teacherSessionUtcToPktWall(utc));
}

String formatTeacherSessionDateIsoPkt(DateTime? utc) =>
    formatTeacherSessionDatePkt(utc, pattern: 'yyyy-MM-dd');

String formatTeacherSessionTime12hPkt(DateTime? utc) {
  if (utc == null) return '';
  return DateFormat('h:mm a').format(teacherSessionUtcToPktWall(utc));
}

/// Session window label for logs/summary (Asia/Karachi).
String formatTeacherSessionWindowPkt(DateTime? startUtc, DateTime? endUtc) {
  if (startUtc == null) return '';
  final a = formatTeacherSessionTime12hPkt(startUtc);
  final b = formatTeacherSessionTime12hPkt(endUtc);
  if (endUtc == null || b.isEmpty) return '$a PKT';
  return '$a – $b PKT';
}

/// Attendance / API timestamp string → PKT time label.
String formatTeacherApiInstantTimePkt(String raw) {
  final utc = parseTeacherSessionInstantToUtc(raw);
  if (utc != null) return formatTeacherSessionTime12hPkt(utc);
  return raw;
}
