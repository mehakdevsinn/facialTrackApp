import 'package:facialtrackapp/controller/providers/session_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/session_model.dart';
import 'package:facialtrackapp/core/models/teacher_course_model.dart';
import 'package:facialtrackapp/core/models/teacher_schedule_slot_model.dart';
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

class StartSessionScreen extends StatefulWidget {
  final bool showBackButton;
  const StartSessionScreen({super.key, this.showBackButton = false});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen>
    with SingleTickerProviderStateMixin {
  static const _primaryColor = Color.fromARGB(255, 35, 4, 170);

  late TabController _tabController;

  static const _sections = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SessionProvider>();
      provider.loadCourses();
      provider.refreshActiveSessions();
      provider.startActiveSessionsPolling();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _onStartFromSlot(
      SessionProvider provider, TeacherScheduleSlotModel slot) async {
    final success = await provider.createSessionFromSlot(slot);
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
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.tune), text: 'Manual'),
                    Tab(
                        icon: Icon(Icons.calendar_today),
                        text: "Today's Schedule"),
                  ],
                ),
              ),
              body: provider.isLoading && provider.courses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _ManualTab(
                          provider: provider,
                          primaryColor: _primaryColor,
                          onStart: () => _onStartManual(provider),
                        ),
                        _ScheduleTab(
                          provider: provider,
                          primaryColor: _primaryColor,
                          sections: _sections,
                          onStart: (slot) =>
                              _onStartFromSlot(provider, slot),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ── Tab 1: Manual ─────────────────────────────────────────────────────────────

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
            icon: Icons.tune,
            title: 'Manual Selection',
            subtitle: 'Choose semester and subject to begin',
          ),
          const SizedBox(height: 32),

          _buildLabel('Select Semester', primaryColor),
          _buildSemesterDropdown(semesters, provider, primaryColor),
          const SizedBox(height: 24),

          _buildLabel('Select Subject', primaryColor),
          _buildCourseDropdown(courses, provider, primaryColor),
          const SizedBox(height: 48),

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

// ── Tab 2: Today's Schedule ───────────────────────────────────────────────────

class _ScheduleTab extends StatelessWidget {
  final SessionProvider provider;
  final Color primaryColor;
  final List<String> sections;
  final void Function(TeacherScheduleSlotModel slot) onStart;

  const _ScheduleTab({
    required this.provider,
    required this.primaryColor,
    required this.sections,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final semesters = provider.distinctSemesters;
    final canLoad = provider.selectedSemesterId != null &&
        provider.selectedSection != null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.calendar_today,
            title: "Today's Schedule",
            subtitle: 'Pick semester + section to load your slots',
          ),
          const SizedBox(height: 24),

          // ── Semester picker ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Semester',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ),
          _DropdownCard(
            child: semesters.isEmpty
                ? InputDecorator(
                    decoration: _emptySessionFieldDecoration(primaryColor),
                    child: _EmptyDropdownNotice(
                      accentColor: primaryColor,
                      icon: Icons.info_outline_rounded,
                      message: provider.errorMessage != null
                          ? 'Could not load your courses. Try again in a moment or contact support if this continues.'
                          : 'You have no course assignments yet. Ask an administrator to assign subjects before you can load today\'s schedule slots.',
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: provider.selectedSemesterId,
                    hint: const Text('Choose semester…'),
                    isExpanded: true,
                    icon: const SizedBox.shrink(),
                    selectedItemBuilder: (_) => semesters
                        .map((s) => Text(
                              'Semester ${s.semesterNumber} — ${s.termLabel}',
                              overflow: TextOverflow.ellipsis,
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.groups, color: primaryColor),
                      suffixIcon: const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                      filled: true,
                      fillColor: primaryColor.withOpacity(0.07),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: primaryColor.withOpacity(0.2), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: semesters
                        .map((s) => DropdownMenuItem<String>(
                              value: s.id,
                              child: _DropdownItem(
                                label:
                                    'Semester ${s.semesterNumber} — ${s.termLabel} ${s.academicSession}',
                                selected:
                                    provider.selectedSemesterId == s.id,
                                color: primaryColor,
                              ),
                            ))
                        .toList(),
                    onChanged: provider.setSelectedSemester,
                  ),
          ),
          const SizedBox(height: 16),

          // ── Section picker ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Section',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ),
          _DropdownCard(
            child: DropdownButtonFormField<String>(
              value: provider.selectedSection,
              hint: const Text('Choose section…'),
              isExpanded: true,
              icon: const SizedBox.shrink(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.people_alt, color: primaryColor),
                suffixIcon: const Icon(Icons.arrow_drop_down,
                    color: Colors.grey),
                filled: true,
                fillColor: primaryColor.withOpacity(0.07),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: primaryColor.withOpacity(0.2), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: sections
                  .map((s) => DropdownMenuItem<String>(
                        value: s,
                        child: _DropdownItem(
                          label: 'Section $s',
                          selected: provider.selectedSection == s,
                          color: primaryColor,
                        ),
                      ))
                  .toList(),
              onChanged: semesters.isEmpty ? null : provider.setSelectedSection,
            ),
          ),
          const SizedBox(height: 20),

          // ── Load slots button ────────────────────────────────────
          ElevatedButton.icon(
            onPressed: canLoad && !provider.scheduleLoading
                ? () => provider.loadSchedule()
                : null,
            icon: provider.scheduleLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(Icons.search, color: Colors.white),
            label: Text(
              provider.scheduleLoading
                  ? 'Loading…'
                  : "Load Today's Slots",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              disabledBackgroundColor: primaryColor.withOpacity(0.4),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Slot cards ───────────────────────────────────────────
          if (!provider.scheduleLoading) ...[
            if (provider.scheduleSlots.isEmpty &&
                provider.selectedSemesterId != null &&
                provider.selectedSection != null)
              _EmptySlots(primaryColor: primaryColor)
            else
              ...provider.scheduleSlots.map(
                (slot) => _SlotCard(
                  slot: slot,
                  primaryColor: primaryColor,
                  isLoading: provider.isLoading,
                  activeSession: provider.activeSessionForCourse(slot.courseId),
                  onStart: () => onStart(slot),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Slot Card ─────────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  final TeacherScheduleSlotModel slot;
  final Color primaryColor;
  final bool isLoading;
  final VoidCallback onStart;
  final SessionModel? activeSession;

  const _SlotCard({
    required this.slot,
    required this.primaryColor,
    required this.isLoading,
    required this.onStart,
    required this.activeSession,
  });

  @override
  Widget build(BuildContext context) {
    final hasActive = activeSession != null;
    final isAuto = (activeSession?.notes ?? '').toLowerCase() ==
        'auto-created from timetable';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.access_time, color: primaryColor),
        ),
        title: Text(
          slot.courseName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              slot.periodLabel,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 13, color: primaryColor),
                const SizedBox(width: 4),
                Text(
                  slot.displayTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Section ${slot.section}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (hasActive && isAuto) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Auto (Timetable)',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (hasActive) {
                          context
                              .read<SessionProvider>()
                              .resumeSession(activeSession!);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LiveSessionScreen(sessionId: activeSession!.id),
                            ),
                          );
                          return;
                        }
                        onStart();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasActive ? Colors.orange.shade700 : const Color(0xFF34A853),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(60, 36),
                ),
                child: Text(
                  hasActive ? 'View' : 'Start',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
        isThreeLine: hasActive && isAuto,
        subtitleTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptySlots extends StatelessWidget {
  final Color primaryColor;
  const _EmptySlots({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'No classes scheduled for today',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try the Manual tab to start a session anyway',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

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
