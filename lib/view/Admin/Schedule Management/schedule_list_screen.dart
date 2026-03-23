import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/core/models/timetable_model.dart';
import 'package:facialtrackapp/utils/dummy/schedule_dummy_data.dart';
import 'package:facialtrackapp/view/Admin/Schedule%20Management/create_schedule_screen.dart';
import 'package:facialtrackapp/view/Admin/Schedule%20Management/schedule_view_screen.dart';
import 'package:flutter/material.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  List<Timetable> _timetables = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => setState(() => _timetables = ScheduleDummyData.all);

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Timetable',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'This timetable and all its entries will be removed. Are you sure?',
            style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ScheduleDummyData.deleteTimetable(id);
      _reload();
    }
  }

  Color _semesterColor(int sem) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
      const Color(0xFF22C55E),
      const Color(0xFFEF4444),
      ColorPallet.primaryBlue,
    ];
    return colors[(sem - 1).clamp(0, colors.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _timetables.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: ColorPallet.primaryBlue,
                      onRefresh: () async => _reload(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                        itemCount: _timetables.length,
                        itemBuilder: (_, i) =>
                            _buildTimetableCard(_timetables[i]),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Timetable',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateScheduleScreen()),
          ).then((_) => _reload()),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 28),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              const Text(
                'Schedule Management',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_view_week_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_timetables.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17),
                    ),
                    Text(
                      'Timetable${_timetables.length == 1 ? '' : 's'} configured',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableCard(Timetable tt) {
    final color = _semesterColor(tt.semesterNumber);
    final periodCount = tt.periods.where((p) => !p.isBreak).length;
    final entryCount = tt.entries.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScheduleViewScreen(timetable: tt)),
      ).then((_) => _reload()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left accent
            Container(
              width: 6,
              height: 82,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Semester circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'S${tt.semesterNumber}',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester ${tt.semesterNumber} — Section ${tt.section}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Session: ${tt.academicSession}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chip(
                          Icons.access_time_rounded,
                          '$periodCount Period${periodCount == 1 ? '' : 's'}',
                          color),
                      const SizedBox(width: 6),
                      _chip(
                          Icons.grid_on_rounded,
                          '$entryCount Class${entryCount == 1 ? '' : 'es'}',
                          color),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade300, size: 20),
              onPressed: () => _delete(tt.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorPallet.primaryBlue.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_view_week_rounded,
                  size: 56, color: ColorPallet.primaryBlue.withOpacity(0.4)),
            ),
            const SizedBox(height: 18),
            Text('No timetables yet',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Tap the button below to create one',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      );
}
