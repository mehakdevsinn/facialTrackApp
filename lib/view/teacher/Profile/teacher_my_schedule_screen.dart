import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/core/models/teacher_schedule_slot_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherMyScheduleScreen extends StatefulWidget {
  const TeacherMyScheduleScreen({super.key});

  @override
  State<TeacherMyScheduleScreen> createState() => _TeacherMyScheduleScreenState();
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
        ),
        body: Consumer<TeacherProvider>(
          builder: (context, teacher, _) {
            if (teacher.isScheduleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (teacher.scheduleError != null && teacher.scheduleError!.isNotEmpty) {
              return _ErrorState(
                message: teacher.scheduleError!,
                onRetry: () => context.read<TeacherProvider>().fetchMySchedule(),
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
              onRefresh: () => context.read<TeacherProvider>().fetchMySchedule(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, index) => _ScheduleTile(slot: sorted[index]),
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

class _ScheduleTile extends StatelessWidget {
  final TeacherScheduleSlotModel slot;
  const _ScheduleTile({required this.slot});

  @override
  Widget build(BuildContext context) {
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
              Text(
                '${slot.startTime} - ${slot.endTime}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
