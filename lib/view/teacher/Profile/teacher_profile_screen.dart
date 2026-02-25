import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/account_setting_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/logout_button.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/overview_card_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/profile_screen_header_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/subject_card_widget.dart';
import 'package:facialtrackapp/view/teacher/Complaints/teacher_report_issue_screen.dart';
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
      if (teacher.teacherProfile == null && !teacher.isLoading) {
        teacher.fetchProfile();
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
                        const OverviewCard(),
                        const SizedBox(height: 20),
                        const SubjectsCard(),
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
}
