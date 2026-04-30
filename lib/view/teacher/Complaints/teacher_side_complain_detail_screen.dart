import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeacherComplaintDetailScreen extends StatefulWidget {
  final ComplaintItem complaint;

  const TeacherComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<TeacherComplaintDetailScreen> createState() =>
      _TeacherComplaintDetailScreenState();
}

class _TeacherComplaintDetailScreenState
    extends State<TeacherComplaintDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _busy = false;

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('MMM dd, yyyy · hh:mm a').format(dt.toLocal());
  }

  Future<void> _approve() async {
    setState(() => _busy = true);
    try {
      await ApiManager.instance.postTeacherComplaintApprove(
        widget.complaint.id,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Complaint approved'),
          backgroundColor: Colors.green,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rejection notes are required so the student knows why.'),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ApiManager.instance.postTeacherComplaintReject(
        widget.complaint.id,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Complaint rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;
    final pending = c.isPending;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text(
            'Complaint Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: ColorPallet.primaryBlue.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        color: ColorPallet.primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.complainantName ?? '—',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (c.complainantRoleLabel != null &&
                              c.complainantRoleLabel!.isNotEmpty)
                            Text(
                              c.complainantRoleLabel!,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          if (c.rollNumber != null && c.rollNumber!.isNotEmpty)
                            Text(
                              c.rollNumber!,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'COMPLAINT OVERVIEW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Course', c.courseName ?? '—'),
                    if (c.complainantRoleLabel != null &&
                        c.complainantRoleLabel!.trim().isNotEmpty)
                      _buildDetailRow('Student', c.complainantRoleLabel!),
                    _buildDetailRow('Session date', _fmt(c.sessionDateRaw)),
                    _buildDetailRow('Submitted', _fmt(c.createdAtRaw)),
                    const Divider(height: 30),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.reason,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                    if (c.reviewNotes != null && c.reviewNotes!.trim().isNotEmpty) ...[
                      const Divider(height: 24),
                      Text(
                        'Review notes: ${c.reviewNotes}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 25),
              if (pending) ...[
                const Text(
                  'TAKE ACTION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Optional when approving. Required when rejecting.',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _busy ? null : _approve,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Approve',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _busy ? null : _reject,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Reject',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else
                _buildOutcomeStamp(c.status),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeStamp(String status) {
    final ok = status == 'approved';
    final label = ok ? 'APPROVED' : 'REJECTED';
    final color = ok ? Colors.green : Colors.red;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
