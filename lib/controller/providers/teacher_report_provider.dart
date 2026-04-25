import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/report_models.dart';
import 'package:facialtrackapp/core/models/teacher_course_model.dart';
import 'package:facialtrackapp/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class TeacherReportProvider extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  bool _isLoadingCourses = false;
  bool _isGenerating = false;
  String? _errorMessage;
  int _attendanceThreshold = 75;

  List<TeacherCourseModel> _courses = [];
  String? _selectedSemesterId;
  String? _selectedCourseId;

  CourseReportResponse? _courseReport;
  MonthlyReportResponse? _monthlyReport;
  DailyReportResponse? _dailyReport;
  List<LowAttendanceStudent> _lowAttendance = [];

  bool get isLoadingCourses => _isLoadingCourses;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  List<TeacherCourseModel> get courses => _courses;
  String? get selectedSemesterId => _selectedSemesterId;
  String? get selectedCourseId => _selectedCourseId;
  CourseReportResponse? get courseReport => _courseReport;
  MonthlyReportResponse? get monthlyReport => _monthlyReport;
  DailyReportResponse? get dailyReport => _dailyReport;
  List<LowAttendanceStudent> get lowAttendance => _lowAttendance;
  int get attendanceThreshold => _attendanceThreshold;

  List<SemesterOption> get semesterOptions {
    final map = <String, SemesterOption>{};
    for (final c in _courses) {
      final sem = c.semester;
      if (sem == null) continue;
      map[sem.id] = SemesterOption(
        id: sem.id,
        label: sem.displayName,
      );
    }
    final list = map.values.toList();
    list.sort((a, b) => a.label.compareTo(b.label));
    return list;
  }

  List<TeacherCourseModel> get filteredCourses {
    if (_selectedSemesterId == null) return [];
    return _courses.where((c) => c.semesterId == _selectedSemesterId).toList();
  }

  TeacherCourseModel? get selectedCourse {
    if (_selectedCourseId == null) return null;
    try {
      return _courses.firstWhere((c) => c.id == _selectedCourseId);
    } catch (_) {
      return null;
    }
  }

  void setSelectedSemester(String? semesterId) {
    _selectedSemesterId = semesterId;
    _selectedCourseId = null;
    notifyListeners();
  }

  void setSelectedCourse(String? courseId) {
    _selectedCourseId = courseId;
    notifyListeners();
  }

  void _syncSelectionsAfterCourseLoad() {
    if (_courses.isEmpty) {
      _selectedSemesterId = null;
      _selectedCourseId = null;
      return;
    }
    final semesterIds =
        _courses.map((c) => c.semesterId).where((id) => id.isNotEmpty).toSet();
    if (_selectedSemesterId == null ||
        !semesterIds.contains(_selectedSemesterId)) {
      _selectedSemesterId = _courses.first.semesterId;
      _selectedCourseId = null;
      return;
    }
    final courseIdsInSemester = _courses
        .where((c) => c.semesterId == _selectedSemesterId)
        .map((c) => c.id)
        .toSet();
    if (_selectedCourseId != null &&
        !courseIdsInSemester.contains(_selectedCourseId)) {
      _selectedCourseId = null;
    }
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadCourses({bool force = false}) async {
    if (_courses.isNotEmpty && !force) return;
    _isLoadingCourses = true;
    _setError(null);
    try {
      final teacherId = await StorageService.getUserId();
      if (teacherId == null) throw Exception('Not logged in');
      _courses = await _api.getTeacherCourses(teacherId);
      await _loadAttendanceThreshold();
      _syncSelectionsAfterCourseLoad();
      _isLoadingCourses = false;
      notifyListeners();
    } on AuthException catch (e) {
      _isLoadingCourses = false;
      _setError(e.message);
    } catch (_) {
      _isLoadingCourses = false;
      _setError('Failed to load courses.');
    }
  }

  Future<void> _loadAttendanceThreshold() async {
    try {
      final criteria = await _api.getAttendanceCriteria();
      _attendanceThreshold = criteria.attendanceThresholdPercent;
    } catch (_) {
      // Keep default threshold (75) if this setting endpoint is unavailable.
    }
  }

  Future<bool> generateDateRangeReport({
    String? startDate,
    String? endDate,
  }) async {
    if (_selectedCourseId == null) {
      _setError('Please select a course first.');
      return false;
    }
    _isGenerating = true;
    _setError(null);
    notifyListeners();
    try {
      _courseReport = await _api.getCourseReport(
        _selectedCourseId!,
        startDate: startDate,
        endDate: endDate,
      );
      _isGenerating = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isGenerating = false;
      _setError(e.message);
      return false;
    } catch (_) {
      _isGenerating = false;
      _setError('Failed to generate date range report.');
      return false;
    }
  }

  Future<bool> generateSemesterReport() async {
    return generateDateRangeReport();
  }

  Future<bool> generateMonthlyReport({
    required int year,
    required int month,
  }) async {
    if (_selectedCourseId == null) {
      _setError('Please select a course first.');
      return false;
    }
    _isGenerating = true;
    _setError(null);
    notifyListeners();
    try {
      _monthlyReport = await _api.getMonthlyReport(
        _selectedCourseId!,
        year: year,
        month: month,
      );
      _isGenerating = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isGenerating = false;
      _setError(e.message);
      return false;
    } catch (_) {
      _isGenerating = false;
      _setError('Failed to generate monthly report.');
      return false;
    }
  }

  Future<bool> generateDailyReport({required String reportDate}) async {
    if (_selectedCourseId == null) {
      _setError('Please select a course first.');
      return false;
    }
    _isGenerating = true;
    _setError(null);
    notifyListeners();
    try {
      _dailyReport = await _api.getDailyReport(
        _selectedCourseId!,
        reportDate: reportDate,
      );
      _isGenerating = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isGenerating = false;
      _setError(e.message);
      return false;
    } catch (_) {
      _isGenerating = false;
      _setError('Failed to generate daily report.');
      return false;
    }
  }

  Future<bool> loadLowAttendance({double? threshold}) async {
    if (_selectedCourseId == null) {
      _setError('Please select a course first.');
      return false;
    }
    try {
      _lowAttendance = await _api.getLowAttendanceAlerts(
        courseId: _selectedCourseId!,
        threshold: threshold,
      );
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Failed to load low attendance alerts.');
      return false;
    }
  }
}

class SemesterOption {
  final String id;
  final String label;
  const SemesterOption({required this.id, required this.label});
}
