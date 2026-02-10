import 'package:flutter/material.dart';

class MonthlyTrendChart extends StatelessWidget {
  final bool showOnlyLow;
  const MonthlyTrendChart({super.key, required this.showOnlyLow});

  @override
  Widget build(BuildContext context) {
    const double maxChartHeight = 150.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Monthly Trend", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-Axis
              SizedBox(
                height: maxChartHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ["100%", "80%", "60%", "40%", "20%", "0%"]
                      .map((l) => Text(l, style: const TextStyle(fontSize: 9, color: Colors.grey))).toList(),
                ),
              ),
              const SizedBox(width: 10),
              // Bars
              Expanded(
                child: SizedBox(
                  height: maxChartHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar(85, 0, 0, "Week 1", maxChartHeight, !showOnlyLow),
                      _buildBar(10, 20, 45, "Week 2", maxChartHeight, true),
                      _buildBar(20, 15, 30, "Week 3", maxChartHeight, !showOnlyLow),
                      _buildBar(0, 35, 50, "Week 4", maxChartHeight, !showOnlyLow),
                      _buildBar(0, 10, 15, "Week 5", maxChartHeight, true),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBar(double blue, double orange, double teal, String label, double maxHeight, bool isHighlighted) {
    return Opacity(
      opacity: isHighlighted ? 1.0 : 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 25,
            child: Column(
              children: [
                if (teal > 0) Container(height: (teal/100)*maxHeight, color: const Color(0xFF26A69A)),
                if (orange > 0) Container(height: (orange/100)*maxHeight, color: const Color(0xFFFF8A65)),
                if (blue > 0) Container(height: (blue/100)*maxHeight, color: const Color(0xFF1A4B8F)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }
}