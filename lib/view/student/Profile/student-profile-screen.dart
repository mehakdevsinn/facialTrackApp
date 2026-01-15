import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 243, 243),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                /// 📌 HEADER (Cover + Profile Pic)
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      color: ColorPallet.primaryBlue,
                    ),
                    Positioned(
                      bottom: -50,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            "https://i.pravatar.cc/150?img=12",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                /// 👤 Name & ID
                Text(
                  "Ahmad Hassan",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  "ID: STU-2024-1234",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 17),
                ),

                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      "Computer Science - Semester 5",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 📄 Personal Info Card
                _infoCard(),

                const SizedBox(height: 16),

                /// 📊 Attendance Overview
                _attendanceCard(),

                const SizedBox(height: 16),

                _thisMonthCard(),

                const SizedBox(height: 24),

                /// 📥 Buttons
                _bottomButtons(context),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.medical_information_outlined, "Personal Information"),

          _infoRow(Icons.email, "ahmad.hassan@university.edu"),
          const SizedBox(height: 8),
          _infoRow(Icons.phone, "+92 300 1234567"),
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today, "Enrolled: September 2023"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: ColorPallet.primaryBlue),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _attendanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 8,
            percent: 0.87,
            center: Text(
              "87%",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            progressColor: Colors.green,
            backgroundColor: Colors.green.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statRow("Total Classes", "145", Icons.event),
              const SizedBox(height: 6),
              _statRow("Present", "126", Icons.check_circle),
              const SizedBox(height: 6),
              _statRow("Absent", "19", Icons.cancel),
              const SizedBox(height: 6),
              _statRow("Leave", "5", Icons.airplane_ticket),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text("$title: $value", style: TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _thisMonthCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This Month",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "92%",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text("Classes attended: 18/20", style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Best subject: ⭐ Mathematics", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _bottomButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.download_rounded),
          label: Text("Download Report"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {},
          child: const Text("Logout", style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}
