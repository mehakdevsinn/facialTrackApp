import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:facialtrackapp/view/teacher/Complaints/teacher_side_complain_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pills on blue header — avoids M3 [FilterChip] forcing a white surface + unreadable label.
class _ComplaintStatusTabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ComplaintStatusTabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.95),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? ColorPallet.primaryBlue : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class TeacherComplaintsInbox extends StatefulWidget {
  const TeacherComplaintsInbox({super.key});

  @override
  State<TeacherComplaintsInbox> createState() => _TeacherComplaintsInboxState();
}

class _TeacherComplaintsInboxState extends State<TeacherComplaintsInbox> {
  String _filterLabel = 'All';
  bool _loading = true;
  String? _error;
  List<ComplaintItem> _items = [];

  String? get _apiStatus {
    switch (_filterLabel) {
      case 'Pending':
        return 'pending';
      case 'Resolved':
        return 'approved';
      case 'Rejected':
        return 'rejected';
      default:
        return null;
    }
  }

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
      final list =
          await ApiManager.instance.getTeacherComplaintsInbox(status: _apiStatus);
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

  String _dateLine(ComplaintItem c) {
    final raw = c.sessionDateRaw ?? c.createdAtRaw;
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('MMM dd, yyyy').format(dt.toLocal());
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return Colors.amber;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text(
            'Complaints Inbox',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildFilterSection(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'Pending', 'Resolved', 'Rejected'].map((status) {
            final sel = _filterLabel == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ComplaintStatusTabPill(
                label: status,
                selected: sel,
                onTap: () {
                  setState(() => _filterLabel = status);
                  _load();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildList() {
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
          'No $_filterLabel complaints',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
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
          final col = _statusColor(c.status);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeacherComplaintDetailScreen(complaint: c),
                    ),
                  );
                  if (mounted) _load();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c.complainantName ?? 'Student',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: col.withOpacity(0.1),
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
                      if (c.complainantRoleLabel != null &&
                          c.complainantRoleLabel!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          c.complainantRoleLabel!,
                          style: TextStyle(
                            color: Colors.blueGrey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (c.rollNumber != null && c.rollNumber!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          c.rollNumber!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        c.courseName ?? '—',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _dateLine(c),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to view details',
                        style: TextStyle(
                          fontSize: 11,
                          color: ColorPallet.primaryBlue.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
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
