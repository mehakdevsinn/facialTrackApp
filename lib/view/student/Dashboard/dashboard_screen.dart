import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/auth_provider.dart';
import 'package:facialtrackapp/controller/providers/student_provider.dart';
import 'package:facialtrackapp/utils/widgets/dashboard-widgets.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/student/Profile/student-profile-screen.dart';
import 'package:flutter/material.dart';
import 'package:facialtrackapp/view/student/Dashboard/today_sessions_screen.dart';
import 'package:facialtrackapp/view/student/Dashboard/monthly_attendance_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final now = DateTime.now();
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(now);
    final isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.fullName ?? 'Student', isWeekend),
              // _buildQuickActions(),
              // const SizedBox(height: 8),

              // SEPARATE CARDS - Weekday/Weekend conditional
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isWeekend
                    ? _buildWeekendCard(date: dateStr)
                    : _buildCurrentClassCard(
                        date: dateStr,
                        subject: "Mathematics",
                        teacher: "Prof. Ayesha",
                        room: "Room 201, B Block",
                        sessionStart: "10:00 AM",
                        presentAt: "10:05 AM",
                        nextClass: "11:00 AM",
                        isPresent: true,
                      ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMonthlyStatsCard(),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTodaySessionsCard(sessions: _getTodaySessions()),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildAlertsCard(alerts: _getAlerts()),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(String name, bool isWeekend) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPallet.primaryBlue,
            const Color(0xFF3B82F6),
            const Color(0xFF6366F1)
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getGreeting(),
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          const Text("Dashboard",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          // _buildNotificationButton(),
                          const SizedBox(width: 12),
                          _buildProfileChip(name),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildScheduleBadge(isWeekend),
                ],
              ),
            ),
            _buildWaveDecoration(),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildNotificationButton() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white24, borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 22),
                Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Color(0xFFEF4444), shape: BoxShape.circle))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleBadge(bool isWeekend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isWeekend ? Icons.weekend : Icons.calendar_today,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(isWeekend ? 'Weekend Schedule' : 'Weekday Schedule',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildWaveDecoration() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28))),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        child: CustomPaint(
            size: const Size(double.infinity, 40), painter: WavePainter()),
      ),
    );
  }

  Widget _buildProfileChip(String name) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 1) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const StudentProfileScreen(showBackButton: true)));
        } else if (value == 2) {
          _showLogoutDialog(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white24, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.person,
                    size: 16, color: ColorPallet.primaryBlue)),
            const SizedBox(width: 8),
            Text(name.split(' ').first,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 1,
            child: Row(children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('View Profile')
            ])),
        const PopupMenuItem(
            value: 2,
            child: Row(children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.red))
            ])),
      ],
    );
  }

  // QUICK ACTIONS
  // Widget _buildQuickActions() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Row(
  //       children: [
  //         Expanded(
  //             child: _quickActionCard(
  //                 icon: Icons.book_outlined,
  //                 label: 'My Courses',
  //                 color: const Color(0xFF3B82F6),
  //                 onTap: () {})),
  //         const SizedBox(width: 12),
  //         Expanded(
  //             child: _quickActionCard(
  //                 icon: Icons.calendar_month_outlined,
  //                 label: 'Timetable',
  //                 color: const Color(0xFF8B5CF6),
  //                 onTap: () {})),
  //         const SizedBox(width: 12),
  //         Expanded(
  //             child: _quickActionCard(
  //                 icon: Icons.assignment_outlined,
  //                 label: 'Reports',
  //                 color: const Color(0xFF10B981),
  //                 onTap: () {})),
  //       ],
  //     ),
  //   );
  // }

  Widget _quickActionCard(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }

  // SEPARATE CARDS
  Widget _buildCurrentClassCard({
    required String date,
    required String subject,
    required String teacher,
    required String room,
    required String sessionStart,
    required String presentAt,
    required String nextClass,
    required bool isPresent,
  }) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: isPresent
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isPresent ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: isPresent
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626)),
                    const SizedBox(width: 4),
                    Text(isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPresent
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 3,
                  height: 50,
                  decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CURRENT CLASS',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(subject,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937))),
                    const SizedBox(height: 2),
                    Text('$teacher · $room',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _timelineItem('Session start', sessionStart, true),
              Expanded(
                  child: Container(
                      height: 1,
                      color: const Color(0xFFE5E7EB),
                      margin: const EdgeInsets.symmetric(horizontal: 8))),
              _timelineItem('Present at', presentAt, true),
              Expanded(
                  child: Container(
                      height: 1,
                      color: const Color(0xFFE5E7EB),
                      margin: const EdgeInsets.symmetric(horizontal: 8))),
              _timelineItem('Next class', nextClass, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendCard({required String date}) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.weekend, size: 14, color: Color(0xFF4F46E5)),
                    SizedBox(width: 4),
                    Text('Weekend',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7), shape: BoxShape.circle),
                  child: const Icon(Icons.wb_sunny,
                      color: Color(0xFFF59E0B), size: 32),
                ),
                const SizedBox(height: 16),
                const Text('No classes today',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937))),
                const SizedBox(height: 8),
                Text('Attendance not required. Next class Mon, Dec 15',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsCard() {
    final subjects = [
      SubjectStat(
          code: 'CS',
          name: 'Computer Science',
          percentage: 92,
          present: 22,
          absent: 2,
          color: const Color(0xFF6366F1)),
      SubjectStat(
          code: 'MA',
          name: 'Mathematics',
          percentage: 89,
          present: 18,
          absent: 2,
          color: const Color(0xFF8B5CF6)),
      SubjectStat(
          code: 'CH',
          name: 'Chemistry',
          percentage: 78,
          present: 14,
          absent: 4,
          color: const Color(0xFF3B82F6)),
      SubjectStat(
          code: 'UR',
          name: 'Urdu',
          percentage: 85,
          present: 17,
          absent: 3,
          color: const Color(0xFF10B981)),
      SubjectStat(
          code: 'PH',
          name: 'Physics',
          percentage: 65,
          present: 9,
          absent: 7,
          color: const Color(0xFFEF4444),
          isAtRisk: true),
    ];

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THIS MONTH - DECEMBER',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('82%',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937))),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_upward,
                  color: Color(0xFF10B981), size: 20),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MonthlyAttendanceScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('VIEW ALL',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5))),
                  ),
                  const Text('Overall: 5 subjects',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  const Text('December 2025',
                      style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...subjects.map((s) => _subjectProgressRow(s)),
        ],
      ),
    );
  }

  Widget _buildTodaySessionsCard({required List<SessionItem> sessions}) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TODAY'S SESSIONS",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5)),
              Text('${sessions.length} TOTAL',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 12),
          ...sessions.map((session) => _compactSessionItem(session)),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TodaySessionsScreen(),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View all',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      size: 12, color: Color(0xFF4F46E5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard({required List<AlertItem> alerts}) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ALERTS & NOTICES',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...alerts.map((alert) => _compactAlertItem(alert)),
        ],
      ),
    );
  }

  // HELPERS
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
    );
  }

  Widget _timelineItem(String label, String time, bool isActive) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF))),
        const SizedBox(height: 4),
        Text(time,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF9CA3AF))),
      ],
    );
  }

  Widget _compactSessionItem(SessionItem session) {
    String statusText;
    Color statusBgColor;
    Color statusTextColor;

    switch (session.status) {
      case SessionStatus.present:
        statusText = 'Present';
        statusBgColor = const Color(0xFFD1FAE5);
        statusTextColor = const Color(0xFF059669);
        break;
      case SessionStatus.upcoming:
        statusText = 'Upcoming';
        statusBgColor = const Color(0xFFE0E7FF);
        statusTextColor = const Color(0xFF4F46E5);
        break;
      case SessionStatus.breakTime:
        statusText = 'Break';
        statusBgColor = const Color(0xFFF3F4F6);
        statusTextColor = const Color(0xFF6B7280);
        break;
      case SessionStatus.absent:
        statusText = 'Absent';
        statusBgColor = const Color(0xFFFEE2E2);
        statusTextColor = const Color(0xFFDC2626);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: session.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(session.code,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: session.color))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.subject,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937))),
                Text(session.time,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: statusBgColor, borderRadius: BorderRadius.circular(20)),
            child: Text(statusText,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusTextColor)),
          ),
        ],
      ),
    );
  }

  Widget _compactAlertItem(AlertItem alert) {
    Color iconColor;
    IconData iconData;

    switch (alert.type) {
      case AlertType.danger:
        iconColor = const Color(0xFFEF4444);
        iconData = Icons.error;
        break;
      case AlertType.warning:
        iconColor = const Color(0xFFF59E0B);
        iconData = Icons.warning_amber;
        break;
      case AlertType.success:
        iconColor = const Color(0xFF10B981);
        iconData = Icons.check_circle;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937))),
                const SizedBox(height: 2),
                Text(alert.subtitle,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<SessionItem> _getTodaySessions() {
    return [
      SessionItem(
          subject: "Physics",
          code: "PH",
          time: "09:00 - 09:45 AM",
          status: SessionStatus.present,
          color: const Color(0xFF10B981)),
      SessionItem(
          subject: "Mathematics",
          code: "MA",
          time: "10:00 - 10:45 AM",
          status: SessionStatus.present,
          color: const Color(0xFF3B82F6)),
      SessionItem(
          subject: "Science",
          code: "SC",
          time: "11:00 - 11:45 AM",
          status: SessionStatus.upcoming,
          color: const Color(0xFF8B5CF6)),
      SessionItem(
          subject: "Lunch Break",
          code: "LB",
          time: "12:00 - 12:45 PM",
          status: SessionStatus.breakTime,
          color: const Color(0xFF6B7280)),
    ];
  }

  List<AlertItem> _getAlerts() {
    return [
      AlertItem(
          title: "Physics at 65% - shortage risk. Need 75% minimum.",
          subtitle: "Today",
          type: AlertType.danger),
      AlertItem(
          title: "Chemistry rescheduled to 3:00 PM tomorrow",
          subtitle: "Yesterday",
          type: AlertType.warning),
      AlertItem(
          title: "Semester report ready - download from Profile",
          subtitle: "2 days ago",
          type: AlertType.success),
    ];
  }

  void _showLogoutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: ColorPallet.primaryBlue.withOpacity(0.1),
                      child: Icon(Icons.logout,
                          color: ColorPallet.primaryBlue, size: 30)),
                  const SizedBox(height: 20),
                  Text("Logout",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: ColorPallet.black)),
                  const SizedBox(height: 10),
                  const Text("Are you sure you want to logout?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("No",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPallet.primaryBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () async {
                            final auth = context.read<AuthProvider>();
                            context.read<StudentProvider>().clear();
                            await auth.logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const RoleSelectionScreen()),
                                  (route) => false);
                            }
                          },
                          child: const Text("Yes",
                              style: TextStyle(color: Colors.white)),
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

  Widget _subjectProgressRow(SubjectStat s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: s.color.withOpacity(0.15), shape: BoxShape.circle),
            child: Center(
                child: Text(s.code,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: s.color))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937))),
                    Text('${s.percentage}%',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: s.color)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: s.percentage / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(s.color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${s.present} present',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF6B7280))),
                    const SizedBox(width: 8),
                    Text('${s.absent} absent',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF6B7280))),
                    if (s.isAtRisk) ...[
                      const SizedBox(width: 8),
                      const Text('At risk',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectStat {
  final String code;
  final String name;
  final int percentage;
  final int present;
  final int absent;
  final Color color;
  final bool isAtRisk;

  SubjectStat({
    required this.code,
    required this.name,
    required this.percentage,
    required this.present,
    required this.absent,
    required this.color,
    this.isAtRisk = false,
  });
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF8F9FA)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8,
        size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.2, size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
