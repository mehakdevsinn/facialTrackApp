/// Response from skip-period APIs:
/// POST .../schedule/skip-period
/// GET  .../schedule/skips
class TimetablePeriodSkipResponse {
  final String id;
  final String timetableId;
  final String classDate;
  final String periodId;
  final String teacherId;
  final String? reason;
  final String createdAtRaw;
  final String updatedAtRaw;

  const TimetablePeriodSkipResponse({
    required this.id,
    required this.timetableId,
    required this.classDate,
    required this.periodId,
    required this.teacherId,
    this.reason,
    required this.createdAtRaw,
    required this.updatedAtRaw,
  });

  factory TimetablePeriodSkipResponse.fromJson(Map<String, dynamic> json) {
    return TimetablePeriodSkipResponse(
      id: json['id']?.toString() ?? '',
      timetableId: json['timetable_id']?.toString() ?? '',
      classDate: json['class_date']?.toString() ?? '',
      periodId: json['period_id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? '',
      reason: json['reason']?.toString(),
      createdAtRaw: json['created_at']?.toString() ?? '',
      updatedAtRaw: json['updated_at']?.toString() ?? '',
    );
  }
}
