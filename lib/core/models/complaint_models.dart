/// Shared complaint payload from backend (list + detail).
class ComplaintItem {
  final String id;
  final String? category;
  final String reason;
  /// Raw: pending, approved, rejected, resolved
  final String status;
  final String? recipientRole;
  final String? complainantRole;
  final String? sessionId;
  final String? studentId;
  final String? complainantName;
  final String? complainantRoleLabel;
  final String? rollNumber;
  final String? courseName;
  final String? sessionDateRaw;
  final String? reviewNotes;
  final String? reviewedAtRaw;
  final String? createdAtRaw;

  const ComplaintItem({
    required this.id,
    this.category,
    required this.reason,
    required this.status,
    this.recipientRole,
    this.complainantRole,
    this.sessionId,
    this.studentId,
    this.complainantName,
    this.complainantRoleLabel,
    this.rollNumber,
    this.courseName,
    this.sessionDateRaw,
    this.reviewNotes,
    this.reviewedAtRaw,
    this.createdAtRaw,
  });

  factory ComplaintItem.fromJson(Map<String, dynamic> json) {
    return ComplaintItem(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString(),
      reason: json['reason']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      recipientRole: json['recipient_role']?.toString(),
      complainantRole: json['complainant_role']?.toString(),
      sessionId: json['session_id']?.toString(),
      studentId: json['student_id']?.toString(),
      complainantName: json['complainant_name']?.toString(),
      complainantRoleLabel: json['complainant_role_label']?.toString(),
      rollNumber: json['roll_number']?.toString(),
      courseName: json['course_name']?.toString(),
      sessionDateRaw: json['session_date']?.toString(),
      reviewNotes: json['review_notes']?.toString(),
      reviewedAtRaw: json['reviewed_at']?.toString(),
      createdAtRaw: json['created_at']?.toString(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  /// Green badge text per product guide.
  String get badgeLabel {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'approved':
      case 'resolved':
        return 'RESOLVED';
      case 'rejected':
        return 'REJECTED';
      default:
        return status.toUpperCase();
    }
  }

  static const Map<String, String> studentAdminCategoryLabels = {
    'not_promoted': 'Not Promoted',
    'wrong_semester_assigned': 'Wrong Semester Assigned',
    'subject_not_visible': 'Subject Not Visible',
    'timetable_issue': 'Timetable Issue',
    'other': 'Other',
  };

  static const Map<String, String> teacherAdminCategoryLabels = {
    'session_issue': 'Session Issue',
    'facility_issue': 'Facility Issue',
    'administrative_issue': 'Administrative Issue',
    'other': 'Other',
  };

  String? get categoryDisplayLabel {
    final c = category;
    if (c == null || c.isEmpty) return null;
    return studentAdminCategoryLabels[c] ??
        teacherAdminCategoryLabels[c] ??
        _titleCaseSnake(c);
  }

  static String _titleCaseSnake(String s) {
    return s.split('_').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
