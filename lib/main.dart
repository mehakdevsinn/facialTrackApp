import 'package:facialtrackapp/view/navbar/student-navbar.dart';
import 'package:facialtrackapp/view/student/attendence-history-screen.dart';
import 'package:facialtrackapp/view/student/dashboard-screeen.dart';
import 'package:facialtrackapp/view/student/login.dart';
import 'package:facialtrackapp/view/teacher/login.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:
          // DashboardScreen(),
          StudentLoginScreen(),
      // TeacherLoginScreen(),
      // AttendanceHistoryScreen(),
      // MainNavigationScreen(),
    );
  }
}
