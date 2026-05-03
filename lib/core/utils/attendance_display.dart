import 'package:flutter/material.dart';

/// Policy B: attendance % uses eligible sessions only (leave excluded from denominator).
/// Use API-provided percentages when available.
const String kAttendancePolicyBShort =
    'Attendance % uses eligible class sessions only (excused leave does not reduce your percentage). '
    'Absent counts are unexcused absences unless labelled otherwise.';

/// Visual state for a session row (teacher or student UI).
enum SessionAttendanceVisualState {
  present,
  onLeave,
  absentUnexcused,
}

SessionAttendanceVisualState sessionRowVisualState({
  required bool isPresent,
  required bool onLeave,
}) {
  if (isPresent) return SessionAttendanceVisualState.present;
  if (onLeave) return SessionAttendanceVisualState.onLeave;
  return SessionAttendanceVisualState.absentUnexcused;
}

String sessionAttendanceStatusLabel(SessionAttendanceVisualState s) {
  switch (s) {
    case SessionAttendanceVisualState.present:
      return 'Present';
    case SessionAttendanceVisualState.onLeave:
      return 'On leave';
    case SessionAttendanceVisualState.absentUnexcused:
      return 'Absent';
  }
}

Color sessionAttendanceStatusColor(SessionAttendanceVisualState s) {
  switch (s) {
    case SessionAttendanceVisualState.present:
      return Colors.green;
    case SessionAttendanceVisualState.onLeave:
      return Colors.indigo;
    case SessionAttendanceVisualState.absentUnexcused:
      return Colors.deepOrange;
  }
}
