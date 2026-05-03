import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:facialtrackapp/core/utils/student_report_datetime.dart';
import 'package:flutter/material.dart';

enum _TeacherMyTab { all, pending, resolved, rejected }

/// `GET /teachers/complaints/submitted` — reports this teacher filed to admin.
class TeacherMyComplaintsScreen extends StatefulWidget {
  const TeacherMyComplaintsScreen({super.key});

  @override
  State<TeacherMyComplaintsScreen> createState() =>
      _TeacherMyComplaintsScreenState();
}

class _TeacherMyComplaintsScreenState extends State<TeacherMyComplaintsScreen> {
  _TeacherMyTab _tab = _TeacherMyTab.all;
  bool _loading = true;
  String? _error;
  List<ComplaintItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? get _apiStatus {
    switch (_tab) {
      case _TeacherMyTab.pending:
        return 'pending';
      case _TeacherMyTab.resolved:
        return 'resolved';
      case _TeacherMyTab.rejected:
        return 'rejected';
      case _TeacherMyTab.all:
        return null;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiManager.instance.getTeacherComplaintsSubmitted(
        status: _apiStatus,
      );
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _items = [];
        _loading = false;
      });
    }
  }

  Color _badgeColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final u = parseReportToUtcInstant(raw);
    if (u == null) return raw.trim();
    return formatPktDateCard(u);
  }

  Widget _tabChip(String label, _TeacherMyTab tab) {
    final sel = _tab == tab;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) {
          setState(() => _tab = tab);
          _load();
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: ColorPallet.primaryBlue.withOpacity(0.18),
        checkmarkColor: ColorPallet.primaryBlue,
        side: BorderSide(
          color: sel ? ColorPallet.primaryBlue : Colors.grey.shade400,
        ),
        labelStyle: TextStyle(
          color: sel ? ColorPallet.primaryBlue : Colors.grey.shade800,
          fontWeight: sel ? FontWeight.bold : FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My complaints',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tabChip('All', _TeacherMyTab.all),
                  _tabChip('Pending', _TeacherMyTab.pending),
                  _tabChip('Resolved', _TeacherMyTab.resolved),
                  _tabChip('Rejected', _TeacherMyTab.rejected),
                ],
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No complaints in this tab',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final c = _items[index];
          final cat = c.categoryDisplayLabel ?? 'Report to admin';
          final created = _formatDate(c.createdAtRaw) ?? '—';
          final col = _badgeColor(c.status);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TeacherSubmittedComplaintDetailScreen(complaint: c),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  created,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to view details',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorPallet.primaryBlue.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: col.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c.badgeLabel,
                          style: TextStyle(
                            color: col,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TeacherSubmittedComplaintDetailScreen extends StatelessWidget {
  final ComplaintItem complaint;

  const TeacherSubmittedComplaintDetailScreen({
    super.key,
    required this.complaint,
  });

  String _fmt(String? raw) => formatPktDateTimeLineFromApiString(raw);

  @override
  Widget build(BuildContext context) {
    final c = complaint;
    final cat = c.categoryDisplayLabel ?? '—';
    return Scaffold(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Category', cat),
                  _row('Status', c.badgeLabel),
                  _row('Submitted', _fmt(c.createdAtRaw)),
                  if (c.reviewedAtRaw != null && c.reviewedAtRaw!.isNotEmpty)
                    _row('Reviewed', _fmt(c.reviewedAtRaw)),
                  const Divider(height: 28),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    const Divider(height: 28),
                    const Text(
                      'Admin response',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              k,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
