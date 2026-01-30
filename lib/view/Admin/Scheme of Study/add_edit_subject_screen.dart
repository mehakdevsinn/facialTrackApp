import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/widgets/scheme_widgets.dart';
import 'package:flutter/material.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddEditSubjectScreen({super.key, this.initialData});

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

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? "";
      _codeController.text = widget.initialData!['code'] ?? "";
      _creditsController.text = widget.initialData!['credits'] ?? "";
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
          title: Text(
            widget.initialData != null
                ? "Edit Subject Detail"
                : "New Subject Detail",
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
                          hint: "Subject Title",
                          icon: Icons.edit_note_rounded,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
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
                        const SizedBox(height: 50),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPallet.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 8,
                              shadowColor: ColorPallet.primaryBlue.withOpacity(
                                0.4,
                              ),
                            ),
                            onPressed: () => _handleSave(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.initialData != null
                                      ? "UPDATE SUBJECT"
                                      : "SAVE SUBJECT",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

  void _handleSave() {
    if (_titleController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _creditsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      "title": _titleController.text,
      "code": _codeController.text,
      "credits": _creditsController.text,
    });
  }
}
