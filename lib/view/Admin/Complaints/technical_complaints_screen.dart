import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/complaint_models.dart';
import 'package:facialtrackapp/view/Admin/Complaints/technical_complaints_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pills on blue header — avoids M3 [FilterChip] white surface + unreadable label.
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

/// Admin complaints inbox. `GET /admin/complaints`
class AdminTechnicalComplaintsScreen extends StatefulWidget {
  const AdminTechnicalComplaintsScreen({super.key});

  @override
  State<AdminTechnicalComplaintsScreen> createState() =>
      _AdminTechnicalComplaintsScreenState();
}

class _AdminTechnicalComplaintsScreenState
    extends State<AdminTechnicalComplaintsScreen> {
  String _statusLabel = 'All';
  String _categoryKey = '';

  bool _loading = true;
  String? _error;
  List<ComplaintItem> _items = [];

  static Map<String, String> get _categoryOptions {
    final m = <String, String>{'': 'All Categories'};
    m.addAll(ComplaintItem.studentAdminCategoryLabels);
    m.addAll(ComplaintItem.teacherAdminCategoryLabels);
    return m;
  }

  String? get _apiStatus {
    switch (_statusLabel) {
      case 'Pending':
        return 'pending';
      case 'Resolved':
        return 'resolved';
      case 'Rejected':
        return 'rejected';
      default:
        return null;
    }
  }

  String? get _apiCategory =>
      _categoryKey.isEmpty ? null : _categoryKey;

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
      final list = await ApiManager.instance.getAdminComplaints(
        status: _apiStatus,
        category: _apiCategory,
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

  Color _statusColor(String s) {
    switch (s) {
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

  String _createdLine(ComplaintItem c) {
    final raw = c.createdAtRaw;
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('MMM dd, yyyy · hh:mm a').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text(
            'Complaints',
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
    final opts = _categoryOptions;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Pending', 'Resolved', 'Rejected'].map((s) {
                final sel = _statusLabel == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ComplaintStatusTabPill(
                    label: s,
                    selected: sel,
                    onTap: () {
                      setState(() => _statusLabel = s);
                      _load();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _categoryKey.isEmpty ? '' : _categoryKey,
                isExpanded: true,
                dropdownColor: ColorPallet.primaryBlue,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                items: opts.entries
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(
                          e.value,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _categoryKey = val ?? '');
                  _load();
                },
              ),
            ),
          ),
        ],
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
          'No complaints found',
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
          final catLabel = c.categoryDisplayLabel ?? 'Attendance';
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
                      builder: (_) =>
                          TechnicalComplaintDetailScreen(complaintId: c.id),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.complainantName ?? '—',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  c.complainantRoleLabel ?? '',
                                  style: TextStyle(
                                    color: c.complainantRole == 'teacher'
                                        ? Colors.deepPurple
                                        : Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 4),
                      Text(
                        catLabel,
                        style: const TextStyle(
                          color: ColorPallet.primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _createdLine(c),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
