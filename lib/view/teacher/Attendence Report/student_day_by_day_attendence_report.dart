import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayByDayReportScreen extends StatelessWidget {
  final String studentName;
  final DateTime? startDate;
  final DateTime? endDate;

  const DayByDayReportScreen({super.key, required this.studentName, this.startDate, this.endDate});

  @override
  Widget build(BuildContext context) {
    // Updated Dummy Data with Leave & Reason
    final List<Map<String, dynamic>> attendanceData = [
      {"date": "2026-01-28", "status": "Present", "time": "09:05 AM", "reason": ""},
      {"date": "2026-01-27", "status": "Leave", "time": "-", "reason": "Severe fever and flu"},
      {"date": "2026-01-26", "status": "Absent", "time": "-", "reason": ""},
      {"date": "2026-01-25", "status": "Sunday", "time": "-", "reason": ""},
      {"date": "2026-01-24", "status": "Leave", "time": "-", "reason": "Sister's wedding ceremony"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        title: Text("$studentName History"),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Range Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Text(
              "Logs: ${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM').format(endDate!)}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13),
            ),
          ),
          
          // Table Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: attendanceData.length,
              itemBuilder: (context, index) {
                var record = attendanceData[index];
                String status = record['status'];
                bool isLeave = status == "Leave";
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      // Main Row (Table Style)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        child: Row(
                          children: [
                            // Date Column
                            SizedBox(
                              width: 80,
                              child: Text(
                                DateFormat('dd MMM').format(DateTime.parse(record['date'])),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            // Time/Check-in Column
                            Expanded(
                              child: Text(
                                status == "Sunday" ? "Weekend" : "In: ${record['time']}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ),
                            // Status Badge
                            _buildStatusBadge(status),
                          ],
                        ),
                      ),
                      
                      // Reason Section (Sirf tab dikhayen jab status 'Leave' ho)
                      if (isLeave && record['reason'].isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Reason: ${record['reason']}",
                                  style: const TextStyle(
                                    fontSize: 12, 
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Status Badge Helper
  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  // Color Logic Helper
  Color _getStatusColor(String status) {
    switch (status) {
      case "Present": return Colors.green;
      case "Absent": return Colors.red;
      case "Leave": return Colors.orange;
      case "Sunday": return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}