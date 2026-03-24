import 'package:flutter/material.dart';

// ── Period / Break slot ────────────────────────────────────────────────────

/// A single time slot in the timetable — either a teaching period or a break.
class PeriodSlot {
  final String id;
  final bool isBreak;
  final String label; // "Period 1", "Break", etc.
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const PeriodSlot({
    required this.id,
    required this.isBreak,
    required this.label,
    required this.startTime,
    required this.endTime,
  });

  /// Formatted duration label, e.g. "08:00 – 09:00".
  String get timeRange {
    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '${fmt(startTime)} – ${fmt(endTime)}';
  }

  PeriodSlot copyWith({
    String? id,
    bool? isBreak,
    String? label,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return PeriodSlot(
      id: id ?? this.id,
      isBreak: isBreak ?? this.isBreak,
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'is_break': isBreak,
        'label': label,
        'start_time': _fmtTime(startTime),
        'end_time': _fmtTime(endTime),
      };

  factory PeriodSlot.fromJson(Map<String, dynamic> json) => PeriodSlot(
        id: json['id'] as String,
        isBreak: json['is_break'] as bool,
        label: json['label'] as String,
        startTime: _parseTime(json['start_time'] as String),
        endTime: _parseTime(json['end_time'] as String),
      );

  /// Parse "HH:MM" → TimeOfDay
  static TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Format TimeOfDay → "HH:MM"
  static String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

// ── Timetable cell entry ───────────────────────────────────────────────────

/// Assignment for one cell: a specific day × period.
class TimetableEntry {
  final String day; // "Mon", "Tue", "Wed", "Thu", "Fri"
  final String periodId; // matches PeriodSlot.id
  final String courseCode;
  final String courseTitle;
  final String teacherName;

  const TimetableEntry({
    required this.day,
    required this.periodId,
    required this.courseCode,
    required this.courseTitle,
    required this.teacherName,
  });

  TimetableEntry copyWith({
    String? courseCode,
    String? courseTitle,
    String? teacherName,
  }) {
    return TimetableEntry(
      day: day,
      periodId: periodId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'period_id': periodId,
        'course_code': courseCode,
        'course_title': courseTitle,
        'teacher_name': teacherName,
      };

  factory TimetableEntry.fromJson(Map<String, dynamic> json) => TimetableEntry(
        day: json['day'],
        periodId: json['period_id'],
        courseCode: json['course_code'],
        courseTitle: json['course_title'],
        teacherName: json['teacher_name'],
      );
}

// ── Timetable ───────────────────────────────────────────────────────────────

/// Full weekly timetable for a Semester × Section.
class Timetable {
  final String id;
  final int semesterNumber;
  final String semesterId;
  final String academicSession; // e.g. "2023-27"
  final String section; // "A", "B", …
  final List<PeriodSlot> periods; // ordered list, may include a break
  final List<TimetableEntry> entries;

  Timetable({
    required this.id,
    required this.semesterNumber,
    required this.semesterId,
    required this.academicSession,
    required this.section,
    required this.periods,
    required this.entries,
  });

  /// Returns the entry for a specific day + period, or null if empty.
  TimetableEntry? entryFor(String day, String periodId) {
    try {
      return entries.firstWhere((e) => e.day == day && e.periodId == periodId);
    } catch (_) {
      return null;
    }
  }

  /// Short display label, e.g. "Sem 6 — Sec A".
  String get displayTitle => 'Sem $semesterNumber — Sec $section';

  /// Session + semester label for the grid header.
  String get headerLabel =>
      'Semester-$semesterNumber   Session: $academicSession';

  Timetable copyWith({
    List<PeriodSlot>? periods,
    List<TimetableEntry>? entries,
  }) {
    return Timetable(
      id: id,
      semesterNumber: semesterNumber,
      semesterId: semesterId,
      academicSession: academicSession,
      section: section,
      periods: periods ?? this.periods,
      entries: entries ?? this.entries,
    );
  }
}
