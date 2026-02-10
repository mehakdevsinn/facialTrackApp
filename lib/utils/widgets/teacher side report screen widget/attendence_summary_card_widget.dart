import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final bool showOnlyLow;
  final VoidCallback onToggleLow;

  const AttendanceSummaryCard({
    super.key,
    required this.showOnlyLow,
    required this.onToggleLow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 10.0,
                percent: 0.82,
                center: const Text("82%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                progressColor: Colors.teal,
                backgroundColor: Colors.grey[200]!,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              GestureDetector(
                onTap: onToggleLow,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: showOnlyLow ? Colors.orange[800] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange[800]!),
                  ),
                  child: Text(
                    "Low Attendance",
                    style: TextStyle(
                      color: showOnlyLow ? Colors.white : Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Present: 85 days - Absent: 15 days", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IndicatorLabel(Colors.teal, "Present"),
              SizedBox(width: 20),
              _IndicatorLabel(Colors.orange, "Absent"),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndicatorLabel extends StatelessWidget {
  final Color color;
  final String text;
  const _IndicatorLabel(this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
