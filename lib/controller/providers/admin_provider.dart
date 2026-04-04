import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/assignment_model.dart';
import 'package:facialtrackapp/core/models/course_model.dart';
import 'package:facialtrackapp/core/models/pending_student_model.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/student_model.dart';
import 'package:facialtrackapp/core/models/timetable_model.dart';
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

  // ── Course management ─────────────────────────────────────────────────────
  // Cache courses by semester: semesterId -> List<CourseModel>
  final Map<String, List<CourseModel>> _coursesBySemester = {};
  final Set<String> _loadingSemestersForCourses = {};
  final Map<String, String> _coursesErrorBySemester = {};

  // ── Assignment management ─────────────────────────────────────────────────
  List<AssignmentModel> _assignments = [];
  bool _isAssignmentsLoading = false;
  bool _assignmentsLoaded = false;
  String? _assignmentsError;

  // ── Student count (all enrolled) ────────────────────────────────────────────
  int _studentCount = 0;
  bool _isStudentCountLoading = false;

  // ── Student management (full list) ────────────────────────────────────────
  List<StudentModel> _students = [];
  bool _isStudentsLoading = false;
  String? _studentsError;
  bool _isStudentsActionLoading = false;

  // ── All courses count ───────────────────────────────────────────────────
  int _allCoursesCount = 0;
  bool _isAllCoursesCountLoading = false;

  // ── Student approval ───────────────────────────────────────────────────────
  List<PendingStudentModel> _pendingStudents = [];
  bool _isPendingStudentsLoading = false;
  bool _pendingStudentsLoaded = false;
  String? _pendingStudentsError;

  /// IDs of students currently being approved.
  final Set<String> _approvingStudentIds = {};

  /// IDs of students currently being rejected.
  final Set<String> _rejectingStudentIds = {};

  // ── Schedule management ──────────────────────────────────────────────
  List<Timetable> _timetables = [];
  bool _isTimetablesLoading = false;
  String? _timetablesError;
  bool _isScheduleActionLoading = false; // create/update/delete
  String? _scheduleActionError;
  // Cache: timetableKey(”semId:section”) → assignments loaded for that scope
  final Map<String, List<AssignmentModel>> _scheduleAssignments = {};

  // ── Enrollment deadline settings ──────────────────────────────────────────
  DateTime? _enrollmentDeadline;
  bool _isDeadlineLoading = false;
  bool _isDeadlineSaving = false;
  String? _deadlineError;

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

  // Courses
  List<CourseModel> getCoursesForSemester(String semesterId) =>
      _coursesBySemester[semesterId] ?? [];
  bool isCoursesLoading(String semesterId) =>
      _loadingSemestersForCourses.contains(semesterId);
  String? getCoursesError(String semesterId) =>
      _coursesErrorBySemester[semesterId];

  // Assignments
  List<AssignmentModel> get assignments => List.unmodifiable(_assignments);
  bool get isAssignmentsLoading => _isAssignmentsLoading;
  bool get assignmentsLoaded => _assignmentsLoaded;
  String? get assignmentsError => _assignmentsError;

  // Student count
  int get studentCount => _studentCount;
  bool get isStudentCountLoading => _isStudentCountLoading;

  // Student management
  List<StudentModel> get students => List.unmodifiable(_students);
  bool get isStudentsLoading => _isStudentsLoading;
  String? get studentsError => _studentsError;
  bool get isStudentsActionLoading => _isStudentsActionLoading;

  // All courses count
  int get allCoursesCount => _allCoursesCount;
  bool get isAllCoursesCountLoading => _isAllCoursesCountLoading;

  // Pending students
  List<PendingStudentModel> get pendingStudents =>
      List.unmodifiable(_pendingStudents);
  bool get isPendingStudentsLoading => _isPendingStudentsLoading;
  String? get pendingStudentsError => _pendingStudentsError;

  /// Returns true while the given student is being approved.
  bool isStudentApproving(String studentId) =>
      _approvingStudentIds.contains(studentId);

  /// Returns true while the given student is being rejected.
  bool isStudentRejecting(String studentId) =>
      _rejectingStudentIds.contains(studentId);

  /// Returns true while ANY action is in progress for the given student.
  bool isStudentProcessing(String studentId) =>
      isStudentApproving(studentId) || isStudentRejecting(studentId);

  // Enrollment deadline
  DateTime? get enrollmentDeadline => _enrollmentDeadline;
  bool get isDeadlineLoading => _isDeadlineLoading;
  bool get isDeadlineSaving => _isDeadlineSaving;
  String? get deadlineError => _deadlineError;

  // Schedule
  List<Timetable> get timetables => List.unmodifiable(_timetables);
  bool get isTimetablesLoading => _isTimetablesLoading;
  String? get timetablesError => _timetablesError;
  bool get isScheduleActionLoading => _isScheduleActionLoading;
  String? get scheduleActionError => _scheduleActionError;
  List<AssignmentModel> scheduleAssignments(String semesterId, String section) =>
      _scheduleAssignments['$semesterId:$section'] ?? [];

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

  /// Deletes a teacher and removes them from the local list.
  Future<bool> deleteTeacher(String teacherId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.deleteTeacher(teacherId);
      _teachers.removeWhere((t) => t.id == teacherId);
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

  // ── Course Methods ─────────────────────────────────────────────────────────

  Future<void> fetchCourses(String semesterId, {bool force = false}) async {
    if (_coursesBySemester.containsKey(semesterId) && !force) return;

    _loadingSemestersForCourses.add(semesterId);
    _coursesErrorBySemester.remove(semesterId);
    notifyListeners();

    try {
      final courses = await _api.getCoursesBySemester(semesterId);
      _coursesBySemester[semesterId] = courses;
      _loadingSemestersForCourses.remove(semesterId);
      notifyListeners();
    } on AuthException catch (e) {
      _coursesErrorBySemester[semesterId] = e.message;
      _loadingSemestersForCourses.remove(semesterId);
      notifyListeners();
    } catch (_) {
      _coursesErrorBySemester[semesterId] = 'An unexpected error occurred.';
      _loadingSemestersForCourses.remove(semesterId);
      notifyListeners();
    }
  }

  Future<bool> createCourse({
    required String code,
    required String name,
    required String semesterId,
    String description = '',
    int creditHours = 3,
    bool attendanceRequired = true,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final created = await _api.createCourse(
        code: code,
        name: name,
        semesterId: semesterId,
        description: description,
        creditHours: creditHours,
        attendanceRequired: attendanceRequired,
      );
      final list = _coursesBySemester[semesterId] ?? [];
      _coursesBySemester[semesterId] = [created, ...list];
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

  Future<bool> updateCourse({
    required String courseId,
    required String semesterId,
    String? name,
    int? creditHours,
    bool? attendanceRequired,
    bool? isActive,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _api.updateCourse(
        courseId: courseId,
        name: name,
        creditHours: creditHours,
        attendanceRequired: attendanceRequired,
        isActive: isActive,
      );

      final list = _coursesBySemester[semesterId] ?? [];
      _coursesBySemester[semesterId] =
          list.map((c) => c.id == courseId ? updated : c).toList();

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

  // ── Assignment Methods ─────────────────────────────────────────────────────

  Future<void> fetchAssignments({bool force = false}) async {
    if (_assignmentsLoaded && !force) return;
    _isAssignmentsLoading = true;
    _assignmentsError = null;
    notifyListeners();
    try {
      _assignments = await _api.getAssignments();
      _assignmentsLoaded = true;
      _isAssignmentsLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      _assignmentsError = e.message;
      _isAssignmentsLoading = false;
      notifyListeners();
    } catch (_) {
      _assignmentsError = 'An unexpected error occurred.';
      _isAssignmentsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssignment({
    required String courseId,
    required String teacherId,
    required String section,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final created = await _api.createAssignment(
        courseId: courseId,
        teacherId: teacherId,
        section: section,
      );
      _assignments = [created, ..._assignments];
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

  Future<bool> updateAssignment({
    required String assignmentId,
    String? teacherId,
    String? section,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _api.updateAssignment(
        assignmentId: assignmentId,
        teacherId: teacherId,
        section: section,
      );
      _assignments =
          _assignments.map((a) => a.id == assignmentId ? updated : a).toList();
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

  Future<bool> deleteAssignment(String assignmentId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.deleteAssignment(assignmentId);
      _assignments.removeWhere((a) => a.id == assignmentId);
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

  // ── Dashboard Summary Counts ────────────────────────────────────────────────

  Future<void> fetchStudentCount() async {
    _isStudentCountLoading = true;
    notifyListeners();
    try {
      final list = await _api.getAllStudents();
      _studentCount = list.length;
      _isStudentCountLoading = false;
      notifyListeners();
    } on AuthException {
      _isStudentCountLoading = false;
      notifyListeners();
    } catch (_) {
      _isStudentCountLoading = false;
      notifyListeners();
    }
  }

  // ── Student Management Methods ──────────────────────────────────────────

  /// Fetches all students. Pass [force]=true to bypass cache.
  Future<void> fetchStudents({bool force = false}) async {
    if (_students.isNotEmpty && !force) return;
    _isStudentsLoading = true;
    _studentsError = null;
    notifyListeners();
    try {
      _students = await _api.getAllStudents();
      _studentCount = _students.length;
      _isStudentsLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      _studentsError = e.message;
      _isStudentsLoading = false;
      notifyListeners();
    } catch (_) {
      _studentsError = 'Failed to load students. Please try again.';
      _isStudentsLoading = false;
      notifyListeners();
    }
  }

  /// Updates a student's editable fields. Returns updated [StudentModel] or null on failure.
  Future<StudentModel?> updateStudent(
    String studentId, {
    required String fullName,
    required String rollNo,
    required String email,
    required int semesterNumber,
    required String section,
  }) async {
    _isStudentsActionLoading = true;
    _setError(null);
    notifyListeners();
    try {
      final updated = await _api.updateStudent(
        studentId,
        fullName: fullName,
        rollNo: rollNo,
        email: email,
        semesterNumber: semesterNumber,
        section: section,
      );
      final idx = _students.indexWhere((s) => s.id == studentId);
      if (idx != -1) _students[idx] = updated;
      _isStudentsActionLoading = false;
      notifyListeners();
      return updated;
    } on AuthException catch (e) {
      _setError(e.message);
      _isStudentsActionLoading = false;
      notifyListeners();
      return null;
    } catch (_) {
      _setError('Failed to update student. Please try again.');
      _isStudentsActionLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Deletes a single student by ID.
  Future<bool> deleteStudent(String studentId) async {
    _isStudentsActionLoading = true;
    _setError(null);
    notifyListeners();
    try {
      await _api.deleteStudent(studentId);
      _students.removeWhere((s) => s.id == studentId);
      _studentCount = _students.length;
      _isStudentsActionLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _isStudentsActionLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _setError('Failed to delete student. Please try again.');
      _isStudentsActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Bulk promotes students to the next semester.
  /// Returns the response map (promoted_count, skipped_count) or null on failure.
  Future<Map<String, dynamic>?> bulkPromoteStudents(
      List<String> studentIds) async {
    _isStudentsActionLoading = true;
    _setError(null);
    notifyListeners();
    try {
      final result = await _api.bulkPromoteStudents(studentIds);
      // Refresh list after promote
      _students = await _api.getAllStudents();
      _studentCount = _students.length;
      _isStudentsActionLoading = false;
      notifyListeners();
      return result;
    } on AuthException catch (e) {
      _setError(e.message);
      _isStudentsActionLoading = false;
      notifyListeners();
      return null;
    } catch (_) {
      _setError('Failed to promote students. Please try again.');
      _isStudentsActionLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Bulk deletes (graduates) a list of students.
  Future<bool> bulkDeleteStudents(List<String> studentIds) async {
    _isStudentsActionLoading = true;
    _setError(null);
    notifyListeners();
    try {
      await _api.bulkDeleteStudents(studentIds);
      _students.removeWhere((s) => studentIds.contains(s.id));
      _studentCount = _students.length;
      _isStudentsActionLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _isStudentsActionLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _setError('Failed to delete students. Please try again.');
      _isStudentsActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAllCoursesCount() async {
    _isAllCoursesCountLoading = true;
    notifyListeners();
    try {
      final list = await _api.getAllCourses();
      _allCoursesCount = list.length;
      _isAllCoursesCountLoading = false;
      notifyListeners();
    } on AuthException {
      _isAllCoursesCountLoading = false;
      notifyListeners();
    } catch (_) {
      _isAllCoursesCountLoading = false;
      notifyListeners();
    }
  }

  // ── Reset ──────────────────────────────────────────────────────────────────

  /// Call on logout to wipe all cached data.
  void clear() {
    _teachers = [];
    _semesters = [];
    _pendingStudents = [];
    _assignments = [];
    _coursesBySemester.clear();

    _semestersLoaded = false;
    _pendingStudentsLoaded = false;
    _assignmentsLoaded = false;
    _loadingSemestersForCourses.clear();

    _errorMessage = null;
    _teachersError = null;
    _semestersError = null;
    _pendingStudentsError = null;
    _assignmentsError = null;
    _coursesErrorBySemester.clear();

    _isLoading = false;
    _isTeachersLoading = false;
    _isSemestersLoading = false;
    _isPendingStudentsLoading = false;
    _isAssignmentsLoading = false;
    notifyListeners();
  }

  // ── Student Approval Methods ─────────────────────────────────────────

  /// Fetches all pending students. Pass [force] = true to bypass cache.
  Future<void> fetchPendingStudents({bool force = false}) async {
    if (_pendingStudentsLoaded && !force) return;
    _isPendingStudentsLoading = true;
    _pendingStudentsError = null;
    notifyListeners();
    try {
      debugPrint('== AdminProvider: calling getPendingStudents()');
      _pendingStudents = await _api.getPendingStudents();
      debugPrint(
          '== AdminProvider: got ${_pendingStudents.length} pending students');
      _pendingStudentsLoaded = true;
      _isPendingStudentsLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      debugPrint('== AdminProvider: getPendingStudents error: ${e.message}');
      _pendingStudentsError = e.message;
      _isPendingStudentsLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('== AdminProvider: getPendingStudents error: $e');
      _pendingStudentsError = 'An unexpected error occurred.';
      _isPendingStudentsLoading = false;
      notifyListeners();
    }
  }

  /// Approves a pending student. Removes them from the local list on success.
  Future<bool> approveStudent(String studentId, {String? notes}) async {
    _approvingStudentIds.add(studentId);
    _setError(null);
    notifyListeners();
    try {
      await _api.approveStudent(studentId, notes: notes);
      _pendingStudents =
          _pendingStudents.where((s) => s.id != studentId).toList();
      _approvingStudentIds.remove(studentId);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _approvingStudentIds.remove(studentId);
      notifyListeners();
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _approvingStudentIds.remove(studentId);
      notifyListeners();
      return false;
    }
  }

  /// Rejects a pending student. Removes them from the local list on success.
  Future<bool> rejectStudent(String studentId, {String? notes}) async {
    _rejectingStudentIds.add(studentId);
    _setError(null);
    notifyListeners();
    try {
      await _api.rejectStudent(studentId, notes: notes);
      _pendingStudents =
          _pendingStudents.where((s) => s.id != studentId).toList();
      _rejectingStudentIds.remove(studentId);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _rejectingStudentIds.remove(studentId);
      notifyListeners();
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      _rejectingStudentIds.remove(studentId);
      notifyListeners();
      return false;
    }
  }

  // ── Schedule Methods ──────────────────────────────────────────────

  /// Convert raw API timetable JSON to the UI Timetable model.
  Timetable _fromApi(TimetableFromApi raw) => Timetable(
        id: raw.id,
        semesterNumber: raw.semesterNumber,
        semesterId: raw.semesterId,
        academicSession: raw.academicSession,
        section: raw.section,
        periods:
            raw.periods.map((p) => PeriodSlot.fromJson(p)).toList(),
        entries: raw.entries
            .map((e) => TimetableEntry(
                  day: e['day'] as String,
                  periodId: e['period_id'] as String,
                  courseCode: e['course_code'] as String,
                  courseTitle: e['course_title'] as String,
                  teacherName: e['teacher_name'] as String,
                ))
            .toList(),
      );

  /// GET /admin/schedule/ — fetch all timetables.
  Future<void> fetchTimetables({bool force = false}) async {
    if (_timetables.isNotEmpty && !force) return;
    _isTimetablesLoading = true;
    _timetablesError = null;
    notifyListeners();
    try {
      final raw = await _api.getTimetables();
      _timetables = raw.map(_fromApi).toList();
      _isTimetablesLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      _timetablesError = e.message;
      _isTimetablesLoading = false;
      notifyListeners();
    } catch (_) {
      _timetablesError = 'An unexpected error occurred.';
      _isTimetablesLoading = false;
      notifyListeners();
    }
  }

  /// POST /admin/schedule/ — create a new timetable.
  /// Returns the created [Timetable] on success, or null on failure.
  Future<Timetable?> createTimetable({
    required String semesterId,
    required String section,
    required String academicSession,
    required List<PeriodSlot> periods,
  }) async {
    _isScheduleActionLoading = true;
    _scheduleActionError = null;
    notifyListeners();
    try {
      final raw = await _api.createTimetable(
        semesterId: semesterId,
        section: section,
        academicSession: academicSession,
        periods: periods.map((p) => p.toJson()).toList(),
      );
      final tt = _fromApi(raw);
      _timetables = [tt, ..._timetables];
      _isScheduleActionLoading = false;
      notifyListeners();
      return tt;
    } on AuthException catch (e) {
      _scheduleActionError = e.message;
      _isScheduleActionLoading = false;
      notifyListeners();
      return null;
    } catch (_) {
      _scheduleActionError = 'An unexpected error occurred.';
      _isScheduleActionLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// PATCH /admin/schedule/{id}/periods — replace the period list.
  Future<Timetable?> updateTimetablePeriods({
    required String timetableId,
    required List<PeriodSlot> periods,
  }) async {
    _isScheduleActionLoading = true;
    _scheduleActionError = null;
    notifyListeners();
    try {
      final raw = await _api.updateTimetablePeriods(
        id: timetableId,
        periods: periods.map((p) => p.toJson()).toList(),
      );
      final tt = _fromApi(raw);
      _timetables = _timetables.map((t) => t.id == timetableId ? tt : t).toList();
      _isScheduleActionLoading = false;
      notifyListeners();
      return tt;
    } on AuthException catch (e) {
      _scheduleActionError = e.message;
      _isScheduleActionLoading = false;
      notifyListeners();
      return null;
    } catch (_) {
      _scheduleActionError = 'An unexpected error occurred.';
      _isScheduleActionLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// PUT /admin/schedule/{id}/entries — assign or update a slot.
  Future<Timetable?> assignScheduleEntry({
    required String timetableId,
    required String day,
    required String periodId,
    required String courseCode,
    required String courseTitle,
    required String teacherName,
  }) async {
    _isScheduleActionLoading = true;
    _scheduleActionError = null;
    notifyListeners();
    try {
      final raw = await _api.assignTimetableEntry(
        timetableId: timetableId,
        day: day,
        periodId: periodId,
        courseCode: courseCode,
        courseTitle: courseTitle,
        teacherName: teacherName,
      );
      final tt = _fromApi(raw);
      _timetables = _timetables.map((t) => t.id == timetableId ? tt : t).toList();
      _isScheduleActionLoading = false;
      notifyListeners();
      return tt;
    } on AuthException catch (e) {
      _scheduleActionError = e.message;
      _isScheduleActionLoading = false;
      notifyListeners();
      return null;
    } catch (_) {
      _scheduleActionError = 'An unexpected error occurred.';
      _isScheduleActionLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// DELETE /admin/schedule/{id}/entries — clear a slot.
  Future<Timetable?> clearScheduleEntry({
    required String timetableId,
    required String day,
    required String periodId,
  }) async {
    _isScheduleActionLoading = true;
    _scheduleActionError = null;
    notifyListeners();
    try {
      final raw = await _api.clearTimetableEntry(
        timetableId: timetableId,
        day: day,
        periodId: periodId,
      );
      final tt = _fromApi(raw);
      _timetables = _timetables.map((t) => t.id == timetableId ? tt : t).toList();
      _isScheduleActionLoading = false;
      notifyListeners();
      return tt;
    } on AuthException catch (e) {
      _scheduleActionError = e.message;
      _isScheduleActionLoading = false;
      notifyListeners();
      return null;
    } catch (_) {
      _scheduleActionError = 'An unexpected error occurred.';
      _isScheduleActionLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// DELETE /admin/schedule/{id} — delete a whole timetable.
  Future<bool> deleteTimetable(String timetableId) async {
    _isScheduleActionLoading = true;
    _scheduleActionError = null;
    notifyListeners();
    try {
      await _api.deleteTimetable(timetableId);
      _timetables.removeWhere((t) => t.id == timetableId);
      _isScheduleActionLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _scheduleActionError = e.message;
      _isScheduleActionLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _scheduleActionError = 'An unexpected error occurred.';
      _isScheduleActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// GET /admin/assignments/?semester_id=&section= — load course+teacher list
  /// for the slot assignment dropdown. Results cached by "semesterId:section".
  Future<void> fetchScheduleAssignments({
    required String semesterId,
    required String section,
    bool force = false,
  }) async {
    final key = '$semesterId:$section';
    if (_scheduleAssignments.containsKey(key) && !force) return;
    try {
      final list = await _api.getAssignmentsFiltered(
          semesterId: semesterId, section: section);
      _scheduleAssignments[key] = list;
      notifyListeners();
    } catch (_) {
      // Silently ignore — the UI will show an empty dropdown
    }
  }

  void clearScheduleActionError() {
    _scheduleActionError = null;
    notifyListeners();
  }

  // ── Enrollment Deadline Methods ───────────────────────────────────────────

  /// Fetches the current enrollment deadline and caches it.
  Future<void> fetchEnrollmentDeadline() async {
    _isDeadlineLoading = true;
    _deadlineError = null;
    notifyListeners();
    try {
      final model = await _api.getEnrollmentDeadline();
      _enrollmentDeadline = model.deadlineDate;
      _isDeadlineLoading = false;
      notifyListeners();
    } on AuthException catch (e) {
      _deadlineError = e.message;
      _isDeadlineLoading = false;
      notifyListeners();
    } catch (_) {
      _deadlineError = 'Failed to load enrollment deadline.';
      _isDeadlineLoading = false;
      notifyListeners();
    }
  }

  /// Saves the chosen deadline to the backend. Returns true on success.
  Future<bool> saveEnrollmentDeadline(DateTime deadline) async {
    _isDeadlineSaving = true;
    _deadlineError = null;
    notifyListeners();
    final formatted =
        '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}';
    try {
      final model = await _api.setEnrollmentDeadline(formatted);
      _enrollmentDeadline = model.deadlineDate;
      _isDeadlineSaving = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _deadlineError = e.message;
      _isDeadlineSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _deadlineError = 'Failed to save enrollment deadline.';
      _isDeadlineSaving = false;
      notifyListeners();
      return false;
    }
  }
}
