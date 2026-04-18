import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/session_provider.dart';
import 'package:facialtrackapp/core/models/session_model.dart';
import 'package:facialtrackapp/view/teacher/Report/montly_report_screen.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/live_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:facialtrackapp/view/teacher/Dashborad/teacher_dashboard_screen.dart';
import 'package:facialtrackapp/view/teacher/Profile/teacher_profile_screen.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/start_screen.dart';
import 'package:provider/provider.dart';

class TeacherRootScreen extends StatefulWidget {
  const TeacherRootScreen({super.key});

  @override
  State<TeacherRootScreen> createState() => _TeacherRootScreenState();
}

class _TeacherRootScreenState extends State<TeacherRootScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  // Active session resume state.
  SessionModel? _resumableSession;
  bool _bannerDismissed = false;

  final List<Widget> _screens = [
    const TeacherDashboardScreen(),
    const StartSessionScreen(),
    MonthlyAttendanceReport(),
    const TeacherProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.play_circle_fill,
    Icons.bar_chart_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    'Dashboard',
    'Start Session',
    'Reports',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    await Future.delayed(Duration.zero); // wait for first frame
    if (!mounted) return;
    try {
      final sessions =
          await context.read<SessionProvider>().getActiveSessions();
      if (!mounted || sessions.isEmpty) return;
      final active = sessions.first;
      // Restore provider state so LiveSessionScreen works after resume.
      if (mounted) {
        context.read<SessionProvider>().resumeSession(active);
        setState(() => _resumableSession = active);
      }
    } catch (_) {
      // Non-critical; silent fail.
    }
  }

  void _dismissBanner() => setState(() => _bannerDismissed = true);

  void _resumeSession(SessionModel session) {
    _dismissBanner();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveSessionScreen(sessionId: session.id),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showBanner =
        _resumableSession != null && !_bannerDismissed;

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Expanded(child: _screens[_selectedIndex]),

          // ── Active session resume banner ────────────────────────
          if (showBanner)
            _ResumeBanner(
              session: _resumableSession!,
              onResume: () => _resumeSession(_resumableSession!),
              onDismiss: _dismissBanner,
            ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorPallet.primaryBlue.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      _icons[index],
                      color: isSelected
                          ? ColorPallet.primaryBlue
                          : Colors.grey,
                      size: isSelected ? 28 : 24,
                    ),
                    const SizedBox(width: 6),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isSelected ? _labels[index] : '',
                        style: TextStyle(
                          color: ColorPallet.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Resume Banner ─────────────────────────────────────────────────────────────

class _ResumeBanner extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onResume;
  final VoidCallback onDismiss;

  const _ResumeBanner({
    required this.session,
    required this.onResume,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade700,
            Colors.deepOrange.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.circle,
                color: Colors.white, size: 10),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'You have an active class session. Tap to resume.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onResume,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Resume',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close,
                color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }
}
