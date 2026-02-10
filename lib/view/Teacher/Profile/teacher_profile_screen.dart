import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/account_setting_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/logout_button.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/overview_card_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/profile_screen_header_widget.dart';
import 'package:facialtrackapp/utils/widgets/teacher%20side%20profile%20screen%20widgets/subject_card_widget.dart';
import 'package:facialtrackapp/view/teacher/Password%20Changed/change_password_inside_teacher_profile.dart';
import 'package:facialtrackapp/view/teacher/Password%20Changed/change_password_inside_teacher_profile.dart'
    hide TeacherSideChangePasswordScreen;
import 'package:facialtrackapp/view/teacher/Complaints/teacher_report_issue_screen.dart';
import 'package:flutter/material.dart';

class TeacherProfileScreen extends StatelessWidget {
  final bool showBackButton;
  const TeacherProfileScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(
                showBackButton: showBackButton,
                name: "Dr. Saima Kamran",
                teacherId: "ID: TCH-2025-014",
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
                            builder: (_) => TeacherSideChangePasswordScreen(),
                          ),
                        );
                      },
                      onReportIssueTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TeacherReportIssueScreen(),
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
          ),
        ),
      ),
    );
  }
}
