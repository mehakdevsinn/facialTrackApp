import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/core/models/timetable_model.dart';
import 'package:facialtrackapp/view/Admin/Schedule%20Management/schedule_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateScheduleScreen extends StatefulWidget {
  const CreateScheduleScreen({super.key});
  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  int _step = 1;

  // Step 1
  SemesterModel? _selectedSemester;
  String _section = 'A';

  // Step 2
  final List<_SlotConfig> _slots = [];
  bool _breakAdded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchSemesters();
    });
  }


  bool get _hasDuplicate {
    if (_selectedSemester == null) return false;
    final prov = context.read<AdminProvider>();
    return prov.timetables.any((t) =>
        t.semesterId == _selectedSemester!.id && t.section == _section);
  }

  void _addPeriod() {
    final last = _slots.lastWhere((s) => !s.isBreak,
        orElse: () => _SlotConfig(
            isBreak: false,
            start: const TimeOfDay(hour: 8, minute: 0),
            end: const TimeOfDay(hour: 9, minute: 0)));
    setState(() =>
        _slots.add(_SlotConfig(isBreak: false, start: last.end, end: last.end)));
  }

  void _addBreak() {
    setState(() {
      _breakAdded = true;
      _slots.add(_SlotConfig(
          isBreak: true,
          start: const TimeOfDay(hour: 11, minute: 0),
          end: const TimeOfDay(hour: 11, minute: 20)));
    });
  }

  Future<void> _pickTime(int i, bool isStart) async {
    final slot = _slots[i];
    final initial = isStart ? slot.start : slot.end;
    final picked =
        await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      _slots[i] = isStart
          ? _slots[i].copyWith(start: picked)
          : _slots[i].copyWith(end: picked);
    });
  }

  void _removeSlot(int i) {
    setState(() {
      if (_slots[i].isBreak) _breakAdded = false;
      _slots.removeAt(i);
    });
  }

  List<PeriodSlot> _buildPeriods() {
    int pNum = 1;
    return _slots.map((s) {
      if (s.isBreak) {
        return PeriodSlot(
            id: 'brk',
            isBreak: true,
            label: 'Break',
            startTime: s.start,
            endTime: s.end);
      }
      final p = PeriodSlot(
          id: 'p$pNum',
          isBreak: false,
          label: 'Period $pNum',
          startTime: s.start,
          endTime: s.end);
      pNum++;
      return p;
    }).toList();
  }

  Future<void> _create() async {
    final periods = _buildPeriods();
    if (_selectedSemester == null || periods.isEmpty) return;

    final prov = context.read<AdminProvider>();
    final tt = await prov.createTimetable(
      semesterId: _selectedSemester!.id,
      section: _section,
      academicSession: _selectedSemester!.academicSession,
      periods: periods,
    );

    if (!mounted) return;
    if (tt == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(prov.scheduleActionError ?? 'Failed to create timetable.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ScheduleViewScreen(timetable: tt)),
    );
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
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child:
                        _step == 1 ? _buildStep1() : _buildStep2())),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
        padding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 24),
        decoration: const BoxDecoration(
          color: ColorPallet.primaryBlue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_step == 2) {
                      setState(() => _step = 1);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                Text('Step $_step of 2',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Create Timetable',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15)),
            const SizedBox(height: 2),
            Text(
              _step == 1
                  ? 'Select semester & section'
                  : 'Define periods & break timing',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75), fontSize: 12),
            ),
          ],
        ),
      );

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    final prov = context.watch<AdminProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: prov.isScheduleActionLoading
              ? null
              : () {
                  if (_step == 1) {
                    if (_selectedSemester == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please select a semester.')),
                      );
                      return;
                    }
                    setState(() {
                      if (_slots.isEmpty) {
                        // Seed 3 default periods
                        _slots.addAll([
                          _SlotConfig(
                              isBreak: false,
                              start: const TimeOfDay(hour: 8, minute: 0),
                              end: const TimeOfDay(hour: 9, minute: 0)),
                          _SlotConfig(
                              isBreak: false,
                              start: const TimeOfDay(hour: 9, minute: 0),
                              end: const TimeOfDay(hour: 10, minute: 0)),
                          _SlotConfig(
                              isBreak: false,
                              start: const TimeOfDay(hour: 10, minute: 0),
                              end: const TimeOfDay(hour: 11, minute: 0)),
                        ]);
                      }
                      _step = 2;
                    });
                  } else {
                    if (_slots.where((s) => !s.isBreak).isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Add at least one period.')),
                      );
                      return;
                    }
                    _create();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPallet.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: prov.isScheduleActionLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(_step == 1 ? 'Next: Define Periods →' : 'Create Timetable',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
    );
  }

  // ── Step 1 ────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    final prov = context.watch<AdminProvider>();
    final semesters = prov.semesters
        .where((s) => s.operationalStatus == 'active')
        .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('SELECT SEMESTER'),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: prov.isSemestersLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)))
            : DropdownButton<SemesterModel>(
                value: _selectedSemester,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Choose semester'),
                items: semesters
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                              'Semester ${s.semesterNumber} — ${s.academicSession}',
                              style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (s) =>
                    setState(() => _selectedSemester = s),
              ),
      ),
      const SizedBox(height: 16),
      _label('SECTION'),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8,
        children: ['A', 'B', 'C', 'D'].map((sec) {
          final selected = _section == sec;
          return ChoiceChip(
            label: Text(sec),
            selected: selected,
            selectedColor: ColorPallet.primaryBlue,
            labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold),
            onSelected: (_) => setState(() => _section = sec),
          );
        }).toList(),
      ),

      if (_hasDuplicate) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200)),
          child: Row(children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange.shade700, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
              'A timetable already exists for Semester ${_selectedSemester!.semesterNumber} Section $_section.',
              style:
                  TextStyle(color: Colors.orange.shade800, fontSize: 12),
            )),
          ]),
        ),
      ],
    ]);
  }

  // ── Step 2 ────────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    int pNum = 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('DRAG TO REORDER · TAP TIMES TO EDIT'),
      const SizedBox(height: 8),
      ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (old, nw) {
          setState(() {
            if (nw > old) nw--;
            final item = _slots.removeAt(old);
            _slots.insert(nw, item);
          });
        },
        children: List.generate(_slots.length, (i) {
          final s = _slots[i];
          final isBreak = s.isBreak;
          final label = isBreak ? 'Break' : 'Period ${pNum++}';
          final color =
              isBreak ? Colors.orange.shade600 : ColorPallet.primaryBlue;
          return Container(
            key: ValueKey('slot-$i'),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(
                    isBreak
                        ? Icons.coffee_rounded
                        : Icons.access_time_rounded,
                    color: color,
                    size: 16),
              ),
              title: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color)),
              subtitle: Row(children: [
                GestureDetector(
                  onTap: () => _pickTime(i, true),
                  child: _timeChip(s.start, color),
                ),
                Text('  –  ',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 12)),
                GestureDetector(
                  onTap: () => _pickTime(i, false),
                  child: _timeChip(s.end, color),
                ),
              ]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: Colors.red.shade300, size: 18),
                    onPressed: () => _removeSlot(i),
                  ),
                  const Icon(Icons.drag_handle_rounded,
                      color: Colors.grey, size: 20),
                ],
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 4),
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _addPeriod,
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ColorPallet.primaryBlue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12)),
            icon: const Icon(Icons.add_rounded,
                color: ColorPallet.primaryBlue, size: 16),
            label: const Text('Add Period',
                style: TextStyle(
                    color: ColorPallet.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _breakAdded ? null : _addBreak,
            style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: _breakAdded
                        ? Colors.grey.shade300
                        : Colors.orange.shade400),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12)),
            icon: Icon(Icons.coffee_rounded,
                color: _breakAdded
                    ? Colors.grey.shade400
                    : Colors.orange.shade600,
                size: 16),
            label: Text(_breakAdded ? 'Break Added' : 'Add Break',
                style: TextStyle(
                    color: _breakAdded
                        ? Colors.grey.shade400
                        : Colors.orange.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ),
      ]),
    ]);
  }

  Widget _timeChip(TimeOfDay t, Color color) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Text('$h:$m',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _label(String text) => Text(text,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.4));
}

// ── Slot config model ─────────────────────────────────────────────────────────
class _SlotConfig {
  final bool isBreak;
  final TimeOfDay start;
  final TimeOfDay end;

  _SlotConfig({required this.isBreak, required this.start, required this.end});

  _SlotConfig copyWith({bool? isBreak, TimeOfDay? start, TimeOfDay? end}) =>
      _SlotConfig(
          isBreak: isBreak ?? this.isBreak,
          start: start ?? this.start,
          end: end ?? this.end);
}
