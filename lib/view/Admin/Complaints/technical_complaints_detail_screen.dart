import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Admin complaint detail: `GET /admin/complaints/{id}`, resolve / reject when pending.
class TechnicalComplaintDetailScreen extends StatefulWidget {
  final String complaintId;

  const TechnicalComplaintDetailScreen({
    super.key,
    required this.complaintId,
  });

  @override
  State<TechnicalComplaintDetailScreen> createState() =>
      _TechnicalComplaintDetailScreenState();
}

class _TechnicalComplaintDetailScreenState
    extends State<TechnicalComplaintDetailScreen> {
  final TextEditingController _noteController = TextEditingController();

  bool _loading = true;
  bool _busy = false;
  String? _error;
  ComplaintItem? _detail;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('MMM dd, yyyy · hh:mm a').format(dt.toLocal());
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d =
          await ApiManager.instance.getAdminComplaint(widget.complaintId);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _detail = null;
        _loading = false;
      });
    }
  }

  Future<void> _resolve() async {
    setState(() => _busy = true);
    try {
      await ApiManager.instance.postAdminComplaintResolve(
        widget.complaintId,
        reviewNotes: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Complaint resolved'),
          backgroundColor: Colors.green,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    try {
      await ApiManager.instance.postAdminComplaintReject(
        widget.complaintId,
        reviewNotes: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text(
            'Complaint details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _fetch,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildBody(_detail!),
      ),
    );
  }

  Widget _buildBody(ComplaintItem c) {
    final cat = c.categoryDisplayLabel ?? (c.category ?? '—');
    final roll = c.rollNumber?.isNotEmpty == true ? c.rollNumber! : '—';
    final roleLine = [
      if (c.complainantRoleLabel != null && c.complainantRoleLabel!.isNotEmpty)
        c.complainantRoleLabel,
      if (roll != '—') 'Roll: $roll',
    ].join(' · ');

    return SingleChildScrollView(
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
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.orange,
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
                      if (roleLine.isNotEmpty)
                        Text(
                          roleLine,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
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
            'DETAILS',
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
                _buildDetailRow('Category', cat),
                if (c.courseName != null && c.courseName!.isNotEmpty)
                  _buildDetailRow('Course', c.courseName!),
                if (c.sessionDateRaw != null && c.sessionDateRaw!.isNotEmpty)
                  _buildDetailRow('Session', _fmt(c.sessionDateRaw)),
                _buildDetailRow('Submitted', _fmt(c.createdAtRaw)),
                _buildDetailRow('Status', c.badgeLabel),
                if (c.reviewedAtRaw != null && c.reviewedAtRaw!.isNotEmpty)
                  _buildDetailRow('Reviewed', _fmt(c.reviewedAtRaw)),
                if (c.reviewNotes != null && c.reviewNotes!.trim().isNotEmpty) ...[
                  const Divider(height: 30),
                  const Text(
                    'Existing review notes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.reviewNotes!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
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
              ],
            ),
          ),
          const SizedBox(height: 25),
          if (c.isPending) ...[
            const Text(
              'ADMIN RESPONSE',
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
                    controller: _noteController,
                    maxLines: 4,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      hintText: 'Optional review notes…',
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
                          onPressed: _busy ? null : _resolve,
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
                            'Fix implemented',
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
                            'Dismiss issue',
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
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: c.isRejected ? Colors.red : Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  c.badgeLabel,
                  style: TextStyle(
                    color: c.isRejected ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 30),
        ],
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: ColorPallet.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
