import 'package:flutter/material.dart';
import 'package:facialtrackapp/view/student/Dashboard/monthly_attendance_screen.dart';

class SubjectSessionsHistoryScreen extends StatelessWidget {
  final SubjectAttendanceData subject;

  const SubjectSessionsHistoryScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sessions = _generateMockSessions(subject);

    return Scaffold(
      backgroundColor: const Color(0xFF2304AA), // primaryBlue
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${subject.title} Sessions",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Header Info for Subject
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                children: [
                   Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: subject.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        subject.code,
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
                          "${subject.percentage.toInt()}% Attendance",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${subject.present} Present • ${subject.absent} Absent • ${subject.leave} Leave",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Body Area (List of Sessions)
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    Color statusColor;
                    if (session['status'] == 'Present') {
                      statusColor = const Color(0xFF10B981);
                    } else if (session['status'] == 'Absent') {
                      statusColor = const Color(0xFFEF4444);
                    } else {
                      statusColor = const Color(0xFFF59E0B);
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  session['status'] == 'Present' 
                                      ? Icons.check 
                                      : (session['status'] == 'Absent' ? Icons.close : Icons.remove_circle_outline),
                                  color: statusColor,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session['date'], // e.g. "Dec 10, Wed"
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    session['time'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              session['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateMockSessions(SubjectAttendanceData data) {
    List<Map<String, dynamic>> realisticList = [];
    DateTime dateCounter = DateTime(2025, 12, 25); // Start backwards from a mock present date
    
    List<String> statuses = [];
    for(int i=0; i<data.present; i++) statuses.add("Present");
    for(int i=0; i<data.absent; i++) statuses.add("Absent");
    for(int i=0; i<data.leave; i++) statuses.add("Leave");
    
    // Shuffle the statuses to make the history look realistic
    statuses.shuffle();
    
    for (int i = 0; i < data.totalClasses; i++) {
        // Skip weekends for more realism
        if (dateCounter.weekday == DateTime.saturday) {
          dateCounter = dateCounter.subtract(const Duration(days: 1));
        } else if (dateCounter.weekday == DateTime.sunday) {
          dateCounter = dateCounter.subtract(const Duration(days: 2));
        }

        realisticList.add({
            "date": _formatDate(dateCounter),
            "time": "09:00 - 10:30 AM",
            "status": statuses[i],
        });
        dateCounter = dateCounter.subtract(const Duration(days: 2)); // Assume classes are every 2 days
    }
    
    return realisticList;
  }

  String _formatDate(DateTime date) {
    List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    
    String month = months[date.month - 1];
    String day = days[date.weekday - 1];
    
    return "$month ${date.day.toString().padLeft(2, '0')}, $day";
  }
}
