import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _rowInfo(Icons.group, "Subjects assigned", "4"),
          const Divider(height: 30),
          _rowInfo(Icons.access_time, "Total classes handled", "13"),
        ],
      ),
    );
  }

  Widget _rowInfo(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade400),
        const SizedBox(width: 15),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
    );
  }
}
