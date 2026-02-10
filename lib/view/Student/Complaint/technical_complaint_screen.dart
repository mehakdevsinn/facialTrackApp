import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/global_complaints.dart';
import 'package:facialtrackapp/widgets/textfield_login.dart';
// import '../../../../controller/complaint_service.dart';
// import '../../../../model/complaint_model.dart';
import 'package:flutter/material.dart';

class TechnicalComplaintScreen extends StatefulWidget {
  const TechnicalComplaintScreen({super.key});

  @override
  State<TechnicalComplaintScreen> createState() =>
      _TechnicalComplaintScreenState();
}

class _TechnicalComplaintScreenState extends State<TechnicalComplaintScreen> {
  bool get isButtonEnabled =>
      _selectedCategory != null && description.isNotEmpty;
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  final FocusNode descriptionFocus = FocusNode();
  String description = "";

  final List<String> _categories = [
    'Login Issue',
    'Face Verification Issue',
    'App Bug',
    'Other',
  ];

  void _submitComplaint() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe the issue")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create complaint map
    final newComplaint = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "type": "Technical",
      "status": "Pending",
      "submissionDate": DateTime.now(),
      "description": _descriptionController.text.trim(),
      "category": _selectedCategory,
    };

    // Simulate delay
    await Future.delayed(const Duration(seconds: 1));

    // Save to global storage
    globalComplaints.insert(0, newComplaint);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complaint submitted to Admin"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Report Technical Issue",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "What issue are you facing?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // // Category Dropdown
              // DropdownButtonFormField<String>(
              //   dropdownColor: Colors.white,
              //   borderRadius: BorderRadius.all(Radius.circular(12)),

              //   decoration: InputDecoration(
              //     filled: true,
              //     fillColor: Colors.white,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey.shade300),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey.shade300),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide(color: Colors.grey.shade300),
              //     ),
              //     contentPadding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 14,
              //     ),
              //   ),
              //   hint: const Text("Select Issue Category"),
              //   value: _selectedCategory,
              //   items: _categories.map((cat) {
              //     return DropdownMenuItem(value: cat, child: Text(cat));
              //   }).toList(),
              //   onChanged: (val) => setState(() => _selectedCategory = val),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorPallet.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCategory != null
                          ? ColorPallet.primaryBlue
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 1,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Row(
                          children: [
                            // Icon(
                            //   Icons.school_outlined,
                            //   color: Colors.grey,
                            //   size: 20,
                            // ),
                            // const SizedBox(width: 12),
                            Text(
                              "Select Issue",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        value: _selectedCategory,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _selectedCategory != null
                              ? ColorPallet.primaryBlue
                              : Colors.grey,
                        ),
                        items: _categories.map((String semester) {
                          return DropdownMenuItem<String>(
                            value: semester,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: Text(
                                semester,

                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              buildTextFieldDescription(
                controller: _descriptionController,
                line: 5,
                // label: "Student ID",
                hint: "Please describe the technical issue...",
                // icon: Icons.person_outline,
                activeColor: ColorPallet.primaryBlue,
                inactiveColor: Colors.grey,
                focusNode: descriptionFocus,
                onChange: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Screenshot Attachment (Placeholder)
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.attach_file, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text(
                      "Attach Screenshot (Optional)",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPallet.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Complaint",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
