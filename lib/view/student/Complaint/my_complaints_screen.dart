import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _StudentComplaintTab { all, pending, resolved, rejected }

/// `GET /students/complaints/all` with status filters.
class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  _StudentComplaintTab _tab = _StudentComplaintTab.all;
  bool _loading = true;
  String? _error;
  List<ComplaintItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<ComplaintItem> list;
      switch (_tab) {
        case _StudentComplaintTab.all:
          list = await ApiManager.instance.getStudentComplaintsAll();
          break;
        case _StudentComplaintTab.pending:
          list = await ApiManager.instance.getStudentComplaintsAll(status: 'pending');
          break;
        case _StudentComplaintTab.rejected:
          list = await ApiManager.instance.getStudentComplaintsAll(status: 'rejected');
          break;
        case _StudentComplaintTab.resolved:
          list = await ApiManager.instance.getStudentComplaintsResolvedMerged();
          break;
      }
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
      case 'approved':
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String? _formatApiDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('MMM dd, yyyy').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Complaints',
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
                  _tabChip('All', _StudentComplaintTab.all),
                  _tabChip('Pending', _StudentComplaintTab.pending),
                  _tabChip('Resolved', _StudentComplaintTab.resolved),
                  _tabChip('Rejected', _StudentComplaintTab.rejected),
                ],
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _tabChip(String label, _StudentComplaintTab tab) {
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
        selectedColor: ColorPallet.primaryBlue.withOpacity(0.2),
        checkmarkColor: ColorPallet.primaryBlue,
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
      return _buildEmptyState();
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) => _buildComplaintCard(_items[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No complaints found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complaints you submit will appear here.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintItem c) {
    final cat = c.categoryDisplayLabel;
    final sessionD = _formatApiDate(c.sessionDateRaw);
    final created = _formatApiDate(c.createdAtRaw) ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (cat != null)
                Expanded(
                  child: Text(
                    cat,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (c.courseName != null && c.courseName!.isNotEmpty)
                Expanded(
                  child: Text(
                    c.courseName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Text(
                    'Attendance complaint',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeColor(c.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _badgeColor(c.status)),
                ),
                child: Text(
                  c.badgeLabel,
                  style: TextStyle(
                    color: _badgeColor(c.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (c.courseName != null &&
              c.courseName!.isNotEmpty &&
              cat != null) ...[
            const SizedBox(height: 4),
            Text(
              c.courseName!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
          if (sessionD != null) ...[
            const SizedBox(height: 4),
            Text(
              'Session date: $sessionD',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            c.reason,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
          if (c.reviewNotes != null && c.reviewNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Response: ${c.reviewNotes}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
          const Divider(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Submitted: $created',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
