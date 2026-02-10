import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Start%20Screen/live_session_screen.dart';
import 'package:flutter/material.dart';

class StartSessionScreen extends StatefulWidget {
  final bool showBackButton;

  // Constructor bilkul aise likhein
  const StartSessionScreen({super.key, this.showBackButton = false});

  @override // Yeh line 'createState' se upar honi chahiye
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  String? selectedSemester;
  String? selectedSubject;

  final List<String> classes = [
    'Semester 2',
    'Semester 4',
    'Semester 6',
    'Semester 8',
  ];
  final List<String> subjects = [
    'OOP',
    'Computer architecture',
    'wireless network',
    'Information Security',
  ];

  @override
  Widget build(BuildContext context) {
    bool isReady = selectedSemester != null && selectedSubject != null;
    const primaryColor = Color.fromARGB(255, 35, 4, 170);

    return PopScope(
      // Agar dashboard se aaye hain toh pop hona chahiye (true)
      // Agar bottom nav se aaye hain toh pop nahi hona chahiye (false)
      canPop: widget.showBackButton,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          // StartSessionScreen ke build method mein
          appBar: AppBar(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,

            // Logic update: showBackButton check karein
            leading: widget.showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,

            title: Row(
              children: [
                // Logo se pehle space sirf tab jab back button na ho
                if (!widget.showBackButton) const SizedBox(width: 8),

                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
                SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Start Attendance Session",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // ... baki title ka code
              ],
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      "Start New Session",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Select semester and subject to begin attendance",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildLabel("Select Semester", primaryColor),
                  _buildCustomDropdown(
                    hint: "Choose semester...",
                    icon: Icons.groups,
                    value: selectedSemester,
                    items: classes,
                    color: primaryColor,
                    onChanged: (val) => setState(() => selectedSemester = val),
                  ),

                  const SizedBox(height: 25),

                  _buildLabel("Select Subject", primaryColor),
                  _buildCustomDropdown(
                    hint: "Choose subject...",
                    icon: Icons.book,
                    value: selectedSubject,
                    items: subjects,
                    color: primaryColor,
                    onChanged: (val) => setState(() => selectedSubject = val),
                  ),

                  const SizedBox(height: 100),

                  Opacity(
                    opacity: isReady ? 1.0 : 0.5,
                    child: ElevatedButton(
                      onPressed: isReady
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LiveSessionScreen(
                                    autoStart: true,
                                  ), // Signal: START
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF81C784),
                        disabledBackgroundColor: const Color(
                          0xFF81C784,
                        ).withOpacity(0.5),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Start Session",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Color color,
    required ValueChanged<String?> onChanged,
  }) {
    bool hasData = value != null;

    return Container(
      // Shadow remove kar di gayi hai taake field clean dikhe
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        icon: const SizedBox.shrink(),
        selectedItemBuilder: (BuildContext context) {
          return items.map((String item) {
            return Text(
              item,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            );
          }).toList();
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: color),
          suffixIcon: SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasData)
                  const Icon(Icons.check_circle, color: Colors.teal, size: 20),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
                const SizedBox(width: 8),
              ],
            ),
          ),
          filled: true,
          // Fill color ab fixed hai, selection se pehle aur baad same rahega
          fillColor: color.withOpacity(0.08),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              // Border ko mazeed light kar diya gaya hai constant look ke liye
              color: color.withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: items.map((String item) {
          bool isSelected = (value == item);
          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? color : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(item),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
