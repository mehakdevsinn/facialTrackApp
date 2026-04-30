import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:facialtrackapp/view/teacher/Complaints/teacher_my_complaints_screen.dart';
import 'package:flutter/material.dart';

/// Teacher → admin. `POST /teachers/complaints/admin`
class TeacherReportIssueScreen extends StatefulWidget {
  const TeacherReportIssueScreen({super.key});

  @override
  State<TeacherReportIssueScreen> createState() =>
      _TeacherReportIssueScreenState();
}

class _TeacherReportIssueScreenState extends State<TeacherReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _categoryKey;
  final TextEditingController _descController = TextEditingController();
  bool _loading = false;

  List<MapEntry<String, String>> get _entries =>
      ComplaintItem.teacherAdminCategoryLabels.entries.toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiManager.instance.postTeacherAdminComplaint(
        category: _categoryKey!,
        reason: _descController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted to admin'),
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text(
            'Report Issue to Admin',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency_share_outlined,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Help & support',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Your report goes to the system administrator.',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'CATEGORY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _categoryKey,
                    decoration: const InputDecoration(border: InputBorder.none),
                    hint: const Text('Choose a category'),
                    items: _entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _categoryKey = v),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please select a category' : null,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _descController,
                    maxLines: 6,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Explain the issue in detail…',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TeacherMyComplaintsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('View my submitted complaints'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallet.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SUBMIT REPORT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
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
}
