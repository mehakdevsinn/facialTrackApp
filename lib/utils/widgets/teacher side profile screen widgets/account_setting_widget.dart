import 'package:flutter/material.dart';

class AccountSettingsCard extends StatelessWidget {
  final VoidCallback onChangePasswordTap;
  final VoidCallback onReportIssueTap;
  final VoidCallback? onMyComplaintsTap;

  const AccountSettingsCard({
    super.key,
    required this.onChangePasswordTap,
    required this.onReportIssueTap,
    this.onMyComplaintsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Account Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_outline, color: Colors.orange),
            ),
            title: const Text(
              "Change Password",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: onChangePasswordTap,
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          if (onMyComplaintsTap != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment_outlined, color: Colors.teal),
              ),
              title: const Text(
                "My complaints",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                "Reports you sent to administration",
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: onMyComplaintsTap,
            ),
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bug_report_outlined, color: Colors.blue),
            ),
            title: const Text(
              "Report Issue",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: onReportIssueTap,
          ),
        ],
      ),
    );
  }
}
