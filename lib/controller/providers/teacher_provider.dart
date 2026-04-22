import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/teacher_profile_summary_model.dart';
import 'package:facialtrackapp/core/models/teacher_schedule_slot_model.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:facialtrackapp/services/storage_service.dart';
import 'package:flutter/foundation.dart';

/// Manages teacher-specific state.
///
/// Used by:
///   - TeacherWaitingApprovalScreen  (checkApprovalStatus)
///   - TeacherProfileScreen          (fetchProfile / teacherProfile)
///   - TeacherDashboardScreen        (teacherProfile for name banner)
class TeacherProvider extends ChangeNotifier {
  final ApiManager _api = ApiManager.instance;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _teacherProfile;
  TeacherProfileSummaryModel? _profileSummary;
  List<TeacherScheduleSlotModel> _mySchedule = [];
  bool _isScheduleLoading = false;
  String? _scheduleError;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get teacherProfile => _teacherProfile;
  TeacherProfileSummaryModel? get profileSummary => _profileSummary;
  List<TeacherScheduleSlotModel> get mySchedule => _mySchedule;
  bool get isScheduleLoading => _isScheduleLoading;
  String? get scheduleError => _scheduleError;

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

  // ── Methods ────────────────────────────────────────────────────────────────

  /// Fetches the current teacher's full profile from the API and caches it.
  /// Returns true on success.
  Future<bool> fetchProfile() async {
    _setLoading(true);
    _setError(null);
    try {
      _teacherProfile = await _api.getMe();
      notifyListeners();
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

  /// Silently polls /me to check approval status.
  /// Returns the fresh [UserModel] on success, null on failure (so the
  /// waiting screen can decide whether to stop or keep polling).
  Future<UserModel?> checkApprovalStatus() async {
    try {
      final user = await _api.getMe();
      _teacherProfile = user;
      notifyListeners();
      return user;
    } on AuthException {
      // Token expired — caller should stop polling
      return null;
    } catch (_) {
      // Network glitch — caller should keep polling
      return null;
    }
  }

  /// Fetches teacher profile summary:
  /// subjects assigned count, total classes handled, active sessions, and subjects list.
  Future<bool> fetchProfileSummary() async {
    _setLoading(true);
    _setError(null);
    try {
      final teacherId = await StorageService.getUserId();
      if (teacherId == null) {
        _setError('Teacher identity missing. Please login again.');
        _setLoading(false);
        return false;
      }

      _profileSummary = await _api.getTeacherProfileSummary(teacherId);
      notifyListeners();
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('Failed to load profile summary.');
      _setLoading(false);
      return false;
    }
  }

  /// Loads full assigned schedule list for teacher.
  Future<bool> fetchMySchedule({String? forDate, String? day}) async {
    _isScheduleLoading = true;
    _scheduleError = null;
    notifyListeners();
    try {
      final teacherId = await StorageService.getUserId();
      if (teacherId == null) {
        _scheduleError = 'Teacher identity missing. Please login again.';
        _isScheduleLoading = false;
        notifyListeners();
        return false;
      }

      _mySchedule = await _api.getTeacherScheduleAll(
        teacherId,
        forDate: forDate,
        day: day,
      );
      _isScheduleLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _scheduleError = e.message;
      _isScheduleLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _scheduleError = 'Failed to load schedule.';
      _isScheduleLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Resets provider state (call on logout).
  void clear() {
    _teacherProfile = null;
    _profileSummary = null;
    _mySchedule = [];
    _errorMessage = null;
    _scheduleError = null;
    _isLoading = false;
    _isScheduleLoading = false;
    notifyListeners();
  }
}
