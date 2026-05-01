import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionData {
  final String iconData;
  final Color iconBgColor;
  final String title;
  final String time;
  final String status;
  final String? attendanceText;
  final String? upcomingNotice;

  SessionData({
    required this.iconData,
    required this.iconBgColor,
    required this.title,
    required this.time,
    required this.status,
    this.attendanceText,
    this.upcomingNotice,
  });
}

class TodaySessionsScreen extends StatefulWidget {
  const TodaySessionsScreen({super.key});

  @override
  State<TodaySessionsScreen> createState() => _TodaySessionsScreenState();
}

class _TodaySessionsScreenState extends State<TodaySessionsScreen> {
  late DateTime _selectedDate;
  late List<SessionData> _sessions;

  @override
  void initState() {
    super.initState();
    // Default mock date as in the design or just today
    _selectedDate = DateTime.now();
    _loadSessionsForDate(_selectedDate);
  }

  void _loadSessionsForDate(DateTime date) {
    bool isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    if (isToday) {
      _sessions = [
        SessionData(
            iconData: "PH",
            iconBgColor: const Color(0xFF059669),
            title: "Physics",
            time: "09:00 AM – 09:45 AM",
            status: "Present",
            attendanceText: "Attendance marked at 09:10 AM"),
        SessionData(
            iconData: "MA",
            iconBgColor: const Color(0xFF2304AA),
            title: "Mathematics",
            time: "10:00 AM – 10:45 AM",
            status: "Present",
            attendanceText: "Attendance marked at 10:05 AM"),
        SessionData(
            iconData: "SC",
            iconBgColor: const Color(0xFF8B5CF6),
            title: "Science",
            time: "11:00 AM – 11:45 AM",
            status: "Upcoming",
            upcomingNotice: "Starts in 15 minutes — be ready"),
        SessionData(
            iconData: "LB",
            iconBgColor: const Color(0xFF9CA3AF),
            title: "Lunch Break",
            time: "12:00 PM – 12:45 PM",
            status: "Break"),
        SessionData(
            iconData: "EN",
            iconBgColor: const Color(0xFFEA580C),
            title: "English",
            time: "01:00 PM – 01:45 PM",
            status: "Upcoming"),
        SessionData(
            iconData: "CS",
            iconBgColor: const Color(0xFF6366F1),
            title: "Computer Science",
            time: "02:00 PM – 02:45 PM",
            status: "Upcoming"),
        SessionData(
            iconData: "UR",
            iconBgColor: const Color(0xFF0D9488),
            title: "Urdu",
            time: "03:00 PM – 03:45 PM",
            status: "Upcoming"),
      ];
    } else {
      bool isPast = date.isBefore(DateTime.now());
      _sessions = [
        SessionData(
            iconData: "EN",
            iconBgColor: const Color(0xFFEA580C),
            title: "English",
            time: "09:00 AM – 09:45 AM",
            status: isPast ? "Present" : "Upcoming",
            attendanceText: isPast ? "Attendance marked at 09:05 AM" : null),
        SessionData(
            iconData: "CH",
            iconBgColor: const Color(0xFFEAB308),
            title: "Chemistry",
            time: "10:00 AM – 10:45 AM",
            status: isPast ? "Absent" : "Upcoming"),
        SessionData(
            iconData: "LB",
            iconBgColor: const Color(0xFF9CA3AF),
            title: "Lunch Break",
            time: "11:00 AM – 11:45 AM",
            status: "Break"),
        SessionData(
            iconData: "PH",
            iconBgColor: const Color(0xFF059669),
            title: "Physics",
            time: "12:00 PM – 12:45 PM",
            status: isPast ? "Present" : "Upcoming",
            attendanceText: isPast ? "Attendance marked at 12:01 PM" : null),
      ];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2304AA), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadSessionsForDate(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int doneCount = _sessions
        .where((s) => s.status == 'Present' || s.status == 'Absent')
        .length;
    int totalCount = _sessions.length;
    int upcomingCount = _sessions.where((s) => s.status == 'Upcoming').length;
    double progress = totalCount > 0 ? doneCount / totalCount : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF2304AA), // primaryBlue
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedDate.day == DateTime.now().day &&
                              _selectedDate.month == DateTime.now().month
                          ? "Today's Sessions"
                          : "Sessions",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Main Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Summary Card
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month,
                                    color: Color(0xFF4F46E5),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, MMM d')
                                            .format(_selectedDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Total $totalCount Sessions",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _selectedDate
                                                .isBefore(DateTime.now()) ||
                                            (_selectedDate.day ==
                                                    DateTime.now().day &&
                                                _selectedDate.month ==
                                                    DateTime.now().month)
                                        ? const Color(0xFFD1FAE5)
                                        : const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                          _selectedDate.isBefore(
                                                      DateTime.now()) ||
                                                  (_selectedDate.day ==
                                                          DateTime.now().day &&
                                                      _selectedDate.month ==
                                                          DateTime.now().month)
                                              ? Icons.check
                                              : Icons.calendar_today,
                                          size: 14,
                                          color: _selectedDate.isBefore(
                                                      DateTime.now()) ||
                                                  (_selectedDate.day ==
                                                          DateTime.now().day &&
                                                      _selectedDate.month ==
                                                          DateTime.now().month)
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF4F46E5)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _selectedDate
                                                    .isBefore(DateTime.now()) ||
                                                (_selectedDate.day ==
                                                        DateTime.now().day &&
                                                    _selectedDate.month ==
                                                        DateTime.now().month)
                                            ? "Present"
                                            : "Upcoming",
                                        style: TextStyle(
                                          color: _selectedDate.isBefore(
                                                      DateTime.now()) ||
                                                  (_selectedDate.day ==
                                                          DateTime.now().day &&
                                                      _selectedDate.month ==
                                                          DateTime.now().month)
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF4F46E5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Progress Bar
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 6,
                              width:
                                  MediaQuery.of(context).size.width * progress,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$doneCount of $totalCount done",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "$upcomingCount upcoming",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Sessions List
                        ..._sessions.map((session) => _buildSessionCard(
                              iconData: session.iconData,
                              iconBgColor: session.iconBgColor,
                              title: session.title,
                              time: session.time,
                              status: session.status,
                              attendanceText: session.attendanceText,
                              upcomingNotice: session.upcomingNotice,
                            )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required String iconData,
    required Color iconBgColor,
    required String title,
    required String time,
    required String status,
    String? attendanceText,
    String? upcomingNotice,
  }) {
    Color statusBgColor;
    Color statusTextColor;
    IconData? statusIcon;

    if (status == "Present") {
      statusBgColor = const Color(0xFFD1FAE5);
      statusTextColor = const Color(0xFF059669);
      statusIcon = Icons.check;
    } else if (status == "Upcoming") {
      statusBgColor = const Color(0xFFEEF2FF);
      statusTextColor = const Color(0xFF4F46E5);
      statusIcon = Icons.remove_circle_outline;
    } else if (status == "Absent") {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
      statusIcon = Icons.close;
    } else {
      statusBgColor = const Color(0xFFF3F4F6);
      statusTextColor = const Color(0xFF6B7280);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    iconData,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (statusIcon != null) ...[
                      Icon(statusIcon, size: 14, color: statusTextColor),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      status,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (attendanceText != null || upcomingNotice != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 64),
                Icon(
                  Icons.circle,
                  size: 6,
                  color: attendanceText != null
                      ? const Color(0xFF059669)
                      : Colors.transparent,
                ),
                if (attendanceText != null) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    attendanceText ?? upcomingNotice!,
                    style: TextStyle(
                      fontSize: 12,
                      color: attendanceText != null
                          ? const Color(0xFF059669)
                          : const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
