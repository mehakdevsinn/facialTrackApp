import 'package:flutter/material.dart';

/// Static dummy student data used before the real API is available.
/// Each student map has:
///   id, fullName, rollNo, email, phone, semesterNumber, section,
///   enrollmentDate, faceEnrolled
class StudentDummyData {
  StudentDummyData._();

  static final List<Map<String, dynamic>> _students = [
    // ── Semester 1 ─────────────────────────────────────────────────────────
    {
      'id': 'stu-001',
      'fullName': 'Ali Hassan',
      'rollNo': 'BSCS-F21-001',
      'email': 'ali.hassan@student.edu',
      'phone': '0301-1234567',
      'semesterNumber': 1,
      'section': 'A',
      'enrollmentDate': '2024-09-01',
      'faceEnrolled': true,
    },
    {
      'id': 'stu-002',
      'fullName': 'Fatima Noor',
      'rollNo': 'BSCS-F21-002',
      'email': 'fatima.noor@student.edu',
      'phone': '0302-2345678',
      'semesterNumber': 1,
      'section': 'A',
      'enrollmentDate': '2024-09-01',
      'faceEnrolled': false,
    },
    {
      'id': 'stu-003',
      'fullName': 'Usman Tariq',
      'rollNo': 'BSCS-F21-003',
      'email': 'usman.tariq@student.edu',
      'phone': '0303-3456789',
      'semesterNumber': 1,
      'section': 'B',
      'enrollmentDate': '2024-09-01',
      'faceEnrolled': true,
    },
    // ── Semester 2 ─────────────────────────────────────────────────────────
    {
      'id': 'stu-004',
      'fullName': 'Ayesha Malik',
      'rollNo': 'BSCS-F20-001',
      'email': 'ayesha.malik@student.edu',
      'phone': '0304-4567890',
      'semesterNumber': 2,
      'section': 'A',
      'enrollmentDate': '2023-09-01',
      'faceEnrolled': true,
    },
    {
      'id': 'stu-005',
      'fullName': 'Hamza Qureshi',
      'rollNo': 'BSCS-F20-002',
      'email': 'hamza.qureshi@student.edu',
      'phone': '0305-5678901',
      'semesterNumber': 2,
      'section': 'B',
      'enrollmentDate': '2023-09-01',
      'faceEnrolled': false,
    },
    // ── Semester 3 ─────────────────────────────────────────────────────────
    {
      'id': 'stu-006',
      'fullName': 'Zara Ahmed',
      'rollNo': 'BSCS-F19-001',
      'email': 'zara.ahmed@student.edu',
      'phone': '0306-6789012',
      'semesterNumber': 3,
      'section': 'A',
      'enrollmentDate': '2022-09-01',
      'faceEnrolled': true,
    },
    {
      'id': 'stu-007',
      'fullName': 'Bilal Akhtar',
      'rollNo': 'BSCS-F19-002',
      'email': 'bilal.akhtar@student.edu',
      'phone': '0307-7890123',
      'semesterNumber': 3,
      'section': 'C',
      'enrollmentDate': '2022-09-01',
      'faceEnrolled': true,
    },
    // ── Semester 4 ─────────────────────────────────────────────────────────
    {
      'id': 'stu-008',
      'fullName': 'Sara Khan',
      'rollNo': 'BSCS-F18-001',
      'email': 'sara.khan@student.edu',
      'phone': '0308-8901234',
      'semesterNumber': 4,
      'section': 'B',
      'enrollmentDate': '2021-09-01',
      'faceEnrolled': false,
    },
    // ── Semester 5 ─────────────────────────────────────────────────────────
    {
      'id': 'stu-009',
      'fullName': 'Omar Siddiqui',
      'rollNo': 'BSCS-F17-001',
      'email': 'omar.siddiqui@student.edu',
      'phone': '0309-9012345',
      'semesterNumber': 5,
      'section': 'A',
      'enrollmentDate': '2020-09-01',
      'faceEnrolled': true,
    },
    {
      'id': 'stu-010',
      'fullName': 'Hina Riaz',
      'rollNo': 'BSCS-F17-002',
      'email': 'hina.riaz@student.edu',
      'phone': '0310-0123456',
      'semesterNumber': 5,
      'section': 'D',
      'enrollmentDate': '2020-09-01',
      'faceEnrolled': true,
    },
    // ── Semester 6 ─────────────────────────────────────────────────────────
    {
      'id': 'stu-011',
      'fullName': 'Kamran Shah',
      'rollNo': 'BSCS-F16-001',
      'email': 'kamran.shah@student.edu',
      'phone': '0311-1234560',
      'semesterNumber': 6,
      'section': 'C',
      'enrollmentDate': '2019-09-01',
      'faceEnrolled': false,
    },
    // ── Semester 7 ─────────────────────────────────────────────────────────
    {
      'id': 'stu-012',
      'fullName': 'Sana Butt',
      'rollNo': 'BSCS-F15-001',
      'email': 'sana.butt@student.edu',
      'phone': '0312-2345671',
      'semesterNumber': 7,
      'section': 'A',
      'enrollmentDate': '2018-09-01',
      'faceEnrolled': true,
    },
    {
      'id': 'stu-013',
      'fullName': 'Tariq Javed',
      'rollNo': 'BSCS-F15-002',
      'email': 'tariq.javed@student.edu',
      'phone': '0313-3456782',
      'semesterNumber': 7,
      'section': 'B',
      'enrollmentDate': '2018-09-01',
      'faceEnrolled': false,
    },
    // ── Semester 8 ─────────────────────────────────────────────────────────
    {
      'id': 'stu-014',
      'fullName': 'Nadia Pervaiz',
      'rollNo': 'BSCS-F14-001',
      'email': 'nadia.pervaiz@student.edu',
      'phone': '0314-4567893',
      'semesterNumber': 8,
      'section': 'A',
      'enrollmentDate': '2017-09-01',
      'faceEnrolled': true,
    },
    {
      'id': 'stu-015',
      'fullName': 'Faisal Raza',
      'rollNo': 'BSCS-F14-002',
      'email': 'faisal.raza@student.edu',
      'phone': '0315-5678904',
      'semesterNumber': 8,
      'section': 'C',
      'enrollmentDate': '2017-09-01',
      'faceEnrolled': true,
    },
  ];

  /// In-memory list — all CRUD operations mutate this list.
  static List<Map<String, dynamic>> get students => List.from(_students);

  static final _data = _students; // mutable reference

  /// Update a specific student's fields.
  static void updateStudent(String id, Map<String, dynamic> fields) {
    final idx = _data.indexWhere((s) => s['id'] == id);
    if (idx != -1) _data[idx] = {..._data[idx], ...fields};
  }

  /// Delete a student by id.
  static void deleteStudent(String id) =>
      _data.removeWhere((s) => s['id'] == id);

  /// Bulk delete students by ids.
  static void bulkDelete(List<String> ids) =>
      _data.removeWhere((s) => ids.contains(s['id']));

  /// Promote students to the next semester (max 8).
  static void promoteStudents(List<String> ids) {
    for (final id in ids) {
      final idx = _data.indexWhere((s) => s['id'] == id);
      if (idx != -1) {
        final current = _data[idx]['semesterNumber'] as int;
        if (current < 8) {
          _data[idx] = {..._data[idx], 'semesterNumber': current + 1};
        }
      }
    }
  }

  /// Helper — initials from full name.
  static String initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Avatar colour per student id (deterministic).
  static Color avatarColor(String id) {
    final colors = [
      const Color(0xFF6366F1), // indigo
      const Color(0xFF8B5CF6), // violet
      const Color(0xFFEC4899), // pink
      const Color(0xFF14B8A6), // teal
      const Color(0xFFF97316), // orange
      const Color(0xFF22C55E), // green
      const Color(0xFFEF4444), // red
      const Color(0xFF3B82F6), // blue
    ];
    final hash = id.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }
}
