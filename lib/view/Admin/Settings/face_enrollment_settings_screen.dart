import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FaceEnrollmentSettingsScreen extends StatefulWidget {
  const FaceEnrollmentSettingsScreen({super.key});

  @override
  State<FaceEnrollmentSettingsScreen> createState() =>
      _FaceEnrollmentSettingsScreenState();
}

class _FaceEnrollmentSettingsScreenState
    extends State<FaceEnrollmentSettingsScreen> {
  // Local date the user picks — synced from provider on init.
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Fetch remote deadline and pre-fill the picker when screen opens.
    Future.microtask(() async {
      if (!mounted) return;
      final admin = context.read<AdminProvider>();
      await admin.fetchEnrollmentDeadline();
      if (mounted && admin.enrollmentDeadline != null) {
        setState(() => _selectedDate = admin.enrollmentDeadline);
      }
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String get _formattedDate {
    if (_selectedDate == null) return 'Not set';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final d = _selectedDate!;
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_selectedDate == null) {
      _showSnackBar('Please select a deadline date first.', isError: true);
      return;
    }
    final admin = context.read<AdminProvider>();
    final success = await admin.saveEnrollmentDeadline(_selectedDate!);
    if (!mounted) return;
    if (success) {
      _showSnackBar(
        'Enrollment deadline set to $_formattedDate.',
        isError: false,
      );
    } else {
      _showSnackBar(
        admin.deadlineError ?? 'Failed to save. Please try again.',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Face Enrollment Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        body: Consumer<AdminProvider>(
          builder: (context, admin, _) {
            final isSaving = admin.isDeadlineSaving;
            final isLoading = admin.isDeadlineLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info banner ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorPallet.primaryBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ColorPallet.primaryBlue.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: ColorPallet.primaryBlue, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Students will only see the Face Enrollment screen '
                            'after login if the current date is on or before '
                            'the deadline you set here.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Section label ───────────────────────────────────────
                  _sectionLabel('ENROLLMENT WINDOW', Icons.date_range_rounded),
                  const SizedBox(height: 14),

                  // ── Date picker card ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Date for Face Enrollment',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Students cannot enroll their face after this date.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 20),

                        // Loading skeleton
                        if (isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: ColorPallet.primaryBlue,
                            ),
                          )
                        else ...[
                          Row(
                            children: [
                              // Date chip
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 18,
                                          color: _selectedDate != null
                                              ? ColorPallet.primaryBlue
                                              : Colors.grey.shade400),
                                      const SizedBox(width: 10),
                                      Text(
                                        _formattedDate,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: _selectedDate != null
                                              ? Colors.black87
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: isSaving ? null : _pickDate,
                                icon: const Icon(Icons.edit_calendar_rounded,
                                    size: 18, color: Colors.white),
                                label: const Text(
                                  'Pick',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorPallet.primaryBlue,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (_selectedDate != null) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: isSaving
                                  ? null
                                  : () =>
                                      setState(() => _selectedDate = null),
                              child: Row(
                                children: [
                                  Icon(Icons.close_rounded,
                                      size: 14, color: Colors.red.shade400),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Clear deadline',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade400,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Save button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: (isSaving || isLoading) ? null : _save,
                      icon: isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Icon(Icons.check_circle_outline,
                              color: Colors.white),
                      label: Text(
                        isSaving ? 'Saving...' : 'Save Settings',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallet.primaryBlue,
                        disabledBackgroundColor:
                            ColorPallet.primaryBlue.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, IconData icon) => Row(
        children: [
          Icon(icon, size: 16, color: ColorPallet.primaryBlue.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
}
