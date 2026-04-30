import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:facialtrackapp/utils/widgets/textfield_login.dart';
import 'package:flutter/material.dart';

/// Student → admin general complaint. `POST /students/complaints/admin`
class TechnicalComplaintScreen extends StatefulWidget {
  const TechnicalComplaintScreen({super.key});

  @override
  State<TechnicalComplaintScreen> createState() =>
      _TechnicalComplaintScreenState();
}

class _TechnicalComplaintScreenState extends State<TechnicalComplaintScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategoryKey;
  bool _isLoading = false;
  final FocusNode _descriptionFocus = FocusNode();

  List<MapEntry<String, String>> get _categoryEntries =>
      ComplaintItem.studentAdminCategoryLabels.entries.toList();

  Future<void> _submitComplaint() async {
    if (_selectedCategoryKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiManager.instance.postStudentAdminComplaint(
        category: _selectedCategoryKey!,
        reason: _descriptionController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted to admin'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Report to Admin',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: ColorPallet.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedCategoryKey != null
                        ? ColorPallet.primaryBlue
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select category'),
                    value: _selectedCategoryKey,
                    items: _categoryEntries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryKey = v),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
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
                hint: 'Describe your issue in detail...',
                activeColor: ColorPallet.primaryBlue,
                inactiveColor: Colors.grey,
                focusNode: _descriptionFocus,
                onChange: (_) {},
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
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Complaint',
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
