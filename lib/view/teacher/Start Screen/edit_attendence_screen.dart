import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class EditAttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const EditAttendanceScreen({super.key, required this.studentData});

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController entryController;
  late TextEditingController exitController;
  late TextEditingController durationController;
  late TextEditingController leaveReasonController;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool isAbsent = false;

  @override
  void initState() {
    super.initState();

    // 1. Logic check for Absent status
    isAbsent = widget.studentData['status']?.toLowerCase() == 'absent';

    // 2. Initialize Controllers
    entryController = TextEditingController(
      text: widget.studentData['entryTime'] ?? "09:00 AM",
    );
    exitController = TextEditingController(
      text: widget.studentData['exitTime'] ?? "10:30 AM",
    );
    durationController = TextEditingController(
      text: widget.studentData['time'],
    );
    leaveReasonController = TextEditingController(
      text: widget.studentData['leaveReason'] ?? "",
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    entryController.dispose();
    exitController.dispose();
    durationController.dispose();
    leaveReasonController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Edit Attendance Logs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: ColorPallet.primaryBlue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        widget.studentData['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _buildAnimatedField(
                  "Entry Time",
                  entryController,
                  Icons.login,
                  0,
                ),
                const SizedBox(height: 15),
                _buildAnimatedField(
                  "Exit Time",
                  exitController,
                  Icons.logout,
                  1,
                ),
                if (isAbsent) ...[
                  const SizedBox(height: 15),
                  _buildAnimatedField(
                    "Leave Reason (Optional)",
                    leaveReasonController,
                    Icons.note_alt_outlined,
                    3,
                  ),
                ],
                const SizedBox(height: 15),
                _buildAnimatedField(
                  "Total Duration",
                  durationController,
                  Icons.timer_outlined,
                  2,
                ),

                const Spacer(),

                Hero(
                  tag: 'save_btn',
                  child: ElevatedButton(
                    onPressed: () {
                      String finalStatus = widget.studentData['status'];

                      if (isAbsent &&
                          leaveReasonController.text.trim().isNotEmpty) {
                        finalStatus = "Leave";
                      } else if (isAbsent &&
                          leaveReasonController.text.trim().isEmpty) {
                        finalStatus = "Absent";
                      }

                      Navigator.pop(context, {
                        "entryTime": entryController.text,
                        "exitTime": exitController.text,
                        "time":
                            "${entryController.text} - ${exitController.text}",
                        "leaveReason": leaveReasonController.text,
                        "status": finalStatus,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallet.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "SAVE CHANGES",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField(
    String label,
    TextEditingController controller,
    IconData icon,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorPallet.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 22),
              hintText: "Enter $label",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ColorPallet.primaryBlue,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
