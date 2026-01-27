import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:facialtrackapp/view/Splash%20Screen/splash_screen.dart';
import 'package:facialtrackapp/view/teacher/Dashborad/subject_screen.dart';
import 'package:facialtrackapp/view/teacher/Dashborad/teacher_dashboard_screen.dart';
import 'package:facialtrackapp/view/teacher/Profile/teacher_profile_screen.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/view_log_screen.dart';
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
      home: TeacherProfileScreen(),
 ); }
}