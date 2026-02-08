import 'package:facialtrackapp/view/Admin/Manage%20Teachers/manage-teachers.dart';
import 'package:facialtrackapp/view/Admin/Student%20Enrollment/student-enrollment-face.dart';
import 'package:facialtrackapp/view/Admin/admin_root_screen.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/Splash%20Screen/splash_screen.dart';
import 'package:facialtrackapp/view/Student/Student%20NavBar/student-root_screen.dart';
import 'package:facialtrackapp/view/teacher/Dashborad/teacher_dashboard_screen.dart';
import 'package:facialtrackapp/view/teacher/Report/daily_report_selection.dart';
import 'package:facialtrackapp/view/teacher/Teacher_NavBar/teacher_root_screen.dart';
import 'package:facialtrackapp/view/Admin/Student%20Enrollment/student-enrollment-info.dart';
import 'package:facialtrackapp/view/Splash%20Screen/splash_screen.dart';
import 'package:facialtrackapp/view/Student/Student%20NavBar/student-root_screen.dart';
import 'package:facialtrackapp/view/student/Student%20Login/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          // FaceEnrollmentScreen(),
          // StudentLoginScreen(),
          // StudentEnrollmentScreen(),
          SplashScreen(),
      // ManageTeachersScreen(),
    );
  }
}
