import 'package:facialtrackapp/core/models/session_model.dart';
import 'package:intl/intl.dart';

/// Pakistan (Asia/Karachi) display rules for student report APIs.
///
/// API instants are stored on the server as **UTC**; JSON often omits `Z`.
/// [parseReportToUtcInstant] uses the same rules as teacher session parsing:
/// naive ISO → UTC wall, then [formatPkt*] shifts +5h for display labels.
///
/// Datetimes with explicit `Z` or `±hh:mm` are parsed as real instants, then
/// formatted in PKT for UI.
const Duration _pktOffset = Duration(hours: 5);

/// Converts student report / session API datetime strings to a UTC instant.
///
/// Delegates to [parseTeacherSessionInstantToUtc] so history, session detail,
/// and teacher sessions agree on naive-without-`Z` = **UTC** storage.
DateTime? parseReportToUtcInstant(String? raw) =>
    parseTeacherSessionInstantToUtc(raw);

/// Wall-clock in PKT as a UTC [DateTime] (shifted +5h from real UTC) for formatting only.
DateTime reportUtcToPktWallForDisplay(DateTime utcInstant) {
  return DateTime.fromMillisecondsSinceEpoch(
    utcInstant.toUtc().millisecondsSinceEpoch + _pktOffset.inMilliseconds,
    isUtc: true,
  );
}

String formatPktTime12h(DateTime utcInstant) {
  final w = reportUtcToPktWallForDisplay(utcInstant);
  return DateFormat('hh:mm a').format(w);
}

String formatPktDateCard(DateTime utcInstant) {
  final w = reportUtcToPktWallForDisplay(utcInstant);
  return DateFormat('MMM dd, yyyy').format(w);
}

String formatPktDayName(DateTime utcInstant) {
  final w = reportUtcToPktWallForDisplay(utcInstant);
  return DateFormat('EEEE').format(w);
}

String formatPktDateIso(DateTime utcInstant) {
  final w = reportUtcToPktWallForDisplay(utcInstant);
  return DateFormat('yyyy-MM-dd').format(w);
}

/// Local [DateTime] at midnight for the PKT calendar day of [utcInstant].
DateTime pktCalendarDateLocalFromUtc(DateTime utcInstant) {
  final w = reportUtcToPktWallForDisplay(utcInstant);
  return DateTime(w.year, w.month, w.day);
}

/// Raw API date/datetime (often naive UTC) → PKT date label, or trimmed raw if unparseable.
String formatPktDateLineFromApiString(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final u = parseReportToUtcInstant(raw);
  if (u == null) return raw.trim();
  return formatPktDateCard(u);
}

/// Raw API datetime → `MMM dd, yyyy · hh:mm a` in PKT.
String formatPktDateTimeLineFromApiString(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final u = parseReportToUtcInstant(raw);
  if (u == null) return raw.trim();
  return '${formatPktDateCard(u)} · ${formatPktTime12h(u)}';
}

/// Raw API datetime → `hh:mm a` in PKT.
String formatPktTimeLineFromApiString(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final u = parseReportToUtcInstant(raw);
  if (u == null) return raw.trim();
  return formatPktTime12h(u);
}

/// Time range "hh:mm a - hh:mm a" or "---- - ----" if both missing.
String formatPktEntryExitRange(DateTime? entryUtc, DateTime? exitUtc) {
  if (entryUtc == null && exitUtc == null) return '---- - ----';
  final a = entryUtc != null ? formatPktTime12h(entryUtc) : '----';
  final b = exitUtc != null ? formatPktTime12h(exitUtc) : '----';
  return '$a - $b';
}

/// Year/month in PKT for "today" (month picker default).
({int year, int month}) currentYearMonthPkt() {
  final w = reportUtcToPktWallForDisplay(DateTime.now().toUtc());
  return (year: w.year, month: w.month);
}

/// Inclusive calendar months from [start] to [end] (date-only ISO bounds).
List<({int year, int month, String label})> monthRangeInclusive(
  String? monthPickerStart,
  String? monthPickerEnd,
) {
  if (monthPickerStart == null ||
      monthPickerEnd == null ||
      monthPickerStart.isEmpty ||
      monthPickerEnd.isEmpty) {
    return [];
  }
  DateTime parseDay(String s) {
    final t = s.trim();
    final p = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(t);
    if (p == null) return DateTime.parse(t);
    final iso = '${p.group(1)!}-${p.group(2)!}-${p.group(3)!}';
    final u = parseReportToUtcInstant(iso);
    if (u != null) return pktCalendarDateLocalFromUtc(u);
    return DateTime(
      int.parse(p.group(1)!),
      int.parse(p.group(2)!),
      int.parse(p.group(3)!),
    );
  }

  final start = parseDay(monthPickerStart);
  final end = parseDay(monthPickerEnd);
  var y = start.year;
  var m = start.month;
  final endY = end.year;
  final endM = end.month;
  final out = <({int year, int month, String label})>[];
  while (y < endY || (y == endY && m <= endM)) {
    final label = DateFormat('MMMM yyyy').format(DateTime(y, m));
    out.add((year: y, month: m, label: label));
    m++;
    if (m > 12) {
      m = 1;
      y++;
    }
  }
  return out;
}

String? verificationMethodLabel(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  switch (raw) {
    case 'facial_recognition':
      return 'Face ID';
    case 'manual':
      return 'Manual';
    case 'complaint_approved':
      return 'Approved';
    default:
      return raw;
  }
}
