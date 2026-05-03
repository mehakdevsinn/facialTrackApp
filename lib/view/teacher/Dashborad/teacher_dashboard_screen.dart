import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/controller/providers/auth_provider.dart';
import 'package:facialtrackapp/controller/providers/session_provider.dart';
import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/core/utils/teacher_session_display.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/live_session_screen.dart';
import 'package:facialtrackapp/view/teacher/Complaints/teacher_side_complain_screen.dart';
import 'package:facialtrackapp/view/teacher/Profile/teacher_profile_screen.dart';
import 'package:facialtrackapp/view/teacher/Report/report_options_screen.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/start_screen.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/view_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int? _pendingComplaintCount;
  bool _pendingComplaintsLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = context.read<SessionProvider>();
      session.refreshActiveSessions();
      session.loadCourses();
      _loadPendingComplaintCount();
    });
  }

  Future<void> _loadPendingComplaintCount({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _pendingComplaintsLoading = true);
    }
    try {
      final list =
          await ApiManager.instance.getTeacherComplaintsInbox(status: 'pending');
      if (!mounted) return;
      setState(() {
        _pendingComplaintCount = list.length;
        _pendingComplaintsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pendingComplaintCount = null;
        _pendingComplaintsLoading = false;
      });
    }
  }

  String _complaintsBannerSubtitle() {
    if (_pendingComplaintsLoading) {
      return 'Checking inbox…';
    }
    final n = _pendingComplaintCount;
    if (n == null) {
      return 'Tap to open complaints inbox';
    }
    if (n == 0) {
      return 'No pending attendance disputes';
    }
    if (n == 1) {
      return '1 pending complaint to review';
    }
    return '$n pending complaints to review';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Yeh back button ko fully disable kar deta hai
      onPopInvokedWithResult: (didPop, result) {
        // Agar back button dabaya jaye toh yahan kuch na likhen
        // Isse screen pop nahi hogi aur na hi koi dialog aayega
        if (didPop) return;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffF6F8FB),
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: ColorPallet.primaryBlue,
            foregroundColor: Colors.white,
            title: const Text(
              'Facial Track',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            actions: [
              PopupMenuButton<int>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onSelected: (value) {
                  if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Yahan showBackButton true bhejain
                        builder: (context) =>
                            TeacherProfileScreen(showBackButton: true),
                      ),
                    );
                  } else if (value == 2) {
                    _showLogoutDialog(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/logo.png'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.watch<AuthProvider>().currentUser?.fullName ??
                            'Teacher',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('View Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) => Text(
                          'Welcome, ${auth.currentUser?.fullName ?? 'Teacher'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTeacherSessionDatePkt(
                          DateTime.now().toUtc(),
                          pattern: 'EEEE, MMMM d, y',
                        ),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      Consumer<SessionProvider>(
                        builder: (context, sessionProvider, _) =>
                            _ActiveSessionCallout(provider: sessionProvider),
                      ),

                      const SizedBox(height: 8),

                      // ---------------- GRID CARDS ----------------
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // TeacherDashboardScreen ke andar
                          _AnimatedDashboardCard(
                            color: Colors.green,
                            icon: Icons.play_arrow,
                            title: 'Start Attendance',
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Yahan showBackButton true bhejain
                                  builder: (context) =>
                                      StartSessionScreen(showBackButton: true),
                                ),
                              ).then((_) {
                                if (!context.mounted) return;
                                context
                                    .read<SessionProvider>()
                                    .refreshActiveSessions();
                              });
                            },
                          ),
                          Consumer<SessionProvider>(
                            builder: (context, provider, _) {
                              final session = provider.dashboardActiveSession;
                              final hasActiveSession =
                                  session != null && session.isActive;
                              return _AnimatedDashboardCard(
                                color: Colors.orange,
                                icon: Icons.stop,
                                title: 'End Attendance',
                                subtitle: hasActiveSession
                                    ? null
                                    : 'No active session',
                                ontap: hasActiveSession
                                    ? () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LiveSessionScreen(
                                                sessionId: session.id),
                                          ),
                                        ).then((_) {
                                          if (!context.mounted) return;
                                          context
                                              .read<SessionProvider>()
                                              .refreshActiveSessions();
                                        })
                                    : null,
                              );
                            },
                          ),
                          _AnimatedDashboardCard(
                            color: Colors.blue,
                            icon: Icons.calendar_today,
                            title: "Today's Logs",
                            ontap: () {
                              final session = context
                                  .read<SessionProvider>()
                                  .dashboardActiveSession;
                              if (session != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AttendanceLogsScreen(
                                        sessionId: session.id),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'No session available. Start a session first.'),
                                  ),
                                );
                              }
                            },
                          ),
                          // _AnimatedDashboardCard(
                          //   color: Colors.purple,
                          //   icon: Icons.bar_chart,
                          //   title: 'Monthly Report',
                          //   ontap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         // Yahan showBackButton true bhejain
                          //         builder: (context) =>
                          //             AttendanceReport(showBackButton: true),
                          //       ),
                          //     );
                          //   },
                          // ),
                          // _AnimatedDashboardCard(
                          //   color: Colors.pinkAccent,
                          //   icon: Icons.analytics_rounded,
                          //   title: 'Analytics',
                          //   ontap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => const SelectionScreen(),
                          //       ),
                          //     );
                          //   },
                          // ),
                          // _AnimatedDashboardCard(
                          //   color: Colors.teal,
                          //   icon: Icons.menu_book,
                          //   title: 'Subjects',
                          //   ontap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) =>
                          //             const SubjectListScreen(),
                          //       ),
                          //     );
                          //   },
                          // ),
                          _AnimatedDashboardCard(
                            color: Colors.purple,
                            icon: Icons.bar_chart,
                            title: 'Report',
                            ontap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TeacherReportOptionsScreen(
                                    showBackButton: true,
                                  ),
                                ),
                              );
                            },
                          ),

                          // _AnimatedDashboardCard(
                          //   color: Colors.indigo,
                          //   icon: Icons.person,
                          //   title: 'Profile',
                          //   ontap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         // Yahan showBackButton true bhejain
                          //         builder: (context) => TeacherProfileScreen(
                          //           showBackButton: true,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildComplaintsBanner(context),

                      // const SizedBox(height: 16),
                      // ---------------- LOGOUT CARD ----------------
                      // AnimatedLogoutCard(),
                    ],
                      ),
                    ),
                  ),
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: ColoredBox(
                      color: Color(0xffF6F8FB),
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorPallet.primaryBlue, Color(0xFF2A5FB0)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ColorPallet.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const TeacherComplaintsInbox()),
            );
            if (context.mounted) {
              _loadPendingComplaintCount(showLoading: false);
            }
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    if (!_pendingComplaintsLoading &&
                        (_pendingComplaintCount ?? 0) > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorPallet.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complaints Inbox',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _complaintsBannerSubtitle(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One-line status when a session is live; nothing when idle.
class _ActiveSessionCallout extends StatelessWidget {
  final SessionProvider provider;

  const _ActiveSessionCallout({required this.provider});

  @override
  Widget build(BuildContext context) {
    final session = provider.dashboardActiveSession;
    if (session == null || !session.isActive) {
      return const SizedBox.shrink();
    }

    final courseName = provider.courseTitleForSession(session);
    final hasTitle = courseName.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF34A853).withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF34A853),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.25,
                    color: Color(0xFF1A1A1A),
                  ),
                  children: [
                    TextSpan(
                      text: 'Active session',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (hasTitle)
                      TextSpan(
                        text: ' · $courseName',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ANIMATED DASHBOARD CARD ----------------
class _AnimatedDashboardCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String? subtitle; // shown when disabled
  final VoidCallback? ontap;

  const _AnimatedDashboardCard({
    required this.color,
    required this.icon,
    required this.title,
    this.subtitle,
    this.ontap,
  });

  @override
  State<_AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}

class _AnimatedDashboardCardState extends State<_AnimatedDashboardCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.ontap == null;
    final Color effectiveColor =
        disabled ? Colors.grey.shade400 : widget.color;
    final Color shadowColor = Colors.black.withOpacity(0.1);

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel:
          disabled ? null : () => setState(() => _isPressed = false),
      child: InkWell(
        onTap: widget.ontap,
        child: Opacity(
          opacity: disabled ? 0.55 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: _isPressed
                ? (Matrix4.identity()..scale(0.95))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: _isPressed
                  ? effectiveColor.withOpacity(0.2)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: disabled ? 4 : 12,
                  spreadRadius: disabled ? 0 : 2,
                  offset: Offset(0, disabled ? 2 : 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: effectiveColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon,
                          color: effectiveColor, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: disabled
                            ? Colors.grey.shade500
                            : Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (disabled && widget.subtitle != null) ...
                    [
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: disabled ? Colors.grey.shade300 : null,
                        gradient: disabled
                            ? null
                            : LinearGradient(
                                colors: [
                                  effectiveColor.withOpacity(0.5),
                                  effectiveColor,
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                // Lock badge in top-right when disabled
                if (disabled)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- ANIMATED LOGOUT CARD ----------------
class AnimatedLogoutCard extends StatefulWidget {
  const AnimatedLogoutCard({super.key});

  @override
  State<AnimatedLogoutCard> createState() => _AnimatedLogoutCardState();
}

class _AnimatedLogoutCardState extends State<AnimatedLogoutCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color shadowColor = Colors.black.withOpacity(0.1); // same uniform shadow

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        // Logout logic
      },
      child: InkWell(
        onTap: () {
          _showLogoutDialog(context); // Alert dialog open hoga
        },
        child: AnimatedContainer(
          height: 120,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.97))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _isPressed
                ? ColorPallet.primaryBlue.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xffFDECEA),
                child: Icon(Icons.logout, color: ColorPallet.primaryBlue),
              ),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: ColorPallet.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 300), // Animation ki speed
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox
          .shrink(); // pageBuilder lazmi hota hai par hum transitionsBuilder use karenge
    },
    transitionBuilder: (context, anim1, anim2, child) {
      // Scale and Opacity Animation
      return Transform.scale(
        scale: anim1.value, // 0 se 1 tak scale hoga
        child: Opacity(
          opacity: anim1.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 24,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ColorPallet.primaryBlue.withOpacity(0.1),
                  child: Icon(
                    Icons.logout,
                    color: ColorPallet.primaryBlue,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPallet.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final auth = context.read<AuthProvider>();
                          context.read<TeacherProvider>().clear();
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RoleSelectionScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
