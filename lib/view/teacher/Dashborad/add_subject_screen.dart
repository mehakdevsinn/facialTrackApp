import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _syllabusController = TextEditingController();
  final _attendanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Animation setup: Jab screen khule to fields thoda slide hokar aayein
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
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
        backgroundColor: ColorPallet.primaryBlue,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 23),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("New Subject Detail", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,fontSize: 18, letterSpacing: 1)),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedLabel("Subject Identity"),
                        _buildModernField(_nameController, "Subject Name", Icons.edit_note_rounded),
                        
                        _buildAnimatedLabel("Semester Assignment"),
                        _buildModernField(_gradeController, "Grade (e.g., Grade 11-A)", Icons.school_outlined),
                        
                        _buildAnimatedLabel("Academic Progress"),
                        Row(
                          children: [
                            Expanded(child: _buildModernField(_syllabusController, "Syllabus %", Icons.pie_chart_outline, isNum: true)),
                            const SizedBox(width: 15),
                            Expanded(child: _buildModernField(_attendanceController, "Attendance %", Icons.percent, isNum: true)),
                          ],
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Animated Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPallet.primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 8,
                              shadowColor: ColorPallet.primaryBlue.withOpacity(0.4),
                            ),
                            onPressed: () => _handleSave(),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.white),
                                SizedBox(width: 10),
                                Text("SAVE SUBJECT", 
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10, top: 20),
      child: Text(text, 
        style: TextStyle(color: ColorPallet.primaryBlue.withOpacity(0.6), 
        fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
    );
  }

  Widget _buildModernField(TextEditingController controller, String hint, IconData icon, {bool isNum = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: ColorPallet.primaryBlue, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.redAccent));
      return;
    }

    Navigator.pop(context, {
      "title": _nameController.text,
      "assigned": _gradeController.text,
      "syllabus": (double.tryParse(_syllabusController.text) ?? 0) / 100,
      "avg": "${_attendanceController.text}%",
      "icon": Icons.book_rounded,
      "grade": _gradeController.text.contains("11") ? "Grade 11" : "Grade 10",
      "percentCircle": int.tryParse(_attendanceController.text) ?? 0,
    });
  }
}