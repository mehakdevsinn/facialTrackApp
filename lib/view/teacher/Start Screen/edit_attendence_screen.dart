import 'package:flutter/material.dart';

class EditAttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const EditAttendanceScreen({super.key, required this.studentData});

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen>
    with SingleTickerProviderStateMixin {
  // Animation ke liye mixin

  late TextEditingController entryController;
  late TextEditingController exitController;
  late TextEditingController durationController;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    entryController = TextEditingController(
      text: widget.studentData['entryTime'] ?? "09:00 AM",
    );
    exitController = TextEditingController(
      text: widget.studentData['exitTime'] ?? "10:30 AM",
    );
    durationController = TextEditingController(
      text: widget.studentData['time'],
    );

    // Animation Setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward(); // Start animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Edit Attendance Logs",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),),
        backgroundColor: const Color(0xFF1A237E),
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
                // Header Card for Student Name
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
                        backgroundColor: Color(0xFF1A237E),
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
      // Data wapis bheja ja raha hai
      Navigator.pop(context, {
        "entryTime": entryController.text,
        "exitTime": exitController.text,
        "time": durationController.text,
      });
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1A237E), // Dark blue
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 55), // Isse button FULL ho jayega
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold)),
  ),
),  ],
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
        // TextField ke upar wala label
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
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
            // Isse text icon ke sath center mein rahega
            textAlignVertical: TextAlignVertical.center, 
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 22),
              hintText: "Enter $label",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              // Proper Border design
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
