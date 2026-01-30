import 'package:flutter/material.dart';

class EnrollStudentScreen extends StatelessWidget {
  const EnrollStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll Student'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Enroll Student Screen Content')),
    );
  }
}
