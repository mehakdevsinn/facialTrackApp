import 'dart:async';

import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/attendance_record_model.dart';
import 'package:facialtrackapp/core/models/roster_student_model.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/session_model.dart';
import 'package:facialtrackapp/core/models/teacher_course_model.dart';
import 'package:facialtrackapp/core/models/teacher_schedule_slot_model.dart';
import 'package:facialtrackapp/services/storage_service.dart';
import 'package:flutter/foundation.dart';

/// Owns all state for the teacher session flow:
///   StartSessionScreen → LiveSessionScreen → AttendanceLogsScreen
///
/// Register in main.dart:
///   ChangeNotifierProvider(create: (_) => SessionProvider())
class SessionProvider extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  List<TeacherCourseModel> _courses = [];
  String? _selectedSemesterId;
  String? _selectedCourseId;

  SessionModel? _currentSession;
  List<RosterStudentModel> _rosterStudents = [];
  List<AttendanceRecordModel> _attendanceRecords = [];

  // ── Schedule (timetable tab) ───────────────────────────────────────────────
  List<TeacherScheduleSlotModel> _scheduleSlots = [];
  bool _scheduleLoading = false;
  String? _selectedSection;

  /// Set of student IDs being optimistically marked (shows spinner in avatar).
  final Set<String> _pendingMarkIds = {};

  Timer? _pollTimer;
  Timer? _activeSessionsPollTimer;
  List<SessionModel> _activeSessions = [];

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TeacherCourseModel> get courses => _courses;
  String? get selectedSemesterId => _selectedSemesterId;
  String? get selectedCourseId => _selectedCourseId;
  SessionModel? get currentSession => _currentSession;
  List<RosterStudentModel> get rosterStudents => _rosterStudents;
  List<AttendanceRecordModel> get attendanceRecords => _attendanceRecords;
  bool isPending(String studentId) => _pendingMarkIds.contains(studentId);
  List<TeacherScheduleSlotModel> get scheduleSlots => _scheduleSlots;
  bool get scheduleLoading => _scheduleLoading;
  String? get selectedSection => _selectedSection;
  List<SessionModel> get activeSessions => _activeSessions;

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Deduplicated, sorted list of semesters from [_courses].
  List<SemesterModel> get distinctSemesters {
    final seen = <String>{};
    final result = <SemesterModel>[];
    for (final c in _courses) {
      if (c.semester != null && seen.add(c.semester!.id)) {
        result.add(c.semester!);
      }
    }
    // Sort by start date ascending.
    result.sort((a, b) => a.startDate.compareTo(b.startDate));
    return result;
  }

  /// Courses filtered by the given [semesterId].
  List<TeacherCourseModel> coursesForSemester(String? semesterId) {
    if (semesterId == null) return [];
    return _courses.where((c) => c.semesterId == semesterId).toList();
  }

  /// The currently selected [TeacherCourseModel], or null.
  TeacherCourseModel? get selectedCourse {
    if (_selectedCourseId == null) return null;
    try {
      return _courses.firstWhere((c) => c.id == _selectedCourseId);
    } catch (_) {
      return null;
    }
  }

  SessionModel? activeSessionForCourse(String courseId) {
    try {
      return _activeSessions.firstWhere(
          (s) => s.isActive && s.courseId == courseId);
    } catch (_) {
      return null;
    }
  }

  /// Active session to highlight on the teacher dashboard: in-memory first,
  /// then any active row from the last [refreshActiveSessions] poll.
  SessionModel? get dashboardActiveSession {
    if (_currentSession != null && _currentSession!.isActive) {
      return _currentSession;
    }
    for (final s in _activeSessions) {
      if (s.isActive) return s;
    }
    return null;
  }

  /// Course title for [session] when [courses] is loaded; empty otherwise.
  String courseTitleForSession(SessionModel session) {
    for (final c in _courses) {
      if (c.id == session.courseId) return c.name;
    }
    return '';
  }

  /// Set of student IDs that already have an attendance record.
  Set<String> get presentStudentIds =>
      _attendanceRecords.map((r) => r.studentId).toSet();

  /// Students from the roster who are NOT yet marked present.
  List<RosterStudentModel> get absentStudents => _rosterStudents
      .where((s) => !presentStudentIds.contains(s.id))
      .toList();

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedSemester(String? id) {
    _selectedSemesterId = id;
    _selectedCourseId = null; // reset subject when semester changes
    _scheduleSlots = [];     // reset schedule when semester changes
    notifyListeners();
  }

  void setSelectedCourse(String? id) {
    _selectedCourseId = id;
    notifyListeners();
  }

  void setSelectedSection(String? section) {
    _selectedSection = section;
    _scheduleSlots = []; // reset schedule when section changes
    notifyListeners();
  }

  // ── 1. Load courses (called on Start Screen open) ─────────────────────────
  Future<void> loadCourses() async {
    _setLoading(true);
    _setError(null);
    try {
      final teacherId = await StorageService.getUserId();
      if (teacherId == null) throw Exception('Not logged in');
      _courses = await _api.getTeacherCourses(teacherId);
      _syncSelectionsAfterCourseLoad();
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load courses: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _syncSelectionsAfterCourseLoad() {
    if (_courses.isEmpty) {
      _selectedSemesterId = null;
      _selectedCourseId = null;
      _selectedSection = null;
      _scheduleSlots = [];
      return;
    }
    final semesterIds =
        _courses.map((c) => c.semesterId).where((id) => id.isNotEmpty).toSet();
    if (_selectedSemesterId == null ||
        !semesterIds.contains(_selectedSemesterId)) {
      _selectedSemesterId = _courses.first.semesterId;
      _selectedCourseId = null;
      _scheduleSlots = [];
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

  // ── 2. Create session (manual) ────────────────────────────────────────────
  /// Creates a session for [_selectedCourseId] starting now (±2 hours window).
  /// Returns true on success.
  Future<bool> createSession() async {
    if (_selectedCourseId == null) return false;
    _setLoading(true);
    _setError(null);
    try {
      final now = DateTime.now().toUtc();
      final end = now.add(const Duration(hours: 2));
      _currentSession = await _api.createSession(
        courseId: _selectedCourseId!,
        startTime: now.toIso8601String(),
        endTime: end.toIso8601String(),
      );
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      final lower = e.message.toLowerCase();
      if (lower.contains('already an active session') ||
          lower.contains('already active session')) {
        _setError(
            'A session is already active for this class. You can view it from active sessions.');
      } else {
        _setError(e.message);
      }
      return false;
    } catch (e) {
      _setError('Failed to create session: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── 2b. Create session from timetable slot ────────────────────────────────
  /// Creates a session using [slot]'s course_id and scheduled start/end times.
  /// Returns true on success.
  Future<bool> createSessionFromSlot(TeacherScheduleSlotModel slot) async {
    _setLoading(true);
    _setError(null);
    try {
      final today = DateTime.now();
      _currentSession = await _api.createSession(
        courseId: slot.courseId,
        startTime: slot.startIso(today),
        endTime: slot.endIso(today),
      );
      // Keep selectedCourseId in sync so selectedCourse getter works on Live screen.
      _selectedCourseId = slot.courseId;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      final lower = e.message.toLowerCase();
      if (lower.contains('already an active session') ||
          lower.contains('already active session')) {
        _setError(
            'A session is already active for this class. You can view it from active sessions.');
      } else {
        _setError(e.message);
      }
      return false;
    } catch (e) {
      _setError('Failed to create session: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── 3. Load roster for the selected course ────────────────────────────────
  Future<void> loadRoster() async {
    if (_selectedCourseId == null) return;
    try {
      final teacherId = await StorageService.getUserId();
      if (teacherId == null) return;
      _rosterStudents = await _api.getTeacherCourseStudents(
          teacherId, _selectedCourseId!);
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load students: ${e.toString()}');
    }
  }

  // ── 4. Load / refresh attendance for the current session ──────────────────
  Future<void> loadAttendance() async {
    if (_currentSession == null) return;
    try {
      _attendanceRecords =
          await _api.getSessionAttendance(_currentSession!.id);
      notifyListeners();
    } catch (_) {
      // Silent poll — don't show error on background refresh.
    }
  }

  // ── 5. Start live polling (10 s interval) ─────────────────────────────────
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      loadAttendance();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── 10. Fetch currently active sessions (for resume banner) ───────────────
  /// Returns sessions that are both is_active and currently within their
  /// time window. Wraps [ApiManager.getActiveSessions].
  Future<List<SessionModel>> getActiveSessions() =>
      _api.getActiveSessions();

  Future<void> refreshActiveSessions() async {
    try {
      _activeSessions = await _api.getActiveSessions();
      if (_currentSession != null) {
        final match = _activeSessions.where((s) => s.id == _currentSession!.id);
        if (match.isEmpty) {
          // session no longer active (possibly auto-stopped)
          _currentSession = null;
        }
      }
      notifyListeners();
    } catch (_) {
      // non-blocking background refresh
    }
  }

  void startActiveSessionsPolling() {
    _activeSessionsPollTimer?.cancel();
    _activeSessionsPollTimer =
        Timer.periodic(const Duration(seconds: 20), (_) {
      refreshActiveSessions();
    });
  }

  void stopActiveSessionsPolling() {
    _activeSessionsPollTimer?.cancel();
    _activeSessionsPollTimer = null;
  }

  // ── 10. Load today's schedule slots ───────────────────────────────────────
  /// Requires [_selectedSemesterId] + [_selectedSection] to be set.
  Future<void> loadSchedule() async {
    if (_selectedSemesterId == null || _selectedSection == null) return;
    _scheduleLoading = true;
    notifyListeners();
    try {
      final teacherId = await StorageService.getUserId();
      if (teacherId == null) return;
      final today = DateTime.now();

      // Only send for_date on Mon–Fri (weekday 1–5).
      // On weekends the backend returns an empty list for that date,
      // so we omit it to receive the full week of slots instead.
      final isWeekday = today.weekday >= DateTime.monday &&
          today.weekday <= DateTime.friday;
      final forDate = isWeekday
          ? '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}'
          : null;

      _scheduleSlots = await _api.getTeacherSchedule(
        teacherId,
        semesterId: _selectedSemesterId,
        section: _selectedSection,
        forDate: forDate,
      );
      await refreshActiveSessions();
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load schedule: ${e.toString()}');
    } finally {
      _scheduleLoading = false;
      notifyListeners();
    }
  }

  // ── 11. Resume an already-active session (from banner) ────────────────────
  /// Restores [_currentSession] and [_selectedCourseId] so LiveSessionScreen
  /// can fully function after app resume.
  void resumeSession(SessionModel session) {
    _currentSession = session;
    _selectedCourseId = session.courseId;
    notifyListeners();
  }

  // ── 6. Mark student present ───────────────────────────────────────────────
  /// Returns true on success, false if already marked (400) or other error.
  Future<bool> markPresent(String studentId) async {
    if (_currentSession == null) return false;
    _pendingMarkIds.add(studentId);
    notifyListeners();
    try {
      await _api.markAttendance(_currentSession!.id, studentId);
      await loadAttendance(); // refresh list
      return true;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already')) {
        // Already marked — just refresh, not an error for the user.
        await loadAttendance();
        return false;
      }
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Could not mark attendance.');
      return false;
    } finally {
      _pendingMarkIds.remove(studentId);
      notifyListeners();
    }
  }

  // ── 7. Remove attendance (toggle absent) ──────────────────────────────────
  Future<bool> markAbsent(String studentId) async {
    if (_currentSession == null) return false;
    _pendingMarkIds.add(studentId);
    notifyListeners();
    try {
      await _api.removeAttendance(_currentSession!.id, studentId);
      // Update list locally (optimistic) then confirm with server.
      _attendanceRecords.removeWhere((r) => r.studentId == studentId);
      notifyListeners();
      await loadAttendance();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Could not remove attendance.');
      return false;
    } finally {
      _pendingMarkIds.remove(studentId);
      notifyListeners();
    }
  }

  // ── 8. End / stop session ─────────────────────────────────────────────────
  /// Calls the stop endpoint. Returns the stopped [SessionModel] (is_active=false).
  Future<SessionModel?> endSession() async {
    if (_currentSession == null) return null;
    _setLoading(true);
    _setError(null);
    try {
      stopPolling();
      final stopped = await _api.stopSession(_currentSession!.id);
      _currentSession = stopped;
      notifyListeners();
      return stopped;
    } on AuthException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to end session.');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── 9. Load attendance by session ID (for Logs screen re-entry) ───────────
  /// If the session stored in [_currentSession] already matches [sessionId],
  /// attendance may already be loaded. Otherwise fetches fresh data.
  Future<void> ensureAttendanceLoaded(String sessionId) async {
    if (_currentSession?.id == sessionId && _attendanceRecords.isNotEmpty) {
      return; // already have data
    }
    try {
      _attendanceRecords = await _api.getSessionAttendance(sessionId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load attendance logs.');
    }
  }

  // ── Reset (logout / new flow) ─────────────────────────────────────────────
  void clear() {
    stopPolling();
    stopActiveSessionsPolling();
    _courses = [];
    _selectedSemesterId = null;
    _selectedCourseId = null;
    _currentSession = null;
    _rosterStudents = [];
    _attendanceRecords = [];
    _scheduleSlots = [];
    _selectedSection = null;
    _activeSessions = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _activeSessionsPollTimer?.cancel();
    super.dispose();
  }
}
