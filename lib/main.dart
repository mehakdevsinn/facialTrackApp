import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/controller/providers/auth_provider.dart';
import 'package:facialtrackapp/controller/providers/student_provider.dart';
import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/view/Splash%20Screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
