import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/account_setting_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/logout_button.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/overview_card_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/profile_screen_header_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/subject_card_widget.dart';
import 'package:facialtrackapp/view/teacher/Complaints/teacher_report_issue_screen.dart';
import 'package:facialtrackapp/view/teacher/Profile/teacher_my_schedule_screen.dart';
import 'package:facialtrackapp/view/teacher/Password%20Changed/change_password_inside_teacher_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherProfileScreen extends StatefulWidget {
  final bool showBackButton;
  const TeacherProfileScreen({super.key, this.showBackButton = false});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the profile if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teacher = context.read<TeacherProvider>();
      if (teacher.teacherProfile == null) {
        teacher.fetchProfile();
      }
      if (teacher.profileSummary == null) {
        teacher.fetchProfileSummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Consumer<TeacherProvider>(
            builder: (context, teacher, _) {
              final profile = teacher.teacherProfile;
              return Column(
                children: [
                  ProfileHeader(
                    showBackButton: widget.showBackButton,
                    name: profile?.fullName ?? 'Loading...',
                    teacherId: profile?.designation != null
                        ? profile!.designation!
                        : profile?.email ?? '—',
                    imagePath: 'assets/profile.png',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildTeacherInfoCard(profile),
                        const SizedBox(height: 20),
                        OverviewCard(
                          subjectsAssignedCount:
                              teacher.profileSummary?.subjectsAssignedCount ?? 0,
                          totalClassesHandled:
                              teacher.profileSummary?.totalClassesHandled ?? 0,
                          activeSessionsCount:
                              teacher.profileSummary?.activeSessionsCount ?? 0,
                        ),
                        const SizedBox(height: 20),
                        SubjectsCard(
                          subjects: teacher.profileSummary?.subjectsAssigned ?? [],
                        ),
                        const SizedBox(height: 20),
                        _buildMyScheduleBox(context),
                        const SizedBox(height: 20),
                        AccountSettingsCard(
                          onChangePasswordTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TeacherSideChangePasswordScreen(),
                              ),
                            );
                          },
                          onReportIssueTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TeacherReportIssueScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        const LogoutButtonWidget(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherInfoCard(UserModel? profile) {
    final email = profile?.email ?? '—';
    final phone = profile?.phoneNumber ?? '—';
    final qualification = profile?.qualification ?? '—';

    return Container(
      width: double.infinity,
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
            'Teacher Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.email_outlined, 'Email', email),
          const SizedBox(height: 10),
          _infoRow(Icons.phone_outlined, 'Phone No', phone),
          const SizedBox(height: 10),
          _infoRow(Icons.school_outlined, 'Qualification', qualification),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildMyScheduleBox(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherMyScheduleScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
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
        child: const Row(
          children: [
            Icon(Icons.schedule_rounded, color: Colors.indigo, size: 28),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Schedule',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to view all assigned schedule slots',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
