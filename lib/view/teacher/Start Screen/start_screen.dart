import 'package:facialtrackapp/controller/providers/session_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/teacher_course_model.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/live_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Border/fill for empty-state fields (no prefix icon).
InputDecoration _emptySessionFieldDecoration(Color color) => InputDecoration(
      isDense: true,
      filled: true,
      fillColor: color.withOpacity(0.07),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color.withOpacity(0.2), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );

/// Shown directly above Start Session actions.
Widget _sessionStartNote() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.info_outline,
        size: 16,
        color: Colors.blueGrey.shade600,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'One live session per subject — use End Attendance if a class is already running.',
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.grey.shade700,
            height: 1.25,
          ),
        ),
      ),
    ],
  );
}

class StartSessionScreen extends StatefulWidget {
  final bool showBackButton;
  const StartSessionScreen({super.key, this.showBackButton = false});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  static const _primaryColor = Color.fromARGB(255, 35, 4, 170);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SessionProvider>();
      provider.loadCourses();
      provider.refreshActiveSessions();
      provider.startActiveSessionsPolling();
    });
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onStartManual(SessionProvider provider) async {
    final success = await provider.createSession();
    if (!mounted) return;
    if (success && provider.currentSession != null) {
      _navigateToLive(provider.currentSession!.id);
    } else if (provider.errorMessage != null) {
      _showError(provider.errorMessage!);
      provider.clearError();
    }
  }

  void _navigateToLive(String sessionId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LiveSessionScreen(sessionId: sessionId),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        return PopScope(
          canPop: widget.showBackButton,
          onPopInvokedWithResult: (didPop, _) {},
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: widget.showBackButton
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null,
                title: Row(
                  children: [
                    if (!widget.showBackButton) const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Start Attendance Session',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: provider.isLoading && provider.courses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _ManualTab(
                      provider: provider,
                      primaryColor: _primaryColor,
                      onStart: () => _onStartManual(provider),
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ── Start session form (semester + subject + note + button) ───────────────────

class _ManualTab extends StatelessWidget {
  final SessionProvider provider;
  final Color primaryColor;
  final VoidCallback onStart;

  const _ManualTab({
    required this.provider,
    required this.primaryColor,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final semesters = provider.distinctSemesters;
    final courses =
        provider.coursesForSemester(provider.selectedSemesterId);
    final isReady = provider.selectedSemesterId != null &&
        provider.selectedCourseId != null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.play_circle_outline,
            title: 'Start attendance',
            subtitle: 'Select semester, then subject',
          ),
          const SizedBox(height: 32),

          _buildLabel('Select Semester', primaryColor),
          _buildSemesterDropdown(semesters, provider, primaryColor),
          const SizedBox(height: 24),

          _buildLabel('Select Subject', primaryColor),
          _buildCourseDropdown(courses, provider, primaryColor),
          const SizedBox(height: 28),

          _sessionStartNote(),
          const SizedBox(height: 14),

          Opacity(
            opacity: isReady ? 1.0 : 0.5,
            child: ElevatedButton.icon(
              onPressed:
                  isReady && !provider.isLoading ? onStart : null,
              icon: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                provider.isLoading ? 'Starting…' : 'Start Session',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34A853),
                disabledBackgroundColor:
                    const Color(0xFF34A853).withOpacity(0.5),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style:
              TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      );

  Widget _buildSemesterDropdown(
      List<SemesterModel> semesters,
      SessionProvider provider,
      Color color) {
    if (semesters.isEmpty) {
      final message = provider.errorMessage != null
          ? 'Could not load your courses. Try again in a moment or contact support if this continues.'
          : 'You have no course assignments yet. Ask an administrator to assign subjects before you can pick a semester here.';
      return _DropdownCard(
        child: InputDecorator(
          decoration: _emptySessionFieldDecoration(color),
          child: _EmptyDropdownNotice(
            accentColor: color,
            icon: Icons.info_outline_rounded,
            message: message,
          ),
        ),
      );
    }
    final value = provider.selectedSemesterId;
    return _DropdownCard(
      child: DropdownButtonFormField<String>(
        value: value,
        hint: const Text('Choose semester…'),
        isExpanded: true,
        icon: const SizedBox.shrink(),
        selectedItemBuilder: (_) => semesters
            .map((s) => Text(
                  'Semester ${s.semesterNumber} — ${s.termLabel}',
                  overflow: TextOverflow.ellipsis,
                ))
            .toList(),
        decoration: _deco(color, Icons.groups, value != null),
        items: semesters
            .map((s) => DropdownMenuItem<String>(
                  value: s.id,
                  child: _DropdownItem(
                    label:
                        'Semester ${s.semesterNumber} — ${s.termLabel} ${s.academicSession}',
                    selected: value == s.id,
                    color: color,
                  ),
                ))
            .toList(),
        onChanged: provider.setSelectedSemester,
      ),
    );
  }

  Widget _buildCourseDropdown(
      List<TeacherCourseModel> courses,
      SessionProvider provider,
      Color color) {
    final value = provider.selectedCourseId;
    final enabled = provider.selectedSemesterId != null;
    if (enabled && courses.isEmpty) {
      return _DropdownCard(
        child: InputDecorator(
          decoration: _deco(color, Icons.book, false),
          child: _EmptyDropdownNotice(
            accentColor: color,
            icon: Icons.menu_book_outlined,
            message:
                'No subjects for this semester. If this looks wrong, ask an administrator to check your course assignments.',
          ),
        ),
      );
    }
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: _DropdownCard(
          child: DropdownButtonFormField<String>(
            value: courses.any((c) => c.id == value) ? value : null,
            hint: Text(enabled
                ? 'Choose subject…'
                : 'Select semester first'),
            isExpanded: true,
            icon: const SizedBox.shrink(),
            selectedItemBuilder: (_) => courses
                .map((c) => Text(
                      c.displayName,
                      overflow: TextOverflow.ellipsis,
                    ))
                .toList(),
            decoration: _deco(color, Icons.book, value != null),
            items: courses
                .map((c) => DropdownMenuItem<String>(
                      value: c.id,
                      child: _DropdownItem(
                        label: c.displayName,
                        selected: value == c.id,
                        color: color,
                      ),
                    ))
                .toList(),
            onChanged: provider.setSelectedCourse,
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(Color color, IconData icon, bool hasData) =>
      InputDecoration(
        prefixIcon: Icon(icon, color: color),
        suffixIcon: SizedBox(
          width: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasData)
                const Icon(Icons.check_circle,
                    color: Colors.teal, size: 18),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
              const SizedBox(width: 6),
            ],
          ),
        ),
        filled: true,
        fillColor: color.withOpacity(0.07),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: color.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// "Today's Schedule" tab — removed from UI (was Tab 2: _ScheduleTab, _SlotCard,
// _EmptySlots + createSessionFromSlot). Restore from git if timetable-based
// start is needed again; re-add imports: session_model, teacher_schedule_slot_model.
// ═══════════════════════════════════════════════════════════════════════════

// ── Shared helpers ────────────────────────────────────────────────────────────

class _EmptyDropdownNotice extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String message;

  const _EmptyDropdownNotice({
    required this.accentColor,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor.withOpacity(0.9), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 35, 4, 170).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              color: const Color.fromARGB(255, 35, 4, 170), size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 16)),
            Text(subtitle,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _DropdownCard extends StatelessWidget {
  final Widget child;
  const _DropdownCard({required this.child});

  @override
  Widget build(BuildContext context) => child;
}

class _DropdownItem extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  const _DropdownItem(
      {required this.label,
      required this.selected,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? color : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
