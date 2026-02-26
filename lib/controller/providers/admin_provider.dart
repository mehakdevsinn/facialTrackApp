import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:flutter/foundation.dart';

/// Manages all admin-specific state.
///
/// Each feature area has its own isolated loading/error fields so that
/// a teacher-list error never bleeds into the semester screen and vice-versa.
class AdminProvider extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  // ── General loading (create/update operations) ────────────────────────────
  bool _isLoading = false;
  String? _errorMessage; // used by create/update (teachers & semesters)

  // ── Teacher management ────────────────────────────────────────────────────
  List<UserModel> _teachers = [];
  bool _isTeachersLoading = false;
  String? _teachersError;

  // ── Semester management ───────────────────────────────────────────────────
  List<SemesterModel> _semesters = [];
  bool _isSemestersLoading = false;
  bool _semestersLoaded = false;
  String? _semestersError; // isolated from teacher errors

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Teachers
  List<UserModel> get teachers => List.unmodifiable(_teachers);
  bool get isTeachersLoading => _isTeachersLoading;
  String? get teachersError => _teachersError;

  // Semesters
  List<SemesterModel> get semesters => List.unmodifiable(_semesters);
  bool get isSemestersLoading => _isSemestersLoading;
  bool get semestersLoaded => _semestersLoaded;
  String? get semestersError => _semestersError;

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Teacher Methods ────────────────────────────────────────────────────────

  /// Fetches all teachers from the API.
  Future<void> fetchTeachers() async {
    _isTeachersLoading = true;
    _teachersError = null;
    notifyListeners();
    try {
      _teachers = await _api.getAllTeachers();
      _isTeachersLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      _teachersError = e.message;
      _isTeachersLoading = false;
      notifyListeners();
    } catch (_) {
      _teachersError = 'An unexpected error occurred.';
      _isTeachersLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new teacher account and prepends it to the list on success.
  Future<bool> createTeacher({
    required String email,
    required String fullName,
    String? phoneNumber,
    String? designation,
    String? qualification,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newTeacher = await _api.createTeacher(
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        designation: designation,
        qualification: qualification,
      );
      _teachers = [newTeacher, ..._teachers];
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Updates an existing teacher's details and refreshes the list entry.
  Future<bool> updateTeacher({
    required String teacherId,
    String? fullName,
    String? phoneNumber,
    String? designation,
    String? qualification,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _api.updateTeacher(
        teacherId: teacherId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        designation: designation,
        qualification: qualification,
      );
      _teachers =
          _teachers.map((t) => t.id == teacherId ? updated : t).toList();
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  // ── Semester Methods ───────────────────────────────────────────────────────

  /// Fetches all semesters from GET /api/v1/admin/semesters.
  /// Pass [force] = true to bypass the one-time cache.
  Future<void> fetchSemesters({bool force = false}) async {
    if (_semestersLoaded && !force) return; // already cached

    _isSemestersLoading = true;
    _semestersError = null;
    notifyListeners();

    try {
      debugPrint('== AdminProvider: calling getSemesters()');
      _semesters = await _api.getSemesters();
      debugPrint('== AdminProvider: got ${_semesters.length} semesters');
      _semestersLoaded = true;
      _isSemestersLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      debugPrint('== AdminProvider: getSemesters AuthException: ${e.message}');
      _semestersError = e.message;
      _isSemestersLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('== AdminProvider: getSemesters error: $e');
      _semestersError = 'An unexpected error occurred.';
      _isSemestersLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new semester via POST /api/v1/admin/semesters.
  /// Returns true on success and prepends the result to [semesters].
  Future<bool> createSemester({
    required int semesterNumber,
    required String academicSession,
    required String termType,
    required String operationalStatus,
    required String startDate,
    required String endDate,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final created = await _api.createSemester(
        semesterNumber: semesterNumber,
        academicSession: academicSession,
        termType: termType,
        operationalStatus: operationalStatus,
        startDate: startDate,
        endDate: endDate,
      );
      // Prepend so newest appears first (matches API ordering)
      _semesters = [created, ..._semesters];
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  /// Updates an existing semester via PUT /api/v1/admin/semesters/{id}.
  /// Returns true on success and replaces the entry in the cached list.
  Future<bool> updateSemester({
    required String semesterId,
    int? semesterNumber,
    String? academicSession,
    String? termType,
    String? operationalStatus,
    String? startDate,
    String? endDate,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _api.updateSemester(
        semesterId: semesterId,
        semesterNumber: semesterNumber,
        academicSession: academicSession,
        termType: termType,
        operationalStatus: operationalStatus,
        startDate: startDate,
        endDate: endDate,
      );
      // Replace the stale entry in the cached list
      _semesters =
          _semesters.map((s) => s.id == semesterId ? updated : s).toList();
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  // ── Reset ──────────────────────────────────────────────────────────────────

  /// Call on logout to wipe all cached data.
  void clear() {
    _teachers = [];
    _semesters = [];
    _semestersLoaded = false;
    _errorMessage = null;
    _teachersError = null;
    _semestersError = null;
    _isLoading = false;
    _isTeachersLoading = false;
    _isSemestersLoading = false;
    notifyListeners();
  }
}
