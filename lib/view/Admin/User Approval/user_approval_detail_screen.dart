import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/pending_student_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserApprovalDetailScreen extends StatefulWidget {
  final PendingStudentModel student;
  final VoidCallback onApprove;
  final Future<void> Function(String note) onRejectWithNote;

  const UserApprovalDetailScreen({
    super.key,
    required this.student,
    required this.onApprove,
    required this.onRejectWithNote,
  });

  @override
  State<UserApprovalDetailScreen> createState() =>
      _UserApprovalDetailScreenState();
}

class _UserApprovalDetailScreenState extends State<UserApprovalDetailScreen> {
  Future<void> _handleApprove() async {
    widget.onApprove();
    // onApprove fires async work in the parent. Poll the provider until
    // the student is no longer in the approving set, then pop.
    final admin = context.read<AdminProvider>();
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return admin.isStudentApproving(widget.student.id);
    });
    if (mounted) Navigator.pop(context);
  }

  /// Shows a bottom sheet to collect a REQUIRED rejection note,
  /// then calls [widget.onRejectWithNote] and pops the screen.
  Future<void> _handleReject() async {
    final ctrl = TextEditingController();
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          String? errorText;

          void onConfirm() {
            if (ctrl.text.trim().isEmpty) {
              setState(
                  () => errorText = 'Please enter a reason for rejection.');
              return;
            }
            Navigator.pop(ctx, ctrl.text.trim());
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Reject ${widget.student.fullName}?',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    const Text('*',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'A reason is required before rejecting.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  maxLines: 3,
                  onChanged: (_) {
                    if (errorText != null) {
                      setState(() => errorText = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Reason for rejection',
                    errorText: errorText,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Confirm Reject',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (note == null || !mounted) return;
    await widget.onRejectWithNote(note);
    if (mounted) Navigator.pop(context);
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
          title: const Text(
            'Student Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── Profile header ───────────────────────────────────
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    _DetailItem(
                        Icons.email_outlined, 'Email', widget.student.email),
                    _DetailItem(Icons.badge_outlined, 'Roll Number',
                        widget.student.rollNumber),
                    _DetailItem(Icons.business_outlined, 'Department',
                        widget.student.department),
                    _DetailItem(Icons.school_outlined, 'Semester',
                        widget.student.semester),
                    _DetailItem(Icons.group_outlined, 'Section',
                        widget.student.section),
                    _DetailItem(Icons.event_note_outlined, 'Registered On',
                        widget.student.formattedDate),

                    const SizedBox(height: 40),

                    // ── Action buttons ────────────────────────
                    Consumer<AdminProvider>(
                      builder: (ctx, admin, _) {
                        final isApproving =
                            admin.isStudentApproving(widget.student.id);
                        final isRejecting =
                            admin.isStudentRejecting(widget.student.id);
                        final isBusy = isApproving || isRejecting;
                        return Row(
                          children: [
                            // Approve
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      Colors.green.withOpacity(0.5),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  elevation: 4,
                                  shadowColor: Colors.green.withOpacity(0.3),
                                ),
                                onPressed: isBusy ? null : _handleApprove,
                                icon: isApproving
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : const Icon(Icons.check_circle_outline),
                                label: Text(
                                  isApproving ? 'Approving…' : 'Approve',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Reject
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(
                                      color: Colors.red, width: 2),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: isBusy ? null : _handleReject,
                                icon: isRejecting
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            color: Colors.red, strokeWidth: 2))
                                    : const Icon(Icons.cancel_outlined),
                                label: Text(
                                  isRejecting ? 'Rejecting…' : 'Reject',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: ColorPallet.primaryBlue.withOpacity(0.1),
              child: Text(
                widget.student.initials,
                style: const TextStyle(
                  color: ColorPallet.primaryBlue,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Name
          Text(
            widget.student.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          // Role chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Student',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Pending badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PENDING APPROVAL',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail row widget ────────────────────────────────────────────────────────
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _DetailItem(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: ColorPallet.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: ColorPallet.primaryBlue, size: 24),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
}
