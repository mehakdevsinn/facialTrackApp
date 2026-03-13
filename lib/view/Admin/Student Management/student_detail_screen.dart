import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/utils/dummy/student_dummy_data.dart';
import 'package:flutter/material.dart';

class StudentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> student; // mutable copy from dummy data

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  bool _isEditing = false;
  late Map<String, dynamic> _student;

  // Text controllers for editable fields
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _rollNoCtrl;

  // Dropdown values
  late String _selectedSection;
  late int _selectedSemester;

  static const List<String> _sections = ['A', 'B', 'C', 'D', 'E'];
  static const List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void initState() {
    super.initState();
    _student = Map.from(widget.student);
    _nameCtrl = TextEditingController(text: _student['fullName']);
    _emailCtrl = TextEditingController(text: _student['email']);
    _phoneCtrl = TextEditingController(text: _student['phone']);
    _rollNoCtrl = TextEditingController(text: _student['rollNo']);
    _selectedSection = _student['section'] as String;
    _selectedSemester = _student['semesterNumber'] as int;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _rollNoCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = (_student['fullName'] as String).trim().split(' ');
    return parts
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  Color get _avatarColor =>
      StudentDummyData.avatarColor(_student['id'] as String);

  // ── Edit / Cancel / Save ──────────────────────────────────────────────────
  void _enterEdit() => setState(() => _isEditing = true);

  void _cancelEdit() {
    _nameCtrl.text = _student['fullName'];
    _emailCtrl.text = _student['email'];
    _phoneCtrl.text = _student['phone'];
    _rollNoCtrl.text = _student['rollNo'];
    _selectedSection = _student['section'];
    _selectedSemester = _student['semesterNumber'];
    setState(() => _isEditing = false);
  }

  void _saveChanges() {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Full name cannot be empty.', isError: true);
      return;
    }
    final updated = {
      'fullName': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'rollNo': _rollNoCtrl.text.trim(),
      'section': _selectedSection,
      'semesterNumber': _selectedSemester,
    };
    StudentDummyData.updateStudent(_student['id'] as String, updated);
    setState(() {
      _student = {..._student, ...updated};
      _isEditing = false;
    });
    _showSnack('Student details updated!', isError: false);
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
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
            _isEditing ? 'Edit Student' : 'Student Details',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Edit',
                onPressed: _enterEdit,
              )
            else
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Cancel',
                onPressed: _cancelEdit,
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: _isEditing ? _buildEditForm() : _buildViewRows(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Blue rounded header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 40),
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
                color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: _avatarColor.withOpacity(0.1),
              child: Text(_initials,
                  style: TextStyle(
                      color: _avatarColor,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _student['fullName'] as String,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            _student['rollNo'] as String,
            style:
                TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
          ),
          const SizedBox(height: 10),
          // Semester + Section + Face badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _headerBadge('Semester ${_student['semesterNumber']}'),
              const SizedBox(width: 8),
              _headerBadge('Section ${_student['section']}'),
              const SizedBox(width: 8),
              _headerBadge(
                (_student['faceEnrolled'] as bool)
                    ? '✓ Face Enrolled'
                    : '✗ No Face',
                color: (_student['faceEnrolled'] as bool)
                    ? Colors.green.withOpacity(0.25)
                    : Colors.red.withOpacity(0.25),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  // ── View mode ──────────────────────────────────────────────────────────────
  List<Widget> _buildViewRows() {
    return [
      _viewRow(Icons.person_outline, 'Full Name', _student['fullName']),
      _viewRow(Icons.badge_outlined, 'Roll Number', _student['rollNo']),
      _viewRow(Icons.email_outlined, 'Email Address', _student['email']),
      _viewRow(Icons.phone_outlined, 'Phone Number', _student['phone']),
      _viewRow(Icons.school_rounded, 'Semester',
          'Semester ${_student['semesterNumber']}'),
      _viewRow(
          Icons.group_rounded, 'Section', 'Section ${_student['section']}'),
      _viewRowReadOnly(Icons.calendar_today_outlined, 'Enrollment Date',
          _student['enrollmentDate']),
      _viewRowReadOnly(
        Icons.face_retouching_natural,
        'Face Enrollment',
        (_student['faceEnrolled'] as bool) ? 'Enrolled ✓' : 'Not Enrolled',
        valueColor:
            (_student['faceEnrolled'] as bool) ? Colors.green : Colors.orange,
      ),
    ];
  }

  Widget _viewRow(IconData icon, String label, String value) {
    return _buildDetailCard(
      icon: icon,
      label: label,
      value: value,
      isReadOnly: false,
    );
  }

  Widget _viewRowReadOnly(IconData icon, String label, String value,
      {Color? valueColor}) {
    return _buildDetailCard(
      icon: icon,
      label: label,
      value: value,
      isReadOnly: true,
      valueColor: valueColor,
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isReadOnly,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorPallet.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: ColorPallet.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(value,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: valueColor ?? const Color(0xFF1E293B))),
                    ),
                    if (isReadOnly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('read-only',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 9)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit mode ──────────────────────────────────────────────────────────────
  List<Widget> _buildEditForm() {
    return [
      _editField(
          ctrl: _nameCtrl,
          label: 'FULL NAME *',
          icon: Icons.person_outline,
          hint: 'Ali Hassan'),
      const SizedBox(height: 14),
      _editField(
          ctrl: _rollNoCtrl,
          label: 'ROLL NUMBER',
          icon: Icons.badge_outlined,
          hint: 'BSCS-F21-001'),
      const SizedBox(height: 14),
      _editField(
          ctrl: _emailCtrl,
          label: 'EMAIL',
          icon: Icons.email_outlined,
          hint: 'student@edu.pk',
          keyboard: TextInputType.emailAddress),
      const SizedBox(height: 14),
      _editField(
          ctrl: _phoneCtrl,
          label: 'PHONE',
          icon: Icons.phone_outlined,
          hint: '0301-1234567',
          keyboard: TextInputType.phone),
      const SizedBox(height: 14),
      // Semester dropdown
      _dropdownField<int>(
        label: 'SEMESTER',
        icon: Icons.school_rounded,
        value: _selectedSemester,
        items: _semesters,
        display: (v) => 'Semester $v',
        onChanged: (v) => setState(() => _selectedSemester = v!),
      ),
      const SizedBox(height: 14),
      // Section dropdown
      _dropdownField<String>(
        label: 'SECTION',
        icon: Icons.group_rounded,
        value: _selectedSection,
        items: _sections,
        display: (v) => 'Section $v',
        onChanged: (v) => setState(() => _selectedSection = v!),
      ),
      const SizedBox(height: 6),
      // Read-only fields note
      Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded,
                color: Colors.grey.shade400, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Enrollment Date and Face Status are system-managed and cannot be edited.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Save button
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _saveChanges,
          icon: const Icon(Icons.save_outlined, color: Colors.white),
          label: const Text('Save Changes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPallet.primaryBlue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
          ),
        ),
      ),
    ];
  }

  Widget _editField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5)),
        ),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          cursorColor: ColorPallet.primaryBlue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 20),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.shade200, width: 1.4)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: ColorPallet.primaryBlue, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1.4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: ColorPallet.primaryBlue),
              items: items
                  .map((item) => DropdownMenuItem(
                      value: item,
                      child: Row(
                        children: [
                          Icon(icon, color: ColorPallet.primaryBlue, size: 18),
                          const SizedBox(width: 10),
                          Text(display(item),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B))),
                        ],
                      )))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
