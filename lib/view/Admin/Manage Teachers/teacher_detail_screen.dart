import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/models/user_model.dart';
import 'package:facialtrackapp/services/api_service.dart';
import 'package:flutter/material.dart';

class TeacherDetailScreen extends StatefulWidget {
  final UserModel teacher;
  const TeacherDetailScreen({super.key, required this.teacher});

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  late UserModel _teacher;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _designationCtrl;
  late final TextEditingController _qualificationCtrl;

  @override
  void initState() {
    super.initState();
    _teacher = widget.teacher;
    _nameCtrl = TextEditingController(text: _teacher.fullName);
    _phoneCtrl = TextEditingController(text: _teacher.phoneNumber ?? '');
    _designationCtrl = TextEditingController(text: _teacher.designation ?? '');
    _qualificationCtrl =
        TextEditingController(text: _teacher.qualification ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _designationCtrl.dispose();
    _qualificationCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _teacher.fullName.trim().split(' ');
    return parts
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  void _enterEditMode() => setState(() => _isEditing = true);

  void _cancelEdit() {
    _nameCtrl.text = _teacher.fullName;
    _phoneCtrl.text = _teacher.phoneNumber ?? '';
    _designationCtrl.text = _teacher.designation ?? '';
    _qualificationCtrl.text = _teacher.qualification ?? '';
    setState(() => _isEditing = false);
  }

  Future<void> _saveChanges() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnackBar('Full Name cannot be empty.', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final updated = await ApiService.instance.updateTeacher(
        teacherId: _teacher.id,
        fullName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        designation: _designationCtrl.text.trim(),
        qualification: _qualificationCtrl.text.trim(),
      );
      if (mounted) {
        setState(() {
          _teacher = updated;
          _isEditing = false;
          _isSaving = false;
        });
        _showSnackBar('Teacher details updated successfully.', isError: false);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar(e.message, isError: true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Something went wrong. Please try again.', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ColorPallet.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEditing ? 'Edit Teacher' : 'Teacher Details',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: _enterEditMode,
                tooltip: 'Edit',
              )
            else
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _cancelEdit,
                tooltip: 'Cancel',
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: _isEditing ? _buildEditItems() : _buildViewItems(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Blue header (matching UserApprovalDetailScreen) ──────────────────────
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: ColorPallet.primaryBlue.withOpacity(0.1),
              child: Text(
                _initials,
                style: const TextStyle(
                  color: ColorPallet.primaryBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _teacher.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _teacher.designation?.isNotEmpty == true
                  ? _teacher.designation!
                  : 'Teacher',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── View mode ─────────────────────────────────────────────────────────────
  List<Widget> _buildViewItems() {
    return [
      _buildDetailItem(Icons.email_outlined, 'Email Address', _teacher.email),
      _buildDetailItem(
        Icons.person_outline,
        'Full Name',
        _teacher.fullName,
      ),
      _buildDetailItem(
        Icons.phone_outlined,
        'Phone Number',
        _teacher.phoneNumber?.isNotEmpty == true
            ? _teacher.phoneNumber!
            : 'Not provided',
      ),
      _buildDetailItem(
        Icons.work_outline,
        'Designation',
        _teacher.designation?.isNotEmpty == true
            ? _teacher.designation!
            : 'Not provided',
      ),
      _buildDetailItem(
        Icons.school_outlined,
        'Qualification',
        _teacher.qualification?.isNotEmpty == true
            ? _teacher.qualification!
            : 'Not provided',
      ),
    ];
  }

  // ── Edit mode ─────────────────────────────────────────────────────────────
  List<Widget> _buildEditItems() {
    return [
      // Email always read-only
      _buildDetailItem(
        Icons.email_outlined,
        'Email Address (read-only)',
        _teacher.email,
      ),
      const SizedBox(height: 4),
      _buildEditField(
        controller: _nameCtrl,
        label: 'FULL NAME *',
        icon: Icons.person_outline,
        hint: 'Dr. John Doe',
      ),
      const SizedBox(height: 14),
      _buildEditField(
        controller: _phoneCtrl,
        label: 'PHONE NUMBER',
        icon: Icons.phone_outlined,
        hint: '0300-1234567',
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 14),
      _buildEditField(
        controller: _designationCtrl,
        label: 'DESIGNATION',
        icon: Icons.work_outline,
        hint: 'Associate Professor',
      ),
      const SizedBox(height: 14),
      _buildEditField(
        controller: _qualificationCtrl,
        label: 'QUALIFICATION',
        icon: Icons.school_outlined,
        hint: 'PhD Computer Science',
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveChanges,
          icon: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Icon(Icons.save_outlined, color: Colors.white),
          label: Text(
            _isSaving ? 'Saving...' : 'Save Changes',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPallet.primaryBlue,
            disabledBackgroundColor: ColorPallet.primaryBlue.withOpacity(0.6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
          ),
        ),
      ),
    ];
  }

  // ── Shared: detail row (view mode) ────────────────────────────────────────
  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorPallet.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: ColorPallet.primaryBlue, size: 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared: text field (edit mode) ────────────────────────────────────────
  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: ColorPallet.primaryBlue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 20),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: ColorPallet.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
