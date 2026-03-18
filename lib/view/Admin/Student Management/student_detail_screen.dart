import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final StudentModel student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late StudentModel _student;
  bool _editMode = false;

  // Edit controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _rollCtrl;
  late TextEditingController _emailCtrl;
  late int _semesterValue;
  late String _sectionValue;

  static const _sections = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _initControllers();

    // Ensure semesters are loaded for the edit dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchSemesters();
    });
  }

  void _initControllers() {
    _nameCtrl = TextEditingController(text: _student.fullName);
    _rollCtrl = TextEditingController(text: _student.rollNo);
    _emailCtrl = TextEditingController(text: _student.email);
    _semesterValue = _student.semesterNumber;
    _sectionValue = _student.section;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _enterEdit() => setState(() {
        _editMode = true;
        // Reset controllers to current values
        _nameCtrl.text = _student.fullName;
        _rollCtrl.text = _student.rollNo;
        _emailCtrl.text = _student.email;
        _semesterValue = _student.semesterNumber;
        _sectionValue = _student.section;
      });

  void _cancelEdit() => setState(() => _editMode = false);

  Future<void> _saveChanges() async {
    final name = _nameCtrl.text.trim();
    final roll = _rollCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || roll.isEmpty || email.isEmpty) {
      _showSnack(
          'Name, roll number and email are required.', Colors.red.shade600);
      return;
    }

    final updated = await context.read<AdminProvider>().updateStudent(
          _student.id,
          fullName: name,
          rollNo: roll,
          email: email,
          semesterNumber: _semesterValue,
          section: _sectionValue,
        );

    if (!mounted) return;

    if (updated != null) {
      setState(() {
        _student = updated;
        _editMode = false;
      });
      _showSnack('Changes saved successfully!', Colors.green.shade600);
    } else {
      final err = context.read<AdminProvider>().errorMessage;
      _showSnack(err ?? 'Failed to save changes.', Colors.red.shade600);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Color get _avatarColor {
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
      Color(0xFFF97316),
      Color(0xFF22C55E),
      Color(0xFFEF4444),
      Color(0xFF3B82F6),
    ];
    final hash = _student.id.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isActionLoading =
        context.watch<AdminProvider>().isStudentsActionLoading;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _editMode
                    ? _buildEditForm(isActionLoading)
                    : _buildViewMode(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Blue header ────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 28),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const Text(
                'Student Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              if (!_editMode)
                GestureDetector(
                  onTap: _enterEdit,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Edit',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(width: 60),
            ],
          ),
          const SizedBox(height: 20),

          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _avatarColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Center(
              child: Text(
                _student.initials,
                style: TextStyle(
                    color: _avatarColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 26),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _student.fullName,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _student.rollNo,
            style:
                TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _headerBadge(String label, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── View mode ──────────────────────────────────────────────────────────────
  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _sectionTitle('Personal Information'),
        _infoCard([
          _infoRow(Icons.person_outline, 'Full Name', _student.fullName),
          _divider(),
          _infoRow(Icons.email_outlined, 'Email', _student.email),
          _divider(),
          _infoRow(Icons.badge_outlined, 'Roll Number', _student.rollNo),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('Academic Information'),
        _infoCard([
          _infoRow(Icons.school_outlined, 'Semester',
              'Semester ${_student.semesterNumber}'),
          _divider(),
          _infoRow(Icons.people_outline, 'Section', _student.section),
          _divider(),
          _infoRow(Icons.calendar_today_outlined, 'Enrollment Date',
              _student.displayDate,
              readOnly: true),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('Face Enrollment'),
        _infoCard([
          _infoRow(
            Icons.face_retouching_natural,
            'Status',
            _student.faceEnrolled ? 'Enrolled' : 'Not Enrolled',
            valueColor: _student.faceEnrolled
                ? Colors.green.shade600
                : Colors.orange.shade700,
            readOnly: true,
          ),
        ]),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Text(title,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      );

  Widget _infoCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(children: children),
      );

  Widget _infoRow(IconData icon, String label, String value,
      {bool readOnly = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColorPallet.primaryBlue.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ColorPallet.primaryBlue, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                    if (readOnly) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('read-only',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 9)),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? const Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 66, color: Colors.grey.shade100);

  // ── Edit form ──────────────────────────────────────────────────────────────
  Widget _buildEditForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Editable fields card
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ]),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _fieldLabel('FULL NAME'),
              _textField(_nameCtrl, 'e.g. Ali Hassan', Icons.person_outline),
              const SizedBox(height: 14),
              _fieldLabel('ROLL NUMBER'),
              _textField(_rollCtrl, 'e.g. BSCS-F21-001', Icons.badge_outlined),
              const SizedBox(height: 14),
              _fieldLabel('EMAIL ADDRESS'),
              _textField(
                  _emailCtrl, 'e.g. ali@student.edu', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _fieldLabel('SEMESTER'),
              Consumer<AdminProvider>(
                builder: (context, provider, _) {
                  if (provider.isSemestersLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))),
                    );
                  }

                  final semestersList = provider.semesters
                      .map((s) => s.semesterNumber)
                      .toList()
                    ..sort();
                  // Fallback to ensuring current student semester exists if local list is empty
                  if (!semestersList.contains(_semesterValue)) {
                    semestersList.add(_semesterValue);
                    semestersList.sort();
                  }

                  return _dropdownField<int>(
                    value: _semesterValue,
                    items: semestersList,
                    labelBuilder: (v) => 'Semester $v',
                    onChanged: (v) => setState(() => _semesterValue = v!),
                  );
                },
              ),
              const SizedBox(height: 14),
              _fieldLabel('SECTION'),
              _dropdownField<String>(
                value: _sectionValue,
                items: _sections,
                labelBuilder: (v) => 'Section $v',
                onChanged: (v) => setState(() => _sectionValue = v!),
              ),
            ],
          ),
        ),

        // Read-only info
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(children: [
            Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Enrollment date and face enrollment status are system-managed and cannot be edited.',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 24),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : _cancelEdit,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Cancel',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPallet.primaryBlue,
                  disabledBackgroundColor:
                      ColorPallet.primaryBlue.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Save Changes',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.4)),
      );

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _dropdownField<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T?) onChanged,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          items: items
              .map((v) => DropdownMenuItem<T>(
                    value: v,
                    child: Text(labelBuilder(v)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      );
}
