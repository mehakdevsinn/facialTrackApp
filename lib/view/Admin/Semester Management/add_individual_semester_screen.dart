import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddIndividualSemesterScreen extends StatefulWidget {
  /// Pass a [semester] to pre-fill all fields for editing.
  /// Leave null for the "Create New" flow.
  final SemesterModel? semester;

  const AddIndividualSemesterScreen({super.key, this.semester});

  bool get isEditing => semester != null;

  @override
  State<AddIndividualSemesterScreen> createState() =>
      _AddIndividualSemesterScreenState();
}

class _AddIndividualSemesterScreenState
    extends State<AddIndividualSemesterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _sessionCtrl;
  late String _selectedSemester;
  late String _termType;
  late String _operationalStatus;
  late DateTime _startDate;
  late DateTime _endDate;

  final List<String> _semesterNumbers = List.generate(8, (i) => '${i + 1}');

  @override
  void initState() {
    super.initState();
    final s = widget.semester;
    _sessionCtrl = TextEditingController(
      text: s?.academicSession ?? '',
    );
    _selectedSemester = s != null ? '${s.semesterNumber}' : '1';
    // API values are lowercase; display values are capitalised
    _termType = s?.termType ?? 'spring';
    _operationalStatus = s?.operationalStatus ?? 'upcoming';
    _startDate = s != null ? DateTime.parse(s.startDate) : DateTime.now();
    _endDate = s != null
        ? DateTime.parse(s.endDate)
        : DateTime.now().add(const Duration(days: 120));
  }

  @override
  void dispose() {
    _sessionCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDisplay(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ColorPallet.primaryBlue,
            onPrimary: Colors.white,
            onSurface: ColorPallet.darkGray,
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
    if (!_formKey.currentState!.validate()) return;
    if (!_endDate.isAfter(_startDate)) {
      _showError('End date must be after start date.');
      return;
    }

    final admin = context.read<AdminProvider>();
    bool success;

    if (widget.isEditing) {
      // ── UPDATE existing semester ─────────────────────────────────────────
      success = await admin.updateSemester(
        semesterId: widget.semester!.id,
        semesterNumber: int.parse(_selectedSemester),
        academicSession: _sessionCtrl.text.trim(),
        termType: _termType,
        operationalStatus: _operationalStatus,
        startDate: _fmt(_startDate),
        endDate: _fmt(_endDate),
      );
    } else {
      // ── CREATE new semester ──────────────────────────────────────────────
      success = await admin.createSemester(
        semesterNumber: int.parse(_selectedSemester),
        academicSession: _sessionCtrl.text.trim(),
        termType: _termType,
        operationalStatus: _operationalStatus,
        startDate: _fmt(_startDate),
        endDate: _fmt(_endDate),
      );
    }

    if (!mounted) return;
    if (success) {
      // Pop with true so the list screen knows to refresh
      Navigator.pop(context, true);
    } else {
      _showError(admin.errorMessage ?? 'Something went wrong.');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Edit Semester' : 'Create New Semester',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Identification ───────────────────────────────────
                _sectionHeader('Identification', Icons.fingerprint_rounded),
                _card([
                  _textField(
                    controller: _sessionCtrl,
                    label: 'Academic Session *',
                    hint: 'e.g. 2021-2025',
                    icon: Icons.history_edu_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _dropdown<String>(
                          value: _selectedSemester,
                          label: 'No.',
                          icon: Icons.layers_rounded,
                          items: _semesterNumbers
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedSemester = v!),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 6,
                        child: _dropdown<String>(
                          value: _termType,
                          label: 'Term Type',
                          icon: Icons.category_rounded,
                          items: const [
                            DropdownMenuItem(
                                value: 'spring', child: Text('Spring')),
                            DropdownMenuItem(
                                value: 'fall', child: Text('Fall')),
                            DropdownMenuItem(
                                value: 'summer', child: Text('Summer')),
                          ],
                          onChanged: (v) => setState(() => _termType = v!),
                        ),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 30),

                // ── Timeline & Status ────────────────────────────────
                _sectionHeader(
                    'Timeline & Status', Icons.shutter_speed_rounded),
                _card([
                  _dropdown<String>(
                    value: _operationalStatus,
                    label: 'Operating Status',
                    icon: Icons.info_outline_rounded,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'upcoming', child: Text('Upcoming')),
                      DropdownMenuItem(
                          value: 'completed', child: Text('Completed')),
                    ],
                    onChanged: (v) => setState(() => _operationalStatus = v!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _datePicker(
                          label: 'Start',
                          date: _startDate,
                          onTap: () => _selectDate(true),
                          icon: Icons.event_available_rounded,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _datePicker(
                          label: 'End',
                          date: _endDate,
                          onTap: () => _selectDate(false),
                          icon: Icons.event_busy_rounded,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 40),

                // ── Submit button ────────────────────────────────────
                Consumer<AdminProvider>(
                  builder: (ctx, admin, _) {
                    final isSubmitting = admin.isLoading;
                    return Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: isSubmitting
                              ? [Colors.grey.shade400, Colors.grey.shade400]
                              : [
                                  ColorPallet.primaryBlue,
                                  const Color(0xFF4F46E5),
                                ],
                        ),
                        boxShadow: isSubmitting
                            ? []
                            : [
                                BoxShadow(
                                  color:
                                      ColorPallet.primaryBlue.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
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
                          isSubmitting
                              ? (widget.isEditing
                                  ? 'Updating...'
                                  : 'Creating...')
                              : (widget.isEditing
                                  ? 'UPDATE SEMESTER'
                                  : 'INITIALIZE SEMESTER'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared widget helpers ──────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Row(
          children: [
            Icon(icon,
                size: 18, color: ColorPallet.primaryBlue.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      );

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: ColorPallet.primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFFBFBFE),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
        ),
      );

  Widget _dropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) =>
      DropdownButtonFormField<T>(
        value: value,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: const Color(0xFFFBFBFE),
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        ),
      );

  Widget _datePicker({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueGrey.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _formatDisplay(date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: ColorPallet.darkGray,
                ),
              ),
            ],
          ),
        ),
      );
}
