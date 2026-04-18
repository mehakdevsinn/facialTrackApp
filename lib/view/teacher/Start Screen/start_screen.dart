import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/session_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/teacher_course_model.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/live_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartSessionScreen extends StatefulWidget {
  final bool showBackButton;

  const StartSessionScreen({super.key, this.showBackButton = false});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  static const primaryColor = Color.fromARGB(255, 35, 4, 170);

  @override
  void initState() {
    super.initState();
    // Load real courses once; use post-frame so provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().loadCourses();
    });
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onStartSession(SessionProvider provider) async {
    final success = await provider.createSession();
    if (!mounted) return;
    if (success && provider.currentSession != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LiveSessionScreen(
            sessionId: provider.currentSession!.id,
          ),
        ),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
      provider.clearError();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        final semesters = provider.distinctSemesters;
        final courses =
            provider.coursesForSemester(provider.selectedSemesterId);
        final isReady =
            provider.selectedSemesterId != null &&
            provider.selectedCourseId != null;

        return PopScope(
          canPop: widget.showBackButton,
          onPopInvokedWithResult: (didPop, _) {},
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                backgroundColor: primaryColor,
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
                    if (!widget.showBackButton) const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      backgroundImage: AssetImage('assets/logo.png'),
                    ),
                    const SizedBox(width: 12),
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
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                'Start New Session',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'Select semester and subject to begin attendance',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // ── Semester dropdown ────────────────────────
                            _buildLabel('Select Semester', primaryColor),
                            _buildSemesterDropdown(semesters, provider),

                            const SizedBox(height: 25),

                            // ── Subject dropdown ─────────────────────────
                            _buildLabel('Select Subject', primaryColor),
                            _buildCourseDropdown(courses, provider),

                            const SizedBox(height: 100),

                            // ── Start button ─────────────────────────────
                            Opacity(
                              opacity: isReady ? 1.0 : 0.5,
                              child: ElevatedButton(
                                onPressed: isReady && !provider.isLoading
                                    ? () => _onStartSession(provider)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF81C784),
                                  disabledBackgroundColor:
                                      const Color(0xFF81C784).withOpacity(0.5),
                                  minimumSize:
                                      const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: provider.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Start Session',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildSemesterDropdown(
      List<SemesterModel> semesters, SessionProvider provider) {
    final value = provider.selectedSemesterId;
    final hasData = value != null;

    return _dropdownContainer(
      hasData: hasData,
      child: DropdownButtonFormField<String>(
        value: value,
        hint: const Text('Choose semester...'),
        isExpanded: true,
        icon: const SizedBox.shrink(),
        selectedItemBuilder: (_) => semesters
            .map((s) => Text(
                  'Semester ${s.semesterNumber} — ${s.termLabel} ${s.academicSession}',
                  style: const TextStyle(
                      color: Colors.black87, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ))
            .toList(),
        decoration: _dropdownDecoration(
          primaryColor,
          Icons.groups,
          hasData,
        ),
        items: semesters
            .map((s) => DropdownMenuItem<String>(
                  value: s.id,
                  child: Row(
                    children: [
                      Icon(
                        value == s.id
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: value == s.id ? primaryColor : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Semester ${s.semesterNumber} — ${s.termLabel} ${s.academicSession}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (id) => provider.setSelectedSemester(id),
      ),
    );
  }

  Widget _buildCourseDropdown(
      List<TeacherCourseModel> courses, SessionProvider provider) {
    final value = provider.selectedCourseId;
    final hasData = value != null;
    final enabled = provider.selectedSemesterId != null;

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: _dropdownContainer(
          hasData: hasData,
          child: DropdownButtonFormField<String>(
            value: courses.any((c) => c.id == value) ? value : null,
            hint: Text(
                enabled ? 'Choose subject...' : 'Select semester first'),
            isExpanded: true,
            icon: const SizedBox.shrink(),
            selectedItemBuilder: (_) => courses
                .map((c) => Text(
                      c.displayName,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ))
                .toList(),
            decoration: _dropdownDecoration(
              primaryColor,
              Icons.book,
              hasData,
            ),
            items: courses
                .map((c) => DropdownMenuItem<String>(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(
                            value == c.id
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: value == c.id
                                ? primaryColor
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              c.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (id) => provider.setSelectedCourse(id),
          ),
        ),
      ),
    );
  }

  Widget _dropdownContainer({
    required bool hasData,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [],
      ),
      child: child,
    );
  }

  InputDecoration _dropdownDecoration(
      Color color, IconData icon, bool hasData) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: color),
      suffixIcon: SizedBox(
        width: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (hasData)
              const Icon(Icons.check_circle, color: Colors.teal, size: 20),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
            const SizedBox(width: 8),
          ],
        ),
      ),
      filled: true,
      fillColor: color.withOpacity(0.08),
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
}
