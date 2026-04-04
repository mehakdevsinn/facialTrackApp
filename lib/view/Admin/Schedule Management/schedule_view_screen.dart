import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/assignment_model.dart';
import 'package:facialtrackapp/core/models/timetable_model.dart';
import 'package:facialtrackapp/services/schedule_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

class ScheduleViewScreen extends StatefulWidget {
  final Timetable timetable;
  const ScheduleViewScreen({super.key, required this.timetable});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  late Timetable _tt;

  @override
  void initState() {
    super.initState();
    _tt = widget.timetable;
    // Pre-load the assignments for this semester+section
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchScheduleAssignments(
            semesterId: _tt.semesterId,
            section: _tt.section,
          );
    });
  }

  /// Reload fresh timetable from the provider's in-memory list.
  void _reload() {
    final prov = context.read<AdminProvider>();
    final fresh = prov.timetables.firstWhere((t) => t.id == _tt.id,
        orElse: () => _tt);
    setState(() => _tt = fresh);
  }

  // ──────────────────────────────────────────────────────────────────────────
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
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: _buildGrid(),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.edit_calendar_rounded),
          label: const Text('Edit Periods',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => _editPeriods(),
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
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const Text(
                  'Timetable',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => SchedulePdfService.exportToPDF(_tt),
                  child: const Icon(Icons.print_rounded,
                      color: Colors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _tt.headerLabel,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              'Section ${_tt.section}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75), fontSize: 13),
            ),
          ],
        ),
      );

  // ── Timetable grid ─────────────────────────────────────────────────────────
  Widget _buildGrid() {
    final periods = _tt.periods;
    const dayColW = 56.0;
    const periodColW = 110.0;
    const breakColW = 75.0;
    const rowH = 78.0;
    const headerH = 56.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ───────────────────────────────────────────────────────
        Row(children: [
          _gridCell(
              width: dayColW,
              height: headerH,
              isHeader: true,
              child: const Text('', style: TextStyle(fontSize: 11))),
          ...periods.map((p) => _gridCell(
                width: p.isBreak ? breakColW : periodColW,
                height: headerH,
                isHeader: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: p.isBreak
                            ? Colors.orange.shade700
                            : ColorPallet.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        p.timeRange,
                        style: TextStyle(
                            fontSize: 9,
                            color: p.isBreak
                                ? Colors.orange.shade400
                                : Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              )),
        ]),

        // Divider
        Container(
            height: 2,
            color: ColorPallet.primaryBlue.withOpacity(0.12),
            margin: const EdgeInsets.only(bottom: 4)),

        // ── Day rows ─────────────────────────────────────────────────────────
        ..._days.map((day) => Row(
              children: [
                _gridCell(
                  width: dayColW,
                  height: rowH,
                  isHeader: true,
                  child: Text(
                    day,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey.shade700),
                  ),
                ),
                ...periods.map((p) {
                  if (p.isBreak) {
                    return _gridCell(
                      width: breakColW,
                      height: rowH,
                      isBreak: true,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Break',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.orange.shade400,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                  final entry = _tt.entryFor(day, p.id);
                  return GestureDetector(
                    onTap: () => _openAssignSheet(day, p, entry),
                    child: _gridCell(
                      width: periodColW,
                      height: rowH,
                      hasEntry: entry != null,
                      isGhost: entry != null && !entry.isAssigned,
                      child: entry != null
                          ? _entryContent(entry)
                          : _emptyCell(),
                    ),
                  );
                }),
              ],
            )),
      ],
    );
  }

  Widget _gridCell({
    required double width,
    required double height,
    Widget? child,
    bool isHeader = false,
    bool isBreak = false,
    bool hasEntry = false,
    bool isGhost = false, // slot exists but assignment was deleted
  }) {
    Color bg = Colors.white;
    if (isHeader) bg = Colors.grey.shade50;
    if (isBreak) bg = Colors.orange.shade50;
    if (hasEntry && !isGhost) bg = ColorPallet.primaryBlue.withOpacity(0.04);
    if (isGhost) bg = Colors.orange.shade50;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: isGhost ? Colors.orange.shade200 : Colors.grey.shade200,
          width: isGhost ? 1.2 : 0.8,
        ),
      ),
      padding: const EdgeInsets.all(5),
      child: child,
    );
  }

  Widget _entryContent(TimetableEntry entry) {
    // Ghost slot — assignment was deleted after the slot was created.
    if (!entry.isAssigned) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade400, size: 14),
          const SizedBox(height: 2),
          Text(
            'Unassigned',
            style: TextStyle(
                fontSize: 9,
                color: Colors.orange.shade600,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          entry.courseCode ?? '',
          style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
              color: ColorPallet.primaryBlue),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          entry.teacherName ?? '',
          style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _emptyCell() => Icon(Icons.add_circle_outline_rounded,
      color: Colors.grey.shade300, size: 20);

  // ── Assign slot bottom sheet ───────────────────────────────────────────────
  void _openAssignSheet(
      String day, PeriodSlot period, TimetableEntry? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignSlotSheet(
        timetable: _tt,
        day: day,
        period: period,
        existing: existing,
        onSaved: _reload,
      ),
    );
  }

  // ── Edit periods ──────────────────────────────────────────────────────────
  void _editPeriods() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _EditPeriodsScreen(timetable: _tt, onSaved: _reload),
      ),
    );
  }
}

// ── Edit periods mini-screen ──────────────────────────────────────────────────
class _EditPeriodsScreen extends StatefulWidget {
  final Timetable timetable;
  final VoidCallback onSaved;
  const _EditPeriodsScreen({required this.timetable, required this.onSaved});

  @override
  State<_EditPeriodsScreen> createState() => _EditPeriodsScreenState();
}

class _EditPeriodsScreenState extends State<_EditPeriodsScreen> {
  late List<_SlotConfig> _slots;
  bool _breakAdded = false;

  @override
  void initState() {
    super.initState();
    _slots = widget.timetable.periods.map((p) {
      if (p.isBreak) _breakAdded = true;
      return _SlotConfig(
          isBreak: p.isBreak, start: p.startTime, end: p.endTime);
    }).toList();
  }

  Future<void> _pickTime(int index, bool isStart) async {
    final slot = _slots[index];
    final initial = isStart ? slot.start : slot.end;
    final picked =
        await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      _slots[index] = isStart
          ? _slots[index].copyWith(start: picked)
          : _slots[index].copyWith(end: picked);
    });
  }

  void _removeSlot(int i) {
    setState(() {
      if (_slots[i].isBreak) _breakAdded = false;
      _slots.removeAt(i);
    });
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

  List<PeriodSlot> _buildSlots() {
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

  Future<void> _save() async {
    final prov = context.read<AdminProvider>();
    final updated = await prov.updateTimetablePeriods(
      timetableId: widget.timetable.id,
      periods: _buildSlots(),
    );
    if (!mounted) return;
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(prov.scheduleActionError ?? 'Failed to update periods.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    int pNum = 1;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Edit Periods',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            Consumer<AdminProvider>(builder: (_, prov, __) {
              return prov.isScheduleActionLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)))
                  : TextButton(
                      onPressed: _save,
                      child: const Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)));
            })
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.all(14),
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (newIdx > oldIdx) newIdx--;
                    final item = _slots.removeAt(oldIdx);
                    _slots.insert(newIdx, item);
                  });
                },
                children: List.generate(_slots.length, (i) {
                  final slot = _slots[i];
                  final isBreak = slot.isBreak;
                  final label = isBreak ? 'Break' : 'Period ${pNum++}';
                  final color = isBreak
                      ? Colors.orange.shade600
                      : ColorPallet.primaryBlue;
                  return Container(
                    key: ValueKey('edit-slot-$i'),
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
                          child: _timeChip(slot.start, color),
                        ),
                        Text('  –  ',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12)),
                        GestureDetector(
                          onTap: () => _pickTime(i, false),
                          child: _timeChip(slot.end, color),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(children: [
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
            ),
          ],
        ),
      ),
    );
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
}

// ── Assign slot bottom sheet ──────────────────────────────────────────────────
class _AssignSlotSheet extends StatefulWidget {
  final Timetable timetable;
  final String day;
  final PeriodSlot period;
  final TimetableEntry? existing;
  final VoidCallback onSaved;

  const _AssignSlotSheet({
    required this.timetable,
    required this.day,
    required this.period,
    required this.existing,
    required this.onSaved,
  });

  @override
  State<_AssignSlotSheet> createState() => _AssignSlotSheetState();
}

class _AssignSlotSheetState extends State<_AssignSlotSheet> {
  AssignmentModel? _selectedCourseAssignment;
  String? _selectedTeacher;
  bool _hasConflict = false;
  bool _isSaving = false;
  bool _selectionInitialised = false; // guard so we only pre-fill once

  @override
  void initState() {
    super.initState();
    // Always trigger a fresh fetch when the sheet opens.
    // This ensures we get data even if the background fetch hasn't finished.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminProvider>().fetchScheduleAssignments(
            semesterId: widget.timetable.semesterId,
            section: widget.timetable.section,
            force: true, // Always fetch fresh — avoids showing deleted assignments
          );
    });
  }

  /// Called from build() the first time assignments are available, so that
  /// we can pre-select the existing assignment without a race condition.
  void _tryPreselect(List<AssignmentModel> assignments) {
    if (_selectionInitialised) return;
    _selectionInitialised = true;
    if (widget.existing == null || !widget.existing!.isAssigned) return;
    try {
      final match =
          assignments.firstWhere((a) => a.id == widget.existing!.assignmentId);
      // Use post-frame so we don't call setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedCourseAssignment = match;
          _selectedTeacher = match.teacher.fullName;
        });
      });
    } catch (_) {
      // Assignment no longer exists — leave both null.
    }
  }


  void _checkConflict() {
    if (_selectedCourseAssignment == null) {
      _hasConflict = false;
      return;
    }
    final assignId = _selectedCourseAssignment!.id;
    _hasConflict = widget.timetable.entries.any((e) =>
        e.day == widget.day &&
        e.periodId == widget.period.id &&
        e.assignmentId == assignId);
  }

  Future<void> _save() async {
    if (_selectedCourseAssignment == null) return;
    setState(() => _isSaving = true);
    final prov = context.read<AdminProvider>();
    final updated = await prov.assignScheduleEntry(
      timetableId: widget.timetable.id,
      day: widget.day,
      periodId: widget.period.id,
      assignmentId: _selectedCourseAssignment!.id,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(prov.scheduleActionError ?? 'Failed to assign slot.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    widget.onSaved();
    Navigator.pop(context);
  }

  Future<void> _clear() async {
    setState(() => _isSaving = true);
    final prov = context.read<AdminProvider>();
    await prov.clearScheduleEntry(
      timetableId: widget.timetable.id,
      day: widget.day,
      periodId: widget.period.id,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Reactively read assignments so we update when the fetch completes.
    final allAssignments = context
        .watch<AdminProvider>()
        .scheduleAssignments(
            widget.timetable.semesterId, widget.timetable.section);

    // Pre-fill selection once data is available.
    _tryPreselect(allAssignments);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2))),
            ),

            // Slot info banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: ColorPallet.primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.access_time_rounded,
                    color: ColorPallet.primaryBlue, size: 18),
                const SizedBox(width: 12),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.day} · ${widget.period.label}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: ColorPallet.primaryBlue)),
                      Text(widget.period.timeRange,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ]),
                const Spacer(),
                if (widget.existing != null)
                  GestureDetector(
                    onTap: _isSaving ? null : _clear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('Clear Slot',
                          style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ]),
            ),

            // Conflict warning
            if (_hasConflict)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200)),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    '${_selectedTeacher ?? "Teacher"} is already scheduled at this time.',
                    style: TextStyle(
                        color: Colors.orange.shade800, fontSize: 12),
                  )),
                ]),
              ),

            const SizedBox(height: 16),

            // No assignments warning
            if (allAssignments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Icon(Icons.info_outline,
                        color: Colors.red.shade400, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                      'No course assignments found for this semester/section. '
                      'Add assignments first.',
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 12),
                    )),
                  ]),
                ),
              ),

            // Course dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('SELECT ASSIGNMENT (COURSE — TEACHER)'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<AssignmentModel>(
                      value: _selectedCourseAssignment,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Choose a course & teacher',
                          style: TextStyle(fontSize: 13)),
                      items: allAssignments
                          .map((a) => DropdownMenuItem(
                                value: a,
                                child: Text(
                                  '${a.course.code} — ${a.teacher.fullName}',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (a) {
                        setState(() {
                          _selectedCourseAssignment = a;
                          _selectedTeacher = a?.teacher.fullName;
                        });
                        _checkConflict();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_selectedCourseAssignment == null || _isSaving)
                              ? null
                              : _save,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPallet.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14)),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                          : const Text('Assign Slot',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.4));
}

// ── Local slot config ─────────────────────────────────────────────────────────
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
