import 'package:facialtrackapp/constants/color_pallet.dart';
import 'user_approval_detail_screen.dart';
import 'package:facialtrackapp/view/Admin/admin_root_screen.dart';
import 'package:flutter/material.dart';

class ApprovableUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'Student' or 'Teacher'
  final String department;
  String status; // 'Pending', 'Approved', 'Rejected'

  // Student specific fields
  final String? rollNo;
  final String? semester;

  // Teacher specific fields
  final String? qualification;

  ApprovableUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.status,
    this.rollNo,
    this.semester,
    this.qualification,
  });
}

class UserApprovalScreen extends StatefulWidget {
  final bool showBackButton;
  const UserApprovalScreen({super.key, this.showBackButton = true});

  @override
  State<UserApprovalScreen> createState() => _UserApprovalScreenState();
}

class _UserApprovalScreenState extends State<UserApprovalScreen> {
  final List<ApprovableUser> _allUsers = [
    // Students
    ApprovableUser(
      id: 'S1',
      name: 'Ahmed Khan',
      email: 'ahmed.k@student.com',
      role: 'Student',
      department: 'Computer Science',
      semester: '5th',
      rollNo: 'F21-CS-101',
      status: 'Pending',
    ),
    ApprovableUser(
      id: 'S2',
      name: 'Sara Ali',
      email: 'sara.a@student.com',
      role: 'Student',
      department: 'Software Engineering',
      semester: '3rd',
      rollNo: 'F22-SE-045',
      status: 'Pending',
    ),
    ApprovableUser(
      id: 'S3',
      name: 'Zainab Bibi',
      email: 'zainab.b@student.com',
      role: 'Student',
      department: 'Data Science',
      semester: '7th',
      rollNo: 'F20-DS-012',
      status: 'Approved',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleStatusUpdate(ApprovableUser user, String newStatus) {
    setState(() {
      user.status = newStatus;
    });

    final color = newStatus == 'Approved' ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} has been $newStatus'),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: ColorPallet.primaryBlue,
          elevation: 4,
          shadowColor: Colors.black26,
          automaticallyImplyLeading: widget.showBackButton,
          leading: widget.showBackButton
              ? IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminRootScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              : null,
          title: const Text(
            "Student Approvals",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Action Required",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Empower the next generation by verifying their academic journey.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildList(
                users: _allUsers.where((u) => u.role == 'Student').toList()
                  ..sort((a, b) => a.status == 'Pending' ? -1 : 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required List<ApprovableUser> users,
    bool isTeacherTab = false,
  }) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 15),
            Text(
              "No verification requests",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user, isTeacherTab);
      },
    );
  }

  Widget _buildUserCard(ApprovableUser user, bool isTeacherTab) {
    bool isPending = user.status == 'Pending';

    return InkWell(
      onTap: () => _showUserDetails(user),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 6, color: _getStatusColor(user.status)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: ColorPallet.primaryBlue
                                  .withOpacity(0.1),
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: ColorPallet.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(user.status),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                Icons.badge_outlined,
                                "Roll No",
                                user.rollNo ?? "N/A",
                              ),
                            ),
                            Expanded(
                              child: _buildInfoRow(
                                Icons.calendar_today_outlined,
                                "Semester",
                                user.semester ?? "N/A",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.business_outlined,
                          "Department",
                          user.department,
                        ),
                        if (isPending) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  label: "View Details",
                                  color: Colors.grey[100]!,
                                  textColor: Colors.black87,
                                  onTap: () => _showUserDetails(user),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () =>
                                    _handleStatusUpdate(user, 'Approved'),
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 30,
                                ),
                                tooltip: 'Approve',
                              ),
                              IconButton(
                                onPressed: () =>
                                    _handleStatusUpdate(user, 'Rejected'),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                tooltip: 'Reject',
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _showUserDetails(user),
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 18,
                              ),
                              label: const Text("View Full Profile"),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ColorPallet.primaryBlue.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showUserDetails(ApprovableUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserApprovalDetailScreen(
          user: user,
          onStatusUpdate: (newStatus) => _handleStatusUpdate(user, newStatus),
        ),
      ),
    );
  }
}
