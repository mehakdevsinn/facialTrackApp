import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditSemesterScreen extends StatefulWidget {
  /// Pass a [semester] to pre-fill the form for editing (future use).
  /// Leave null to show a blank "Add New" form.
  final SemesterModel? semester;

  const AddEditSemesterScreen({super.key, this.semester});

  bool get isEditing => semester != null;

  @override
  State<AddEditSemesterScreen> createState() => _AddEditSemesterScreenState();
}

class _AddEditSemesterScreenState extends State<AddEditSemesterScreen> {
  // ── Form controllers & state ───────────────────────────────────────────────
  late final TextEditingController _semesterNumberCtrl;
  late final TextEditingController _academicSessionCtrl;
  late String _termType;
  late String _operationalStatus;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final s = widget.semester;
    _semesterNumberCtrl = TextEditingController(
      text: s != null ? s.semesterNumber.toString() : '',
    );
    _academicSessionCtrl = TextEditingController(
      text: s?.academicSession ?? '',
    );
    _termType = s?.termType ?? 'spring';
    _operationalStatus = s?.operationalStatus ?? 'upcoming';
    _startDate = s != null ? DateTime.parse(s.startDate) : DateTime.now();
    _endDate = s != null
        ? DateTime.parse(s.endDate)
        : DateTime.now().add(const Duration(days: 120));
  }

  @override
  void dispose() {
    _semesterNumberCtrl.dispose();
    _academicSessionCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ColorPallet.primaryBlue,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 120));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _submit() async {
    // ── Edit mode: update API not yet available ────────────────────────────
    if (widget.isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            const Text('⚠️ Update endpoint not yet available from backend.'),
        backgroundColor: Colors.amber.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    // ── Create mode ────────────────────────────────────────────────────────
    final numText = _semesterNumberCtrl.text.trim();
    final session = _academicSessionCtrl.text.trim();

    if (numText.isEmpty || int.tryParse(numText) == null) {
      _showError('Please enter a valid semester number (e.g. 8).');
      return;
    }
    if (session.isEmpty) {
      _showError('Please enter the academic session (e.g. 2021-2025).');
      return;
    }
    if (!_endDate.isAfter(_startDate)) {
      _showError('End date must be after start date.');
      return;
    }

    final admin = context.read<AdminProvider>();
    final success = await admin.createSemester(
      semesterNumber: int.parse(numText),
      academicSession: session,
      termType: _termType,
      operationalStatus: _operationalStatus,
      startDate: _fmt(_startDate),
      endDate: _fmt(_endDate),
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context, admin.semesters.first);
    } else {
      _showError(admin.errorMessage ?? 'Something went wrong.');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Semester' : 'New Semester',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Edit mode info banner ──────────────────────────────────
            if (widget.isEditing)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'View only — semester update API coming soon.',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _sectionTitle('Semester Details'),
            const SizedBox(height: 12),
            _card([
              _field(
                controller: _semesterNumberCtrl,
                label: 'Semester Number *',
                hint: '8',
                icon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _academicSessionCtrl,
                label: 'Academic Session *',
                hint: '2021-2025',
                icon: Icons.date_range_outlined,
              ),
              const SizedBox(height: 16),
              _dropdown<String>(
                label: 'Term Type',
                value: _termType,
                items: const [
                  DropdownMenuItem(value: 'spring', child: Text('Spring')),
                  DropdownMenuItem(value: 'fall', child: Text('Fall')),
                  DropdownMenuItem(value: 'summer', child: Text('Summer')),
                ],
                onChanged: (v) => setState(() => _termType = v!),
              ),
            ]),
            const SizedBox(height: 24),
            _sectionTitle('Duration & Status'),
            const SizedBox(height: 12),
            _card([
              Row(
                children: [
                  Expanded(
                    child: _datePicker(
                        label: 'Start Date',
                        date: _startDate,
                        onTap: () => _pickDate(isStart: true)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _datePicker(
                        label: 'End Date',
                        date: _endDate,
                        onTap: () => _pickDate(isStart: false)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _dropdown<String>(
                label: 'Operational Status',
                value: _operationalStatus,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Completed')),
                ],
                onChanged: (v) => setState(() => _operationalStatus = v!),
              ),
            ]),
            const SizedBox(height: 32),
            Consumer<AdminProvider>(
              builder: (ctx, admin, _) {
                final isSubmitting = admin.isLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _submit,
                    icon: isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.check_circle_outline,
                            color: Colors.white),
                    label: Text(
                      isSubmitting ? 'Creating...' : 'Create Semester',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallet.primaryBlue,
                      disabledBackgroundColor:
                          ColorPallet.primaryBlue.withOpacity(0.7),
                      elevation: 5,
                      shadowColor: ColorPallet.primaryBlue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Reusable widgets ───────────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: ColorPallet.primaryBlue,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: ColorPallet.primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      );

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) =>
      DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: ColorPallet.primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items,
        onChanged: onChanged,
      );

  Widget _datePicker({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today,
                color: ColorPallet.primaryBlue, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          child: Text(
            _fmt(date),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
}
