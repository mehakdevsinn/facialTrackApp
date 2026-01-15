import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/widgets/dashboard-widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 243, 243),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -220,
                    left: -120,
                    right: -120,
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: ColorPallet.primaryBlue,
                        borderRadius: BorderRadius.circular(400),
                      ),
                    ),
                  ),

                  const Positioned(
                    top: 20,
                    left: 20,
                    child: Text(
                      "Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: ColorPallet.white,
                        ),
                        SizedBox(width: 16),

                        CircleAvatar(radius: 17),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 90,
                    left: 20,
                    right: 20,
                    child: todayAttendanceCard(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            Transform.translate(
              offset: const Offset(0, -60),
              child: overallAttendanceCard(),
            ),

            const SizedBox(height: 16),

            Transform.translate(
              offset: const Offset(0, -60),
              child: subjectsSection(),
            ),
          ],
        ),
      ),
    );
  }
}
