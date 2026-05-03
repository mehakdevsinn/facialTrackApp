/// GET /api/v1/students/settings/attendance-criteria (student JWT).
class StudentAttendanceCriteriaSettings {
  final int attendanceThresholdPercent;
  final String? updatedAt;

  const StudentAttendanceCriteriaSettings({
    required this.attendanceThresholdPercent,
    this.updatedAt,
  });

  factory StudentAttendanceCriteriaSettings.fromJson(Map<String, dynamic> json) {
    final raw = json['attendance_threshold_percent'];
    final parsed = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    return StudentAttendanceCriteriaSettings(
      attendanceThresholdPercent: (parsed ?? 75).clamp(50, 100),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
