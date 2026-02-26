import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/view/Admin/Semester%20Management/add_individual_semester_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IndividualSemesterManagementScreen extends StatefulWidget {
  const IndividualSemesterManagementScreen({super.key});

  @override
  State<IndividualSemesterManagementScreen> createState() =>
      _IndividualSemesterManagementScreenState();
}

class _IndividualSemesterManagementScreenState
    extends State<IndividualSemesterManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force refresh every time this screen opens
      context.read<AdminProvider>().fetchSemesters(force: true);
    });
  }

  String _formatDisplayDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _calculatePeriod(String startStr, String endStr) {
    try {
      final start = DateTime.parse(startStr);
      final end = DateTime.parse(endStr);
      final months = (end.year - start.year) * 12 + (end.month - start.month);
      return '$months Months';
    } catch (_) {
      return '—';
    }
  }

  Color _statusColor(SemesterModel sem) => sem.statusColor;

  Future<void> _openAddScreen({SemesterModel? semester}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddIndividualSemesterScreen(semester: semester),
      ),
    );
    // Refresh the list whenever create or update succeeded
    if (result == true && mounted) {
      context.read<AdminProvider>().fetchSemesters(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Semester Management',
            style: TextStyle(
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () =>
                  context.read<AdminProvider>().fetchSemesters(force: true),
            ),
          ],
        ),
        body: Consumer<AdminProvider>(
          builder: (context, admin, _) {
            // ── Loading ──────────────────────────────────────────────────
            if (admin.isSemestersLoading) {
              return const Center(
                child:
                    CircularProgressIndicator(color: ColorPallet.primaryBlue),
              );
            }

            // ── Error ────────────────────────────────────────────────────
            if (admin.semestersError != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade300, size: 52),
                      const SizedBox(height: 16),
                      Text(
                        admin.semestersError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => admin.fetchSemesters(force: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPallet.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ── Empty ────────────────────────────────────────────────────
            if (admin.semesters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No semesters found.\nTap "New Term" to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            // ── List ─────────────────────────────────────────────────────
            return RefreshIndicator(
              color: ColorPallet.primaryBlue,
              onRefresh: () => admin.fetchSemesters(force: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Term Records',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Monitor and customize academic timelines for each session independently.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: admin.semesters.length,
                      itemBuilder: (context, index) {
                        final sem = admin.semesters[index];
                        final color = _statusColor(sem);
                        return _buildSemesterCard(
                          sem,
                          color,
                          onTap: () => _openAddScreen(semester: sem),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddScreen,
          backgroundColor: ColorPallet.primaryBlue,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'New Term',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterCard(SemesterModel sem, Color color,
      {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Header row ──────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Semester ${sem.semesterNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            sem.academicSession,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(sem.statusLabel, color),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Quick info row ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickInfo(
                        Icons.auto_awesome_mosaic_rounded,
                        sem.termLabel,
                        'Type',
                      ),
                      _buildQuickInfo(
                        Icons.date_range_rounded,
                        sem.startDate.split('-')[0],
                        'Year',
                      ),
                      _buildQuickInfo(
                        Icons.access_time_filled_rounded,
                        _calculatePeriod(sem.startDate, sem.endDate),
                        'Period',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // ── Timeline row ─────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.event_note_rounded,
                        size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 5),
                    Text(
                      'Timeline: ${_formatDisplayDate(sem.startDate)} – ${_formatDisplayDate(sem.endDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: ColorPallet.primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: ColorPallet.primaryBlue.withOpacity(0.6)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: Color(0xFF334155),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
