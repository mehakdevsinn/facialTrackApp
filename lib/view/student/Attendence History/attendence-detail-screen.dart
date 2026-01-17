import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final String date;
  final String day;
  final String? entry;
  final String? exit;
  final String subject;
  final bool present;

  const AttendanceDetailScreen({
    super.key,
    required this.date,
    required this.day,
    this.entry,
    this.exit,
    required this.subject,
    required this.present,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3F3),
      appBar: AppBar(
        backgroundColor: ColorPallet.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorPallet.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Attendance Detail",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              date,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: present ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    present ? Icons.check_circle : Icons.cancel,
                    size: 40,
                    color: present ? Colors.green : Colors.red,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    present ? "Present" : "Absent",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: present ? Colors.green : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    present ? "Status Verified" : "Status Not Verified",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (present) _timeLogsCard(),

            const SizedBox(height: 16),

            _sessionInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _timeLogsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TIME LOGS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.login, "Entry Time", entry ?? "--"),
          const SizedBox(height: 8),
          _infoRow(Icons.logout, "Exit Time", exit ?? "--"),
        ],
      ),
    );
  }

  Widget _sessionInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SESSION INFO",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.book, "Subject", subject),
          const SizedBox(height: 8),
          _infoRow(
            Icons.schedule,
            "Session",
            "${entry ?? '--'} - ${exit ?? '--'}",
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, [String? value]) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ${value ?? ''}", style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(2, 2),
        ),
      ],
    );
  }
}
