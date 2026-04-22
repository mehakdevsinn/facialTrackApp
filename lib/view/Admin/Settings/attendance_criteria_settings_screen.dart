import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceCriteriaSettingsScreen extends StatefulWidget {
  const AttendanceCriteriaSettingsScreen({super.key});

  @override
  State<AttendanceCriteriaSettingsScreen> createState() =>
      _AttendanceCriteriaSettingsScreenState();
}

class _AttendanceCriteriaSettingsScreenState
    extends State<AttendanceCriteriaSettingsScreen> {
  double _threshold = 75;
  bool _isInitializedFromApi = false;

  int get _thresholdPercent => _threshold.round();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      await context.read<AdminProvider>().fetchAttendanceCriteria();
      if (!mounted) return;
      final fetched = context.read<AdminProvider>().attendanceCriteria;
      setState(() {
        _threshold = fetched.toDouble();
        _isInitializedFromApi = true;
      });
    });
  }

  Future<void> _save() async {
    final admin = context.read<AdminProvider>();
    final success = await admin.saveAttendanceCriteria(_thresholdPercent);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Attendance criteria set to $_thresholdPercent%.'
              : (admin.attendanceCriteriaError ??
                  'Failed to save attendance criteria.'),
        ),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
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
            'Attendance Criteria Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        body: Consumer<AdminProvider>(
          builder: (context, admin, _) {
            final isLoading = admin.isAttendanceCriteriaLoading;
            final isSaving = admin.isAttendanceCriteriaSaving;
            final canEdit = !isLoading && !isSaving;

            if (!_isInitializedFromApi && !isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _threshold = admin.attendanceCriteria.toDouble();
                  _isInitializedFromApi = true;
                });
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    const Icon(
                      Icons.info_outline_rounded,
                      color: ColorPallet.primaryBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Set the minimum attendance percentage required to '
                        'consider a student in the high attendance category.',
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
              _sectionLabel(
                'ATTENDANCE THRESHOLD',
                Icons.rule_folder_outlined,
              ),
              const SizedBox(height: 14),
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
                      'Minimum Attendance Criteria',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Students with attendance >= selected value are high '
                      'attendance. Below it are low attendance.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 20),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: ColorPallet.primaryBlue,
                        ),
                      )
                    else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.percent_rounded,
                            size: 18,
                            color: ColorPallet.primaryBlue,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Selected Criteria: $_thresholdPercent%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: ColorPallet.primaryBlue,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: ColorPallet.primaryBlue,
                        overlayColor: ColorPallet.primaryBlue.withOpacity(0.15),
                        valueIndicatorColor: ColorPallet.primaryBlue,
                        showValueIndicator: ShowValueIndicator.always,
                      ),
                      child: Slider(
                        min: 50,
                        max: 100,
                        divisions: 50,
                        value: _threshold,
                        label: '$_thresholdPercent%',
                        onChanged: canEdit ? (value) {
                          setState(() => _threshold = value);
                        } : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '50%',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        Text(
                          '100%',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: canEdit ? _save : null,
                  icon: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
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
