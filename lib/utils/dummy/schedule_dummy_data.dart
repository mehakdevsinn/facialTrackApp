import 'package:facialtrackapp/core/models/timetable_model.dart';
import 'package:flutter/material.dart';

/// Static dummy schedule data.
/// All CRUD operations mutate the in-memory list — real API hooks later.
class ScheduleDummyData {
  ScheduleDummyData._();

  // ── Course catalogue (per semester) ───────────────────────────────────────
  /// Returns courses available for the given semester number.
  static List<Map<String, dynamic>> coursesForSemester(int semesterNumber) {
    const courseMap = {
      1: [
        {'code': 'CS-101', 'title': 'Programming Fundamentals'},
        {'code': 'CS-103', 'title': 'Discrete Mathematics'},
        {'code': 'ENG-101', 'title': 'English Composition'},
        {'code': 'MTH-101', 'title': 'Calculus I'},
      ],
      2: [
        {'code': 'CS-201', 'title': 'Object Oriented Programming'},
        {'code': 'CS-203', 'title': 'Data Structures'},
        {'code': 'MTH-201', 'title': 'Calculus II'},
        {'code': 'ENG-201', 'title': 'Communication Skills'},
      ],
      3: [
        {'code': 'CS-301', 'title': 'Algorithms Analysis'},
        {'code': 'CS-303', 'title': 'Database Systems'},
        {'code': 'CS-305', 'title': 'Computer Networks'},
        {'code': 'MTH-301', 'title': 'Linear Algebra'},
      ],
      6: [
        {'code': 'CS-351', 'title': 'Theory of Automata'},
        {'code': 'CS-303', 'title': 'Object Oriented Analysis & Design'},
        {'code': 'CS-452', 'title': 'Digital Image Processing'},
        {'code': 'CS-355', 'title': 'Web Technologies'},
        {'code': 'CS-404', 'title': 'Human Computer Interaction'},
        {'code': 'STAT-379', 'title': 'Probability & Statistics (Allied)'},
      ],
      8: [
        {'code': 'CS-423', 'title': 'Parallel & Distributed Computing'},
        {'code': 'CS-424', 'title': 'Information Security'},
        {'code': 'CS-425', 'title': 'Final Year Project II'},
        {'code': 'MG-402', 'title': 'Human Resource Management'},
        {'code': 'SS-406', 'title': 'Foreign Language (Arabic)'},
      ],
    };
    final list = List<Map<String, dynamic>>.from(courseMap[semesterNumber] ??
        [
          {'code': 'CS-000', 'title': 'General Course'}
        ]);
    list.sort((a, b) => a['code']!.compareTo(b['code']!));
    return list;
  }

  // ── Teacher catalogue (per course code) ───────────────────────────────────
  static List<String> teachersForCourse(String courseCode) {
    const teacherMap = {
      'CS-351': ['Dr. Aliza Qasim'],
      'CS-303': ['Dr. Aliza Qasim', 'Asst. Rehan Siddiqui'],
      'CS-452': ['Hafsa Hafeez', 'CTI Faculty'],
      'CS-355': ['Anila Majeed'],
      'CS-404': ['Fizza Jahangir'],
      'STAT-379': ['Najaf Naz'],
      'CS-423': ['Arqsa Aslam'],
      'CS-424': ['Dr. Qurat ul Ain'],
      'CS-425': ['Entire Department'],
      'MG-402': ['Hafiza Saba'],
      'SS-406': ['Bushra Parveen'],
      'CS-101': ['Dr. Imran Ali'],
      'CS-103': ['Asst. Sara Malik'],
      'ENG-101': ['Ms. Rabia Khan'],
      'MTH-101': ['Dr. Nasir Ahmed'],
      'CS-201': ['Dr. Imran Ali', 'Ms. Ayesha Naz'],
      'CS-203': ['Arqsa Aslam'],
      'MTH-201': ['Dr. Nasir Ahmed'],
      'ENG-201': ['Ms. Rabia Khan'],
      'CS-301': ['Dr. Qurat ul Ain'],
      'CS-305': ['Hafsa Hafeez'],
      'MTH-301': ['Dr. Nasir Ahmed'],
    };
    return teacherMap[courseCode] ?? ['TBA'];
  }

  // ── Pre-built period configs ───────────────────────────────────────────────
  static List<PeriodSlot> _standardPeriods() => [
        PeriodSlot(
          id: 'p1',
          isBreak: false,
          label: 'Period 1',
          startTime: const TimeOfDay(hour: 8, minute: 0),
          endTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        PeriodSlot(
          id: 'p2',
          isBreak: false,
          label: 'Period 2',
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
        ),
        PeriodSlot(
          id: 'p3',
          isBreak: false,
          label: 'Period 3',
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 0),
        ),
        PeriodSlot(
          id: 'brk',
          isBreak: true,
          label: 'Break',
          startTime: const TimeOfDay(hour: 11, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 20),
        ),
        PeriodSlot(
          id: 'p4',
          isBreak: false,
          label: 'Period 4',
          startTime: const TimeOfDay(hour: 11, minute: 20),
          endTime: const TimeOfDay(hour: 12, minute: 20),
        ),
        PeriodSlot(
          id: 'p5',
          isBreak: false,
          label: 'Period 5',
          startTime: const TimeOfDay(hour: 12, minute: 20),
          endTime: const TimeOfDay(hour: 13, minute: 20),
        ),
        PeriodSlot(
          id: 'p6',
          isBreak: false,
          label: 'Period 6',
          startTime: const TimeOfDay(hour: 13, minute: 20),
          endTime: const TimeOfDay(hour: 14, minute: 20),
        ),
      ];

  // ── Pre-built timetables ───────────────────────────────────────────────────
  static final List<Timetable> _timetables = [
    // Semester 6, Section A
    Timetable(
      id: 'tt-001',
      semesterNumber: 6,
      semesterId: 'sem-6',
      academicSession: '2023-27',
      section: 'A',
      periods: _standardPeriods(),
      entries: [
        const TimetableEntry(
            day: 'Mon',
            periodId: 'p1',
            courseCode: 'CS-351',
            courseTitle: 'Theory of Automata',
            teacherName: 'Dr. Aliza Qasim'),
        const TimetableEntry(
            day: 'Mon',
            periodId: 'p2',
            courseCode: 'CS-303',
            courseTitle: 'OO Analysis & Design',
            teacherName: 'Dr. Aliza Qasim'),
        const TimetableEntry(
            day: 'Mon',
            periodId: 'p4',
            courseCode: 'CS-404',
            courseTitle: 'Human Computer Interaction',
            teacherName: 'Fizza Jahangir'),
        const TimetableEntry(
            day: 'Mon',
            periodId: 'p5',
            courseCode: 'CS-452',
            courseTitle: 'Digital Image Processing',
            teacherName: 'Hafsa Hafeez'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p1',
            courseCode: 'CS-351',
            courseTitle: 'Theory of Automata',
            teacherName: 'Dr. Aliza Qasim'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p2',
            courseCode: 'CS-303',
            courseTitle: 'OO Analysis & Design',
            teacherName: 'Dr. Aliza Qasim'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p4',
            courseCode: 'CS-355',
            courseTitle: 'Web Technologies',
            teacherName: 'Anila Majeed'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p5',
            courseCode: 'CS-452',
            courseTitle: 'Digital Image Processing',
            teacherName: 'Hafsa Hafeez'),
        const TimetableEntry(
            day: 'Wed',
            periodId: 'p1',
            courseCode: 'CS-351',
            courseTitle: 'Theory of Automata',
            teacherName: 'Dr. Aliza Qasim'),
        const TimetableEntry(
            day: 'Wed',
            periodId: 'p2',
            courseCode: 'CS-303',
            courseTitle: 'OO Analysis & Design',
            teacherName: 'Dr. Aliza Qasim'),
        const TimetableEntry(
            day: 'Wed',
            periodId: 'p4',
            courseCode: 'STAT-379',
            courseTitle: 'Probability & Statistics',
            teacherName: 'Najaf Naz'),
        const TimetableEntry(
            day: 'Wed',
            periodId: 'p5',
            courseCode: 'CS-452',
            courseTitle: 'Digital Image Processing',
            teacherName: 'Hafsa Hafeez'),
        const TimetableEntry(
            day: 'Thu',
            periodId: 'p1',
            courseCode: 'CS-404',
            courseTitle: 'Human Computer Interaction',
            teacherName: 'Fizza Jahangir'),
        const TimetableEntry(
            day: 'Thu',
            periodId: 'p2',
            courseCode: 'CS-355',
            courseTitle: 'Web Technologies',
            teacherName: 'Anila Majeed'),
        const TimetableEntry(
            day: 'Thu',
            periodId: 'p4',
            courseCode: 'STAT-379',
            courseTitle: 'Probability & Statistics',
            teacherName: 'Najaf Naz'),
        const TimetableEntry(
            day: 'Fri',
            periodId: 'p1',
            courseCode: 'CS-404',
            courseTitle: 'Human Computer Interaction',
            teacherName: 'Fizza Jahangir'),
        const TimetableEntry(
            day: 'Fri',
            periodId: 'p2',
            courseCode: 'CS-355',
            courseTitle: 'Web Technologies',
            teacherName: 'Anila Majeed'),
        const TimetableEntry(
            day: 'Fri',
            periodId: 'p4',
            courseCode: 'STAT-379',
            courseTitle: 'Probability & Statistics',
            teacherName: 'Najaf Naz'),
      ],
    ),

    // Semester 8, Section A  (e-Lab)
    Timetable(
      id: 'tt-002',
      semesterNumber: 8,
      semesterId: 'sem-8',
      academicSession: '2021-25',
      section: 'A',
      periods: _standardPeriods(),
      entries: [
        const TimetableEntry(
            day: 'Mon',
            periodId: 'p2',
            courseCode: 'CS-424',
            courseTitle: 'Information Security',
            teacherName: 'Dr. Qurat ul Ain'),
        const TimetableEntry(
            day: 'Mon',
            periodId: 'p3',
            courseCode: 'CS-423',
            courseTitle: 'Parallel & Distributed Computing',
            teacherName: 'Arqsa Aslam'),
        const TimetableEntry(
            day: 'Mon',
            periodId: 'p4',
            courseCode: 'SS-406',
            courseTitle: 'Foreign Language (Arabic)',
            teacherName: 'Bushra Parveen'),
        const TimetableEntry(
            day: 'Mon',
            periodId: 'p5',
            courseCode: 'CS-425',
            courseTitle: 'Final Year Project II',
            teacherName: 'Entire Department'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p1',
            courseCode: 'MG-402',
            courseTitle: 'Human Resource Management',
            teacherName: 'Hafiza Saba'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p2',
            courseCode: 'CS-424',
            courseTitle: 'Information Security',
            teacherName: 'Dr. Qurat ul Ain'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p3',
            courseCode: 'CS-423',
            courseTitle: 'Parallel & Distributed Computing',
            teacherName: 'Arqsa Aslam'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p4',
            courseCode: 'SS-406',
            courseTitle: 'Foreign Language (Arabic)',
            teacherName: 'Bushra Parveen'),
        const TimetableEntry(
            day: 'Tue',
            periodId: 'p5',
            courseCode: 'CS-425',
            courseTitle: 'Final Year Project II',
            teacherName: 'Entire Department'),
        const TimetableEntry(
            day: 'Wed',
            periodId: 'p2',
            courseCode: 'CS-424',
            courseTitle: 'Information Security',
            teacherName: 'Dr. Qurat ul Ain'),
        const TimetableEntry(
            day: 'Wed',
            periodId: 'p3',
            courseCode: 'CS-423',
            courseTitle: 'Parallel & Distributed Computing',
            teacherName: 'Arqsa Aslam'),
        const TimetableEntry(
            day: 'Wed',
            periodId: 'p4',
            courseCode: 'CS-425',
            courseTitle: 'Final Year Project II',
            teacherName: 'Entire Department'),
        const TimetableEntry(
            day: 'Wed',
            periodId: 'p5',
            courseCode: 'CS-425',
            courseTitle: 'Final Year Project II',
            teacherName: 'Entire Department'),
        const TimetableEntry(
            day: 'Thu',
            periodId: 'p2',
            courseCode: 'MG-402',
            courseTitle: 'Human Resource Management',
            teacherName: 'Hafiza Saba'),
        const TimetableEntry(
            day: 'Thu',
            periodId: 'p4',
            courseCode: 'CS-425',
            courseTitle: 'Final Year Project II',
            teacherName: 'Entire Department'),
        const TimetableEntry(
            day: 'Fri',
            periodId: 'p2',
            courseCode: 'MG-402',
            courseTitle: 'Human Resource Management',
            teacherName: 'Hafiza Saba'),
        const TimetableEntry(
            day: 'Fri',
            periodId: 'p4',
            courseCode: 'CS-425',
            courseTitle: 'Final Year Project II',
            teacherName: 'Entire Department'),
      ],
    ),
  ];

  // ── Public API ─────────────────────────────────────────────────────────────
  static List<Timetable> get all => List.from(_timetables);

  static Timetable? findById(String id) {
    try {
      return _timetables.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  static void addTimetable(Timetable t) => _timetables.add(t);

  static void deleteTimetable(String id) =>
      _timetables.removeWhere((t) => t.id == id);

  static void updateEntry(
      String timetableId, String day, String periodId, TimetableEntry? entry) {
    final idx = _timetables.indexWhere((t) => t.id == timetableId);
    if (idx == -1) return;
    final tt = _timetables[idx];
    final newEntries = tt.entries
        .where((e) => !(e.day == day && e.periodId == periodId))
        .toList();
    if (entry != null) newEntries.add(entry);
    _timetables[idx] = tt.copyWith(entries: newEntries);
  }

  static void clearEntry(String timetableId, String day, String periodId) =>
      updateEntry(timetableId, day, periodId, null);

  static void updatePeriods(String timetableId, List<PeriodSlot> periods) {
    final idx = _timetables.indexWhere((t) => t.id == timetableId);
    if (idx == -1) return;
    _timetables[idx] = _timetables[idx].copyWith(periods: periods);
  }

  /// Simple unique ID generator for new timetables.
  static String generateId() => 'tt-${DateTime.now().millisecondsSinceEpoch}';

  /// Check if a teacher is already booked at the same [day] + [periodId]
  /// in another entry (excluding the one being set).
  static bool hasConflict({
    required String timetableId,
    required String day,
    required String periodId,
    required String teacherName,
  }) {
    final tt = _timetables.firstWhere((t) => t.id == timetableId,
        orElse: () => Timetable(
            id: '',
            semesterNumber: 0,
            semesterId: '',
            academicSession: '',
            section: '',
            periods: [],
            entries: []));
    return tt.entries.any((e) =>
        e.day == day &&
        e.periodId == periodId &&
        e.teacherName == teacherName &&
        e.periodId != periodId);
  }
}
