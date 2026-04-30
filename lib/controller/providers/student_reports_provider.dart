import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:flutter/foundation.dart';

/// Student portal report APIs: attendance history, subjects, session detail.
class StudentReportsProvider extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  bool _loadingBootstrap = false;
  bool _loadingHistory = false;
  String? _errorMessage;

  StudentMonthPickerBounds? _bounds;
  List<StudentCourseSummary> _enrolledCourses = [];
  List<({int year, int month, String label})> _selectableMonths = [];

  int? _selectedYear;
  int? _selectedMonth;
  String? _selectedCourseId;

  StudentAttendanceHistoryResponse? _history;

  bool get loadingBootstrap => _loadingBootstrap;
  bool get loadingHistory => _loadingHistory;
  String? get errorMessage => _errorMessage;
  StudentMonthPickerBounds? get bounds => _bounds;
  List<StudentCourseSummary> get enrolledCourses =>
      List.unmodifiable(_enrolledCourses);
  List<({int year, int month, String label})> get selectableMonths =>
      List.unmodifiable(_selectableMonths);
  int? get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;
  String? get selectedCourseId => _selectedCourseId;
  StudentAttendanceHistoryResponse? get history => _history;

  bool get canLoadHistory =>
      _bounds != null &&
      _bounds!.hasEnrolledCourses &&
      _bounds!.monthPickerStart != null &&
      _bounds!.monthPickerEnd != null &&
      _selectedYear != null &&
      _selectedMonth != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Loads month bounds + enrolled subjects (for history chips). Call from history screen.
  Future<void> loadBootstrap() async {
    _loadingBootstrap = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _bounds = await _api.getStudentHistoryMonthBounds();
      final subjects = await _api.getStudentSubjectsReport();
      _enrolledCourses = subjects.courses;
      _selectableMonths = monthRangeInclusive(
        _bounds!.monthPickerStart,
        _bounds!.monthPickerEnd,
      );

      if (_selectableMonths.isEmpty) {
        _selectedYear = null;
        _selectedMonth = null;
      } else {
        final now = currentYearMonthPkt();
        ({int year, int month, String label})? pick;
        for (final e in _selectableMonths) {
          if (e.year == now.year && e.month == now.month) {
            pick = e;
            break;
          }
        }
        pick ??= _selectableMonths.last;
        _selectedYear = pick.year;
        _selectedMonth = pick.month;
      }
      _selectedCourseId = null;
      _history = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loadingBootstrap = false;
      notifyListeners();
    }
  }

  void selectCourseFilter(String? courseId) {
    _selectedCourseId = courseId;
    notifyListeners();
  }

  void selectMonth(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    notifyListeners();
  }

  String? selectedMonthLabel() {
    if (_selectedYear == null || _selectedMonth == null) return null;
    for (final e in _selectableMonths) {
      if (e.year == _selectedYear && e.month == _selectedMonth) return e.label;
    }
    return null;
  }

  Future<void> loadHistory() async {
    if (!canLoadHistory) {
      _history = null;
      notifyListeners();
      return;
    }
    _loadingHistory = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _history = await _api.getStudentAttendanceHistory(
        year: _selectedYear!,
        month: _selectedMonth!,
        courseId: _selectedCourseId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _history = null;
    } finally {
      _loadingHistory = false;
      notifyListeners();
    }
  }

  Future<StudentAttendanceSessionRecord?> fetchSessionDetail(
      String sessionId) async {
    try {
      return await _api.getStudentSessionDetail(sessionId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<StudentSubjectsResponse?> fetchSubjectsReport() async {
    try {
      return await _api.getStudentSubjectsReport();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<StudentSubjectDetailResponse?> fetchSubjectDetail(
      String courseId) async {
    try {
      return await _api.getStudentSubjectDetail(courseId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
