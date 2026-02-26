import 'package:flutter/material.dart';

/// Represents a single academic semester returned by
/// GET/POST /api/v1/admin/semesters
class SemesterModel {
  final String id;
  final int semesterNumber;
  final String academicSession;

  /// API values: "spring" | "fall" | "summer"
  final String termType;

  /// API values: "active" | "upcoming" | "completed"
  final String operationalStatus;

  final String startDate; // "YYYY-MM-DD"
  final String endDate; // "YYYY-MM-DD"

  const SemesterModel({
    required this.id,
    required this.semesterNumber,
    required this.academicSession,
    required this.termType,
    required this.operationalStatus,
    required this.startDate,
    required this.endDate,
  });

  // ── JSON → Model ──────────────────────────────────────────────────────────
  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id']?.toString() ?? '',
      semesterNumber: (json['semester_number'] as num?)?.toInt() ?? 0,
      academicSession: json['academic_session']?.toString() ?? '',
      termType: json['term_type']?.toString() ?? '',
      operationalStatus: json['operational_status']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
    );
  }

  // ── Model → JSON (for POST body) ──────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'semester_number': semesterNumber,
        'academic_session': academicSession,
        'term_type': termType,
        'operational_status': operationalStatus,
        'start_date': startDate,
        'end_date': endDate,
      };

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// E.g. "Spring 2025 — Semester 8"
  String get displayName =>
      '${_capitalise(termType)} ${academicSession.split('-').last} — Sem $semesterNumber';

  bool get isActive => operationalStatus == 'active';
  bool get isUpcoming => operationalStatus == 'upcoming';
  bool get isCompleted => operationalStatus == 'completed';

  Color get statusColor {
    switch (operationalStatus) {
      case 'active':
        return Colors.green;
      case 'upcoming':
        return Colors.orange;
      case 'completed':
      default:
        return Colors.grey;
    }
  }

  String get statusLabel => _capitalise(operationalStatus);
  String get termLabel => _capitalise(termType);

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  String toString() => displayName;
}
