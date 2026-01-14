import 'package:facialtrackapp/view/navbar/student-root_screen.dart';
import 'package:facialtrackapp/view/student/attendence-history-screen.dart';
import 'package:facialtrackapp/view/student/dashboard-screeen.dart';
import 'package:facialtrackapp/view/student/login.dart';
import 'package:facialtrackapp/view/teacher/login.dart';
import 'package:facialtrackapp/view/Splash%20Screen/splash_screen.dart';
import 'package:facialtrackapp/view/Teacher/Dashborad/teacher_dashboard_screen.dart';
import 'package:facialtrackapp/view/Teacher/Root%20Screen/root_screen.dart';
import 'package:facialtrackapp/view/Teacher/Start%20Screen/live_session_screen.dart';
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
      home: SplashScreen(),
 ); }
}