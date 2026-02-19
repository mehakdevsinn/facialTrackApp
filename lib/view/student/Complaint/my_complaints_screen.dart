import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/global_complaints.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  // Access globalComplaints directly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Complaints",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: globalComplaints.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: globalComplaints.length,
              itemBuilder: (context, index) {
                return _buildComplaintCard(globalComplaints[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No complaints found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Any issues you report will appear here.",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final bool isAttendance = complaint['type'] == 'Attendance';
    final DateTime date = complaint['submissionDate'] as DateTime;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            // offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  complaint['type'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: isAttendance ? Colors.orange : Colors.purple,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              _buildStatusChip(complaint['status']),
            ],
          ),
          const SizedBox(height: 12),
          if (isAttendance) ...[
            Text(
              "${complaint['course']} - ${complaint['issueType']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Date: ${DateFormat('MMM dd, yyyy').format(complaint['classDate'])}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ] else ...[
            Text(
              complaint['category'] ?? "General Issue",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            complaint['description'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          const Divider(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Submitted: ${DateFormat('MMM dd, hh:mm a').format(date)}",
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case "Pending":
        color = Colors.amber;
        break;
      case "Resolved":
        color = Colors.green;
        break;
      case "Rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.grey; // Default color for unknown status
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
