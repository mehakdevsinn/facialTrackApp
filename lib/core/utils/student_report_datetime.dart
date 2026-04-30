import 'package:intl/intl.dart';

/// Pakistan (Asia/Karachi) display rules for student report APIs.
/// Naive strings (no Z / no offset) = wall clock in PKT → stored as UTC instants.
/// Explicit Z/offset → parse as real instant, then format in PKT (+5 from UTC).
const Duration _pktOffset = Duration(hours: 5);

bool reportDatetimeHasExplicitZone(String s) {
  final t = s.trim();
  if (t.endsWith('Z')) return true;
  // +hh:mm or +hhmm or -hh:mm at end (not just a middle T)
  return RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(t) ||
      RegExp(r'[+-]\d{4}$').hasMatch(t);
}

/// Converts API datetime string to a UTC [DateTime] instant, or null.
DateTime? parseReportToUtcInstant(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;

  if (reportDatetimeHasExplicitZone(s)) {
    return DateTime.parse(s).toUtc();
  }

  final normalized = s.replaceFirst(' ', 'T');
  final m = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})[T](\d{2}):(\d{2}):(\d{2})(\.\d+)?',
  ).firstMatch(normalized);
  if (m != null) {
    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    final h = int.parse(m.group(4)!);
    final mi = int.parse(m.group(5)!);
    final sec = int.parse(m.group(6)!);
    // Naive wall time in PKT → UTC instant is wall minus 5h on the same labels.
    return DateTime.utc(y, mo, d, h, mi, sec).subtract(_pktOffset);
  }

  final dOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (dOnly != null) {
    final y = int.parse(dOnly.group(1)!);
    final mo = int.parse(dOnly.group(2)!);
    final d = int.parse(dOnly.group(3)!);
    return DateTime.utc(y, mo, d, 0, 0, 0).subtract(_pktOffset);
  }

  try {
    return DateTime.parse(s).toUtc();
  } catch (_) {
    return null;
  }
}

/// Wall-clock in PKT as a UTC [DateTime] (shifted +5h from real UTC) for formatting only.
DateTime _pktWallClockForFormat(DateTime utcInstant) {
  return DateTime.fromMillisecondsSinceEpoch(
    utcInstant.toUtc().millisecondsSinceEpoch + _pktOffset.inMilliseconds,
    isUtc: true,
  );
}

String formatPktTime12h(DateTime utcInstant) {
  final w = _pktWallClockForFormat(utcInstant);
  return DateFormat('hh:mm a').format(w);
}

String formatPktDateCard(DateTime utcInstant) {
  final w = _pktWallClockForFormat(utcInstant);
  return DateFormat('MMM dd, yyyy').format(w);
}

String formatPktDayName(DateTime utcInstant) {
  final w = _pktWallClockForFormat(utcInstant);
  return DateFormat('EEEE').format(w);
}

String formatPktDateIso(DateTime utcInstant) {
  final w = _pktWallClockForFormat(utcInstant);
  return DateFormat('yyyy-MM-dd').format(w);
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
  final w = _pktWallClockForFormat(DateTime.now().toUtc());
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
    final p = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s.trim());
    if (p == null) return DateTime.parse(s);
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
