import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/course_model.dart';
import 'package:facialtrackapp/utils/widgets/scheme_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final String semesterId;
  final CourseModel? initialCourse;

  const AddEditSubjectScreen({
    super.key,
    required this.semesterId,
    this.initialCourse,
  });

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();
  final _outlineController = TextEditingController();
  bool _attendanceRequired = true;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCourse != null) {
      _titleController.text = widget.initialCourse!.name;
      _codeController.text = widget.initialCourse!.code;
      _creditsController.text = widget.initialCourse!.creditHours.toString();
      _outlineController.text = widget.initialCourse!.description;
      _attendanceRequired = widget.initialCourse!.attendanceRequired;
      _isActive = widget.initialCourse!.isActive;
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _outlineController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = context.read<AdminProvider>();
    final creditHours = int.tryParse(_creditsController.text) ?? 3;

    final success = widget.initialCourse == null
        ? await provider.createCourse(
            code: _codeController.text.trim(),
            name: _titleController.text.trim(),
            semesterId: widget.semesterId,
            description: _outlineController.text.trim(),
            creditHours: creditHours,
            attendanceRequired: _attendanceRequired,
          )
        : await provider.updateCourse(
            courseId: widget.initialCourse!.id,
            semesterId: widget.semesterId,
            name: _titleController.text.trim(),
            creditHours: creditHours,
            attendanceRequired: _attendanceRequired,
            isActive: _isActive,
          );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Course ${widget.initialCourse == null ? 'created' : 'updated'} successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "An error occurred"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
          title: Text(
            widget.initialCourse != null ? "Edit Course" : "New Course",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SchemeLabel(text: "Subject Information"),
                        SchemeModernField(
                          controller: _titleController,
                          hint: "Subject Title (e.g. Data Structures)",
                          icon: Icons.edit_note_rounded,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SchemeLabel(text: "Course Code"),
                                  SchemeModernField(
                                    controller: _codeController,
                                    hint: "CS-101",
                                    icon: Icons.code_rounded,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SchemeLabel(text: "Credits"),
                                  SchemeModernField(
                                    controller: _creditsController,
                                    hint: "e.g., 3",
                                    icon: Icons.stars_rounded,
                                    isNum: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SchemeLabel(text: "Course Settings"),
                        SchemeToggleField(
                          label: "Attendance Required",
                          value: _attendanceRequired,
                          icon: Icons.fact_check_rounded,
                          onChanged: (val) =>
                              setState(() => _attendanceRequired = val),
                        ),
                        if (widget.initialCourse != null)
                          SchemeToggleField(
                            label: "Course Active",
                            value: _isActive,
                            icon: Icons.toggle_on_rounded,
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                        const SchemeLabel(text: "Description"),
                        SchemeModernField(
                          controller: _outlineController,
                          hint: "Briefly describe the course content...",
                          icon: Icons.description_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Consumer<AdminProvider>(
                            builder: (context, provider, child) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorPallet.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 8,
                                  shadowColor:
                                      ColorPallet.primaryBlue.withOpacity(0.4),
                                ),
                                onPressed:
                                    provider.isLoading ? null : _handleSave,
                                child: provider.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            widget.initialCourse != null
                                                ? "UPDATE COURSE"
                                                : "SAVE COURSE",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              );
                            },
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
}
