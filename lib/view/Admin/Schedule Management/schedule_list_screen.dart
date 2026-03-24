import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/timetable_model.dart';
import 'package:facialtrackapp/view/Admin/Schedule%20Management/create_schedule_screen.dart';
import 'package:facialtrackapp/view/Admin/Schedule%20Management/schedule_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});
  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchTimetables();
    });
  }

  Future<void> _refresh() =>
      context.read<AdminProvider>().fetchTimetables(force: true);

  Future<void> _delete(Timetable tt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Timetable',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Delete timetable for ${tt.headerLabel} — Section ${tt.section}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final ok =
        await context.read<AdminProvider>().deleteTimetable(tt.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Timetable deleted.' : 'Failed to delete timetable.'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  Color _accentFor(int sem) {
    const colors = [
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.deepOrange,
    ];
    return colors[(sem - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: ColorPallet.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Schedule Management',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Manage weekly timetables',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: Consumer<AdminProvider>(
                builder: (context, prov, _) {
                  if (prov.isTimetablesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (prov.timetablesError != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade300, size: 48),
                          const SizedBox(height: 12),
                          Text(prov.timetablesError!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (prov.timetables.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.table_chart_outlined,
                                    size: 64,
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('No timetables yet',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.grey.shade500)),
                                const SizedBox(height: 6),
                                Text('Tap + to create your first timetable',
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: prov.timetables.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _TimetableCard(
                        tt: prov.timetables[i],
                        accent: _accentFor(prov.timetables[i].semesterNumber),
                        onDelete: () => _delete(prov.timetables[i]),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScheduleViewScreen(
                                timetable: prov.timetables[i]),
                          ),
                        ).then((_) => _refresh()),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CreateScheduleScreen()),
          ).then((_) => _refresh()),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}

// ── Timetable card ────────────────────────────────────────────────────────────
class _TimetableCard extends StatelessWidget {
  final Timetable tt;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TimetableCard({
    required this.tt,
    required this.accent,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final periods = tt.periods.where((p) => !p.isBreak).length;
    final assigned = tt.entries.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Accent strip
            Container(
              width: 6,
              height: 90,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tt.headerLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sec ${tt.section}  •  ${tt.academicSession}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      _badge('$periods Periods', accent.withOpacity(0.1),
                          accent),
                      const SizedBox(width: 8),
                      _badge('$assigned Classes',
                          Colors.green.withOpacity(0.1), Colors.green),
                    ]),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade300, size: 20),
              onPressed: onDelete,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style:
                TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}
