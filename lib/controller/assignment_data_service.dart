import 'package:flutter/material.dart';

class AssignmentDataService extends ChangeNotifier {
  // Static storage that lives as long as the app is running
  static List<Map<String, dynamic>> allAssignments = [
    {
      "teacherName": "Dr. Sarah Ahmed",
      "teacherDesignation": "Associate Professor",
      "initials": "SA",
      "subjects": <Map<String, dynamic>>[
        {
          "course": "Introduction to Computing",
          "semester": "2nd Sem",
          "section": "Section A",
          "code": "CS-101",
          "credits": "3",
        },
        {
          "course": "Programming Fundamentals",
          "semester": "2nd Sem",
          "section": "Section B",
          "code": "CS-102",
          "credits": "4",
        },
      ],
    },
    {
      "teacherName": "Prof. Usman Khan",
      "teacherDesignation": "Head of Department",
      "initials": "UK",
      "subjects": <Map<String, dynamic>>[
        {
          "course": "Operating Systems",
          "semester": "4th Sem",
          "section": "Section A",
          "code": "CS-301",
          "credits": "4",
        },
      ],
    },
  ];

  static final List<Map<String, dynamic>> availableTeachers = [
    {
      "name": "Dr. Sarah Ahmed",
      "designation": "Associate Professor",
      "initials": "SA",
    },
    {
      "name": "Prof. Usman Khan",
      "designation": "Head of Department",
      "initials": "UK",
    },
    {"name": "Engr. Maria Ali", "designation": "Lecturer", "initials": "MA"},
    {
      "name": "Dr. Ahmed Hassan",
      "designation": "Assistant Professor",
      "initials": "AH",
    },
    {"name": "Ms. Zainab Bibi", "designation": "Instructor", "initials": "ZB"},
  ];

  static final AssignmentDataService instance = AssignmentDataService();

  // The Master Update Method
  static void updateAssignment(
    Map<String, dynamic> newData, {
    String? originalTeacherName,
  }) {
    // 1. If teacher was changed
    if (originalTeacherName != null &&
        originalTeacherName != newData['teacherName']) {
      allAssignments.removeWhere(
        (a) => a['teacherName'] == originalTeacherName,
      );

      final targetIdx = allAssignments.indexWhere(
        (a) => a['teacherName'] == newData['teacherName'],
      );
      if (targetIdx != -1) {
        // MERGE logic
        final List subjects = allAssignments[targetIdx]['subjects'];
        for (var sub in newData['subjects']) {
          if (!subjects.any((s) => s['code'] == sub['code'])) {
            subjects.add(Map<String, dynamic>.from(sub));
          }
        }
      } else {
        allAssignments.add(newData);
      }
    } else {
      // 2. Standard Update / Add to existing
      final existingIdx = allAssignments.indexWhere(
        (a) => a['teacherName'] == newData['teacherName'],
      );
      if (existingIdx != -1) {
        // MERGE logic to prevent overwriting
        final List subjects = allAssignments[existingIdx]['subjects'];
        for (var sub in newData['subjects']) {
          if (!subjects.any((s) => s['code'] == sub['code'])) {
            subjects.add(Map<String, dynamic>.from(sub));
          }
        }
        // Update other info but keep existing subjects
        allAssignments[existingIdx]['teacherDesignation'] =
            newData['teacherDesignation'];
        allAssignments[existingIdx]['initials'] = newData['initials'];
      } else {
        allAssignments.add(Map<String, dynamic>.from(newData));
      }
    }

    instance.notifyListeners();
  }

  static void addSubjectToTeacher(
    String teacherName,
    Map<String, dynamic> subject,
  ) {
    final existingIdx = allAssignments.indexWhere(
      (a) => a['teacherName'] == teacherName,
    );
    if (existingIdx != -1) {
      final List subjects = allAssignments[existingIdx]['subjects'];
      if (!subjects.any((s) => s['code'] == subject['code'])) {
        subjects.add(Map<String, dynamic>.from(subject));
      }
    } else {
      allAssignments.add({
        "teacherName": teacherName,
        "teacherDesignation": teacherName.contains("Dr.")
            ? "Professor"
            : "Lecturer",
        "initials": teacherName
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join('')
            .toUpperCase(),
        "subjects": <Map<String, dynamic>>[Map<String, dynamic>.from(subject)],
      });
    }
    instance.notifyListeners();
  }
}
