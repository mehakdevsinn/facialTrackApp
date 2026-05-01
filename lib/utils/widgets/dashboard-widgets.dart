import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

// ========== CURRENT CLASS CARD ==========
Widget currentClassCard({
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
    padding: const EdgeInsets.all(16),
    decoration: _modernCardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and Present status row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPresent ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPresent ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPresent ? 'Present' : 'Absent',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current Class section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT CLASS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$teacher · $room',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Timeline
        Row(
          children: [
            _timelineItem('Session start', sessionStart, true),
            Expanded(
              child: Container(
                height: 1,
                color: const Color(0xFFE5E7EB),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            _timelineItem('Present at', presentAt, true),
            Expanded(
              child: Container(
                height: 1,
                color: const Color(0xFFE5E7EB),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            _timelineItem('Next class', nextClass, false),
          ],
        ),
      ],
    ),
  );
}

Widget _timelineItem(String label, String time, bool isActive) {
  return Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isActive ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        time,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isActive ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
        ),
      ),
    ],
  );
}

// ========== MONTHLY STATS SECTION ==========
Widget monthlyStatsSection({
  required int percentage,
  required int attended,
  required int total,
  required int totalClasses,
  required int present,
  required int absent,
  required int onLeave,
  required String bestSubject,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'THIS MONTH - DECEMBER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$attended/$total classes',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // Percentage with arrow
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_upward,
            color: Color(0xFF10B981),
            size: 20,
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Stats grid
      Row(
        children: [
          Expanded(child: _statCard('$totalClasses', 'Total classes', const Color(0xFFDBEAFE), const Color(0xFF3B82F6))),
          const SizedBox(width: 8),
          Expanded(child: _statCard('$present', 'Present', const Color(0xFFD1FAE5), const Color(0xFF10B981))),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _statCard('$absent', 'Absent', const Color(0xFFFEE2E2), const Color(0xFFEF4444))),
          const SizedBox(width: 8),
          Expanded(child: _statCard('$onLeave', 'On leave', const Color(0xFFFEF3C7), const Color(0xFFF59E0B))),
        ],
      ),
      const SizedBox(height: 12),

      // Best subject
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF9C3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFEAB308), size: 18),
            const SizedBox(width: 8),
            Text(
              'Best subject this month: $bestSubject',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFA16207),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _statCard(String value, String label, Color bgColor, Color textColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.8),
          ),
        ),
      ],
    ),
  );
}

// ========== TODAY'S SESSIONS SECTION ==========
Widget todaySessionsSection({required List<SessionItem> sessions}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "TODAY'S SESSIONS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            '${sessions.length} TOTAL',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...sessions.map((session) => _sessionItem(session)).toList(),
      const SizedBox(height: 8),
      Center(
        child: TextButton(
          onPressed: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View all 6 sessions',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF4F46E5)),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _sessionItem(SessionItem session) {
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
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: _modernCardDecoration(),
    child: Row(
      children: [
        // Subject icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: session.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              session.code,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: session.color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Subject info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.subject,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                session.time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusTextColor,
            ),
          ),
        ),
      ],
    ),
  );
}

// ========== ALERTS SECTION ==========
Widget alertsSection({required List<AlertItem> alerts}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'ALERTS & NOTICES',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 12),
      ...alerts.map((alert) => _alertItem(alert)).toList(),
    ],
  );
}

Widget _alertItem(AlertItem alert) {
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
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: _modernCardDecoration(),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(iconData, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                alert.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ========== COMMON DECORATION ==========
BoxDecoration _modernCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

// ========== DATA CLASSES ==========
class SessionItem {
  final String subject;
  final String code;
  final String time;
  final SessionStatus status;
  final Color color;

  SessionItem({
    required this.subject,
    required this.code,
    required this.time,
    required this.status,
    required this.color,
  });
}

enum SessionStatus { present, upcoming, breakTime, absent }

class AlertItem {
  final String title;
  final String subtitle;
  final AlertType type;

  AlertItem({
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

enum AlertType { danger, warning, success }
