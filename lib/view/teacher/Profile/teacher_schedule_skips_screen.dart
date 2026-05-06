import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/core/models/timetable_period_skip_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

DateTime _parseClassDate(String ymd) {
  final p = ymd.split('-');
  if (p.length == 3) {
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (y != null && m != null && d != null) {
      return DateTime(y, m, d);
    }
  }
  return DateTime.tryParse(ymd) ?? DateTime.now();
}

/// Lists timetable period skips and allows DELETE (scheduler cancellation).
class TeacherScheduleSkipsScreen extends StatefulWidget {
  const TeacherScheduleSkipsScreen({super.key});

  @override
  State<TeacherScheduleSkipsScreen> createState() =>
      _TeacherScheduleSkipsScreenState();
}

class _TeacherScheduleSkipsScreenState extends State<TeacherScheduleSkipsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().fetchPeriodSkips();
    });
  }

  Future<void> _confirmDelete(TimetablePeriodSkipResponse skip) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove skip?'),
        content: Text(
          'Automatic attendance will apply again for period ${skip.periodId} on ${skip.classDate} unless you skip again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final p = context.read<TeacherProvider>();
    final success = await p.deletePeriodSkip(skip.id);
    if (!mounted) return;
    if (!success && p.skipsError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(p.skipsError!)),
      );
      p.clearSkipsError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Skipped periods',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacher, _) {
          if (teacher.isSkipsLoading && teacher.periodSkips.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (teacher.skipsError != null && teacher.periodSkips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      teacher.skipsError!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        teacher.clearSkipsError();
                        teacher.fetchPeriodSkips();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (teacher.periodSkips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No skipped periods in this date range.\n'
                  'Use “Skip this class” on My Schedule to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => teacher.fetchPeriodSkips(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: teacher.periodSkips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final s = teacher.periodSkips[i];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    title: Text(
                      DateFormat.yMMMEd().format(_parseClassDate(s.classDate)),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Period: ${s.periodId}'),
                          if (s.reason != null && s.reason!.trim().isNotEmpty)
                            Text(
                              s.reason!.trim(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(s),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
