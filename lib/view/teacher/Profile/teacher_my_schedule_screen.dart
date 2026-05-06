import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/core/models/teacher_schedule_slot_model.dart';
import 'package:facialtrackapp/core/utils/teacher_session_display.dart';
import 'package:facialtrackapp/view/teacher/Profile/teacher_schedule_skips_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TeacherMyScheduleScreen extends StatefulWidget {
  const TeacherMyScheduleScreen({super.key});

  @override
  State<TeacherMyScheduleScreen> createState() =>
      _TeacherMyScheduleScreenState();
}

class _TeacherMyScheduleScreenState extends State<TeacherMyScheduleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<TeacherProvider>().fetchMySchedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          title: const Text(
            'My Schedule',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Skipped periods',
              icon: const Icon(Icons.event_busy_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherScheduleSkipsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<TeacherProvider>(
          builder: (context, teacher, _) {
            if (teacher.isScheduleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (teacher.scheduleError != null &&
                teacher.scheduleError!.isNotEmpty) {
              return _ErrorState(
                message: teacher.scheduleError!,
                onRetry: () =>
                    context.read<TeacherProvider>().fetchMySchedule(),
              );
            }

            if (teacher.mySchedule.isEmpty) {
              return const _EmptyState();
            }

            final sorted = [...teacher.mySchedule]..sort((a, b) {
                final dayCmp = _dayOrder(a.day).compareTo(_dayOrder(b.day));
                if (dayCmp != 0) return dayCmp;
                return a.startTime.compareTo(b.startTime);
              });

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<TeacherProvider>().fetchMySchedule(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, index) => _ScheduleTile(
                  slot: sorted[index],
                  onSkip: () => _showSkipPeriodSheet(context, sorted[index]),
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: sorted.length,
              ),
            );
          },
        ),
      ),
    );
  }

  int _dayOrder(String day) {
    const order = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };
    return order[day] ?? 99;
  }
}

void _showSkipPeriodSheet(
    BuildContext context, TeacherScheduleSlotModel slot) {
  if (slot.timetableId.isEmpty || slot.periodId.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'This slot is missing timetable or period data. Cannot skip.'),
      ),
    );
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(ctx).bottom,
      ),
      child: _SkipPeriodSheet(slot: slot),
    ),
  );
}

bool _validSkipDate(DateTime d, TeacherScheduleSlotModel slot) {
  final targetWd = pktSlotDayLabelToWeekday(slot.day);
  final today = pktCalendarToday();
  if (d.isBefore(today) || !pktIsWeekday(d)) return false;
  if (targetWd != null && d.weekday != targetWd) return false;
  return true;
}

DateTime _defaultSkipDate(TeacherScheduleSlotModel slot) {
  final today = pktCalendarToday();
  if (_validSkipDate(today, slot)) return today;
  var d = today.add(const Duration(days: 1));
  for (var i = 0; i < 400; i++) {
    if (_validSkipDate(d, slot)) return d;
    d = d.add(const Duration(days: 1));
  }
  return today;
}

class _SkipPeriodSheet extends StatefulWidget {
  final TeacherScheduleSlotModel slot;
  const _SkipPeriodSheet({required this.slot});

  @override
  State<_SkipPeriodSheet> createState() => _SkipPeriodSheetState();
}

class _SkipPeriodSheetState extends State<_SkipPeriodSheet> {
  late DateTime _classDate;
  final _reasonCtrl = TextEditingController();
  bool _submitting = false;

  TeacherScheduleSlotModel get slot => widget.slot;

  @override
  void initState() {
    super.initState();
    _classDate = _defaultSkipDate(slot);
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = pktCalendarToday();
    final last = today.add(const Duration(days: 180));
    final picked = await showDatePicker(
      context: context,
      initialDate: _classDate,
      firstDate: today,
      lastDate: last,
      selectableDayPredicate: (d) => _validSkipDate(d, slot),
    );
    if (picked != null && mounted) {
      setState(() => _classDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await context.read<TeacherProvider>().createPeriodSkip(
            timetableId: slot.timetableId,
            classDateYmd: formatPktYyyyMmDd(_classDate),
            periodId: slot.periodId,
            reason: _reasonCtrl.text,
          );
      if (!mounted) return;
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('This period is skipped for the selected day.'),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiConflictException {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'This period is already skipped for that date.',
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save skip. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Skip this class',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stops automatic attendance for this timetable cell on one calendar day only '
            '(Asia/Karachi). Students are not bulk-marked absent for that slot.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${slot.courseCode} · ${slot.courseName}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Text(
            '${slot.day} · ${slot.periodLabel} · ${slot.displayTime}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Class date'),
            subtitle: Text(
              DateFormat.yMMMEd().format(_classDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: _pickDate,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonCtrl,
            maxLines: 3,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'e.g. On leave, conference…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Confirm skip'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final TeacherScheduleSlotModel slot;
  final VoidCallback onSkip;

  const _ScheduleTile({
    required this.slot,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final canSkip =
        slot.timetableId.isNotEmpty && slot.periodId.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slot.day,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${slot.startTime} - ${slot.endTime}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${slot.courseCode} - ${slot.courseName}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Section ${slot.section} • ${slot.displaySemester}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            slot.academicSession,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: canSkip ? onSkip : null,
              icon: const Icon(Icons.event_busy_outlined, size: 18),
              label: const Text('Skip this class'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No schedule slots found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 52),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
