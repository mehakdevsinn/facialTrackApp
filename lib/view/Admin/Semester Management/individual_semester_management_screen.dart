import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Admin/Semester%20Management/add_individual_semester_screen.dart';
import 'package:flutter/material.dart';

class IndividualSemesterManagementScreen extends StatefulWidget {
  const IndividualSemesterManagementScreen({super.key});

  @override
  State<IndividualSemesterManagementScreen> createState() =>
      _IndividualSemesterManagementScreenState();
}

class _IndividualSemesterManagementScreenState
    extends State<IndividualSemesterManagementScreen> {
  final List<Map<String, dynamic>> _individualSemesters = [
    {
      "session": "2021-2025",
      "semesterNo": "5",
      "type": "Fall",
      "status": "Active",
      "startDate": "2023-09-01",
      "endDate": "2024-01-15",
    },
    {
      "session": "2022-2026",
      "semesterNo": "3",
      "type": "Fall",
      "status": "Active",
      "startDate": "2023-09-01",
      "endDate": "2024-01-15",
    },
    {
      "session": "2020-2024",
      "semesterNo": "8",
      "type": "Spring",
      "status": "Completed",
      "startDate": "2023-02-01",
      "endDate": "2023-06-15",
    },
  ];

  String _formatDisplayDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _navigateToAddScreen({
    Map<String, dynamic>? semester,
    int? index,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIndividualSemesterScreen(
          semester: semester,
          isEditing: semester != null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (semester != null && index != null) {
          _individualSemesters[index] = result;
        } else {
          _individualSemesters.insert(0, result);
        }
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF10B981);
      case 'Upcoming':
        return const Color(0xFFF59E0B);
      case 'Completed':
        return const Color(0xFF6B7280);
      default:
        return ColorPallet.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            "Semester Management",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Term Records",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Monitor and customize academic timelines for each session independently.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),
              _individualSemesters.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text(
                          "No semesters found",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _individualSemesters.length,
                      itemBuilder: (context, index) {
                        final sem = _individualSemesters[index];
                        final statusColor = _getStatusColor(sem['status']);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _navigateToAddScreen(
                                semester: sem,
                                index: index,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.calendar_today_rounded,
                                            color: statusColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Semester ${sem['semesterNo']}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 18,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              Text(
                                                sem['session'],
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildStatusBadge(
                                          sem['status'],
                                          statusColor,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildQuickInfo(
                                            Icons.auto_awesome_mosaic_rounded,
                                            sem['type'],
                                            "Type",
                                          ),
                                          _buildQuickInfo(
                                            Icons.date_range_rounded,
                                            sem['startDate'].split('-')[0],
                                            "Year",
                                          ),
                                          _buildQuickInfo(
                                            Icons.access_time_filled_rounded,
                                            "4 Months",
                                            "Period",
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.event_note_rounded,
                                          size: 14,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Timeline: ${_formatDisplayDate(sem['startDate'])} - ${_formatDisplayDate(sem['endDate'])}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 16,
                                          color: ColorPallet.primaryBlue,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToAddScreen(),
          backgroundColor: ColorPallet.primaryBlue,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "New Term",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: ColorPallet.primaryBlue.withOpacity(0.6)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: Color(0xFF334155),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
