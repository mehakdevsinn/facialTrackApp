import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentPercentageScreen extends StatefulWidget {
  final String studentName;
  final DateTime? startDate;
  final DateTime? endDate;

  const StudentPercentageScreen({
    super.key,
    required this.studentName,
    this.startDate,
    this.endDate,
  });

  @override
  State<StudentPercentageScreen> createState() =>
      _StudentPercentageScreenState();
}

class _StudentPercentageScreenState extends State<StudentPercentageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: Text("${widget.studentName} Report"),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: ColorPallet.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              _buildBigPercentageChart(),

              const SizedBox(height: 40),

              Row(
                children: [
                  _buildStatCard("Total Days", "20", Colors.blue),
                  const SizedBox(width: 15),
                  _buildStatCard("Present", "19", Colors.green),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildStatCard("Absent", "01", Colors.redAccent),
                  const SizedBox(width: 15),
                  _buildStatCard("Leave", "00", Colors.orange),
                ],
              ),

              const SizedBox(height: 40),

              _buildRemarkCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigPercentageChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: CircularProgressIndicator(
                value: _animation.value,
                strokeWidth: 15,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.grey[200],
                color: ColorPallet.primaryBlue,
              ),
            ),
            Column(
              children: [
                Text(
                  "${(_animation.value * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const Text(
                  "Attendance Rate",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarkCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorPallet.primaryBlue, const Color(0xFF6A85E6)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Excellent Performance!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Mehak is consistently attending classes in this range.",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
