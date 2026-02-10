import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final bool showBackButton;
  final String name;
  final String teacherId;
  final String imagePath;

  const ProfileHeader({
    super.key,
    required this.showBackButton,
    required this.name,
    required this.teacherId,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 1. Dark Blue Background
        Container(
          height: 220,
          width: double.infinity,
          color: const Color.fromARGB(255, 35, 4, 170),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 20),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Teacher Profile",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. White Card Section
        Container(
          margin: const EdgeInsets.only(top: 160),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 70),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(teacherId, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // 3. Floating Profile Image
        Positioned(
          top: 100,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFE0E0FF),
              backgroundImage: AssetImage(imagePath),
            ),
          ),
        ),
      ],
    );
  }
}
