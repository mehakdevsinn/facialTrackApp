import 'dart:async'; // Timer ke liye zaroori hai
import 'package:facialtrackapp/view/Teacher/Root%20Screen/root_screen.dart';
import 'package:flutter/material.dart';

class LiveSessionScreen extends StatefulWidget {
  const LiveSessionScreen({super.key});

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  // Timer variables
  Timer? _timer;
  String _currentTime = "";
  Duration _duration =
      const Duration(hours: 0, minutes: 23, seconds: 45); // Initial time
  bool _isSessionRunning = true;

  @override
  void initState() {
    super.initState();
    _updateTime(); // Initial time set karne ke liye
    _startTimer();
  }
String _formatDuration(Duration duration) {
 String twoDigits(int n) => n.toString().padLeft(2, "0");
 String hours = twoDigits(duration.inHours);
 String minutes = twoDigits(duration.inMinutes.remainder(60));
 String seconds = twoDigits(duration.inSeconds.remainder(60));
 return "$hours:$minutes:$seconds";
 }
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSessionRunning) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    // Pakistan Time Format (9:13:05 PM)
    int hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    String amPm = now.hour >= 12 ? "PM" : "AM";
    String minute = now.minute.toString().padLeft(2, '0');
    String second = now.second.toString().padLeft(2, '0');

    setState(() {
      _currentTime = "$hour:$minute:$second $amPm";
    });
  }

 void _stopSession() {
  setState(() {
    _isSessionRunning = false;
    _timer?.cancel(); 
  });

  // Future.delayed(const Duration(milliseconds: 500), () {
  //   if (mounted) {
  //     // Yeh line user ko seedha pehli screen (Dashboard) par phenk degi
  //     // Raste mein jitni bhi screens (StartSessionScreen wagera) hongi, wo remove ho jayengi
  //     Navigator.of(context).popUntil((route) => route.isFirst);
  //   }
  // });
} @override
  Widget build(BuildContext context) {
    const primaryBlue = Color.fromARGB(255, 35, 4, 170);
    const orangeTheme = Color(0xFFFF7043);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Default back button ko khatam kiya
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        
        title: Row(
          children: [
  IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () {
    // Ye logic purani saari screens (Splash, Login, StartSession) khatam karke
    // seedha Dashboard par le jayegi.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const RootScreen(), 
      ),
      (route) => false, // Iska matlab hai purana koi rasta (back) nahi bachega
    );
  },
),
      
            const Text("Live Session Status",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // Real-time Timer Badge
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isSessionRunning
                  ? orangeTheme
                  : Colors.grey, // Stop hone par grey
              borderRadius: BorderRadius.circular(25),
              boxShadow: _isSessionRunning
                  ? [
                      BoxShadow(
                          color: orangeTheme.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                _currentTime, // Dynamic Time
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildClassInfoCard(),
            const SizedBox(height: 25),
            _buildStudentsGrid(),
            const SizedBox(height: 25),
            _buildSessionTimeline(),
            // const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                _buildStatCard(
                    "Attendance", "92%", Icons.pie_chart, Colors.teal),
                const SizedBox(width: 12),
                _buildStatCard(
                    "Avg Entry", "09:05 AM", Icons.access_time, primaryBlue),
                const SizedBox(width: 12),
                _buildStatCard("Duration", _formatDuration(_duration),
                    Icons.timer, orangeTheme),
              ],
            ),

            const SizedBox(height: 35),

            // End Session Button
            ElevatedButton(
              // onPressed: (){},
              onPressed: _isSessionRunning
                  ? _stopSession
                  : null, // Click karne par stop ho jaye
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeTheme,
                disabledBackgroundColor: Colors.grey, // Stop hone ke baad grey
                minimumSize: const Size(double.infinity, 54),
                shape: const StadiumBorder(),
              ),
              child: Text(
                _isSessionRunning ? "End Session" : "Session Ended",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Center(
                child: Text("This will finalize attendance",
                    style: TextStyle(
                        color: _isSessionRunning ? orangeTheme : Colors.grey,
                        fontSize: 13))),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryBlue, width: 1.5),
                minimumSize: const Size(double.infinity, 54),
                shape: const StadiumBorder(), // Same circle/pill shape
              ),
              child: const Text(
                "View Logs",
                style:
                    TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Baki Widgets (ClassInfoCard, Grid, Timeline etc.) same rahengi jo pehle thin ---
  // (Yahan aap apne purane helper methods paste kar sakte hain)
  Widget _buildClassInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF34A853), width: 2), // Green Border
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Class 10A - Mathematics",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2671))),
          const SizedBox(height: 10),
          // LIVE Tag with light green background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: Colors.orange, size: 10),
                const SizedBox(width: 6),
                const Text("LIVE",
                    style: TextStyle(
                        color: Color(0xFF34A853), fontWeight: FontWeight.bold)),
                const Text(" - 23 students detected",
                    style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Moti Orange Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.8,
              minHeight: 8, // Moti progress bar
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFF7043)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsGrid() {
    return Container(
      // Grey background container
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey shade jo image mein hai
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
            ),
            itemCount: 15, // Aap isse dynamic kar sakte hain
            itemBuilder: (context, index) {
              // Kuch icons par orange glow/border hai image mein
              bool hasAlert =
                  index == 3 || index == 7 || index == 10 || index == 11;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: hasAlert
                          ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 6,
                              )
                            ]
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          const Color(0xFF34A853), // Green color matching image
                      child: Text(index % 2 == 0 ? "AK" : "SM",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // Green check mark icon
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.check_circle,
                          color: Color(0xFF34A853), size: 16),
                    ),
                  )
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // Bottom indicator: 23/25 students detected
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF34A853), width: 2),
                ),
                child: const Text("23",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              const Text(
                "/25 students detected",
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTimeline() {
    const greenColor = Color(0xFF34A853);
    const orangeColor = Color(0xFFFF7043);
    const greyLine = Color(0xFFE0E0E0);

    // --- Thickness aur Size Adjustments ---
    const double lineThickness = 4.0; // Line ko mota karne ke liye
    const double dotSize = 14.0; // Dots ko line ke hisab se bada kiya
    const double startPadding = 35.0; // Left side se gap

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Student Timeline",style: TextStyle(fontSize: 18,color: Colors.black, fontWeight: FontWeight.bold),),
      SizedBox(height: 10,),
        Container(
          height: 100,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: startPadding),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  // 1. Background Grey Line (Moti Line)
                  Positioned(
                    left: -startPadding,
                    right: -startPadding,
                    child: Container(
                      height: lineThickness,
                      color: greyLine,
                    ),
                  ),

                  // 2. Colored Progress Lines (Moti Line)
                  Row(
                    children: [
                      const SizedBox(width: dotSize / 2),
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: lineThickness,
                          color: greenColor,
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          height: lineThickness,
                          color: orangeColor,
                        ),
                      ),
                      const SizedBox(width: dotSize / 2),
                    ],
                  ),

                  // 3. Dots Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _timelineDot(greenColor, false, dotSize),
                      _timelineDot(orangeColor, false, dotSize),
                      _timelineDot(orangeColor, true, dotSize),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 4. Labels Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _timelineLabel("09:00 AM -", "Session Started",
                      CrossAxisAlignment.start),
                  _timelineLabel("09:15 AM -", "15 students detected",
                      CrossAxisAlignment.center),
                  _timelineLabel("", "Current Time", CrossAxisAlignment.end,
                      isCurrent: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timelineDot(Color color, bool hasGlow, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 4,
                )
              ]
            : [],
      ),
    );
  }

  Widget _timelineLabel(String time, String desc, CrossAxisAlignment alignment,
      {bool isCurrent = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (time.isNotEmpty)
            Text(
              time,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          Text(
            desc,
            textAlign: alignment == CrossAxisAlignment.center
                ? TextAlign.center
                : (alignment == CrossAxisAlignment.start
                    ? TextAlign.left
                    : TextAlign.right),
            style: TextStyle(
              fontSize: 11,
              color: isCurrent ? const Color(0xFFFF7043) : Colors.black54,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

// Widget _timelineLabel(String time, String desc, {bool isCurrent = false}) {
//   return Expanded(
//     child: Column(
//       children: [
//         if (time.isNotEmpty)
//           Text(
//             time,
//             style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
//             textAlign: TextAlign.center,
//           ),
//         Text(
//           desc,
//           style: TextStyle(
//             fontSize: 10,
//             color: isCurrent ? const Color(0xFFFF7043) : Colors.black54,
//             fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     ),
//   );
// }
  Widget _timelineNode(String time, String label, bool isDone) {
    return Column(
      children: [
        Icon(Icons.circle,
            color: isDone ? Colors.teal : Colors.orange, size: 16),
        const SizedBox(height: 4),
        Text(time,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(val,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
