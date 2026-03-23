import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/core/models/timetable_model.dart';
import 'package:facialtrackapp/utils/dummy/schedule_dummy_data.dart';
import 'package:flutter/material.dart';

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
  }

  void _reload() {
    final fresh = ScheduleDummyData.findById(_tt.id);
    if (fresh != null) setState(() => _tt = fresh);
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
                const SizedBox(width: 24),
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

    // Column widths
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
                // Day label
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
                // Period cells
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
                      child:
                          entry != null ? _entryContent(entry) : _emptyCell(),
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
  }) {
    Color bg = Colors.white;
    if (isHeader) bg = Colors.grey.shade50;
    if (isBreak) bg = Colors.orange.shade50;
    if (hasEntry) bg = ColorPallet.primaryBlue.withOpacity(0.04);

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      padding: const EdgeInsets.all(5),
      child: child,
    );
  }

  Widget _entryContent(TimetableEntry entry) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            entry.courseCode,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
                color: ColorPallet.primaryBlue),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            entry.teacherName,
            style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );

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
        timetableId: _tt.id,
        semesterNumber: _tt.semesterNumber,
        day: day,
        period: period,
        existing: existing,
        onSaved: _reload,
      ),
    );
  }

  // ── Edit periods → re-open wizard step 2 ──────────────────────────────────
  void _editPeriods() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _EditPeriodsScreen(timetableId: _tt.id, periods: _tt.periods),
      ),
    ).then((_) => _reload());
  }
}

// ── Edit periods mini-screen ─────────────────────────────────────────────────
class _EditPeriodsScreen extends StatefulWidget {
  final String timetableId;
  final List<PeriodSlot> periods;
  const _EditPeriodsScreen({required this.timetableId, required this.periods});

  @override
  State<_EditPeriodsScreen> createState() => _EditPeriodsScreenState();
}

class _EditPeriodsScreenState extends State<_EditPeriodsScreen> {
  late List<_SlotConfig> _slots;
  bool _breakAdded = false;

  @override
  void initState() {
    super.initState();
    _slots = widget.periods.map((p) {
      if (p.isBreak) _breakAdded = true;
      return _SlotConfig(
          isBreak: p.isBreak, start: p.startTime, end: p.endTime);
    }).toList();
  }

  Future<void> _pickTime(int index, bool isStart) async {
    final slot = _slots[index];
    final initial = isStart ? slot.start : slot.end;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _slots[index] = _slots[index].copyWith(start: picked);
      } else {
        _slots[index] = _slots[index].copyWith(end: picked);
      }
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
    setState(() => _slots
        .add(_SlotConfig(isBreak: false, start: last.end, end: last.end)));
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

  void _save() {
    ScheduleDummyData.updatePeriods(widget.timetableId, _buildSlots());
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
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
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
                                color: Colors.grey.shade400, fontSize: 12)),
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

// ── Assign slot bottom sheet ─────────────────────────────────────────────────
class _AssignSlotSheet extends StatefulWidget {
  final String timetableId;
  final int semesterNumber;
  final String day;
  final PeriodSlot period;
  final TimetableEntry? existing;
  final VoidCallback onSaved;

  const _AssignSlotSheet({
    required this.timetableId,
    required this.semesterNumber,
    required this.day,
    required this.period,
    required this.existing,
    required this.onSaved,
  });

  @override
  State<_AssignSlotSheet> createState() => _AssignSlotSheetState();
}

class _AssignSlotSheetState extends State<_AssignSlotSheet> {
  late List<Map<String, dynamic>> _courses;
  Map<String, dynamic>? _selectedCourse;
  String? _selectedTeacher;
  bool _hasConflict = false;

  @override
  void initState() {
    super.initState();
    _courses = ScheduleDummyData.coursesForSemester(widget.semesterNumber);

    if (widget.existing != null) {
      try {
        _selectedCourse = _courses
            .firstWhere((c) => c['code'] == widget.existing!.courseCode);
      } catch (_) {}
      _selectedTeacher = widget.existing?.teacherName;
    }
  }

  List<String> get _teachers => _selectedCourse == null
      ? []
      : ScheduleDummyData.teachersForCourse(_selectedCourse!['code'] as String);

  void _onCourseChanged(Map<String, dynamic>? course) {
    final teachers = course == null
        ? []
        : ScheduleDummyData.teachersForCourse(course['code'] as String);
    setState(() {
      _selectedCourse = course;
      _selectedTeacher = teachers.isNotEmpty ? teachers.first : null;
      _checkConflict();
    });
  }

  void _onTeacherChanged(String? teacher) {
    setState(() {
      _selectedTeacher = teacher;
      _checkConflict();
    });
  }

  void _checkConflict() {
    if (_selectedTeacher == null) {
      _hasConflict = false;
      return;
    }
    _hasConflict = ScheduleDummyData.hasConflict(
      timetableId: widget.timetableId,
      day: widget.day,
      periodId: widget.period.id,
      teacherName: _selectedTeacher!,
    );
  }

  void _save() {
    if (_selectedCourse == null || _selectedTeacher == null) return;
    ScheduleDummyData.updateEntry(
      widget.timetableId,
      widget.day,
      widget.period.id,
      TimetableEntry(
        day: widget.day,
        periodId: widget.period.id,
        courseCode: _selectedCourse!['code'],
        courseTitle: _selectedCourse!['title'],
        teacherName: _selectedTeacher!,
      ),
    );
    widget.onSaved();
    Navigator.pop(context);
  }

  void _clear() {
    ScheduleDummyData.clearEntry(
        widget.timetableId, widget.day, widget.period.id);
    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: ColorPallet.primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.access_time_rounded,
                    color: ColorPallet.primaryBlue, size: 18),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${widget.day} · ${widget.period.label}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: ColorPallet.primaryBlue)),
                  Text(widget.period.timeRange,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ]),
                const Spacer(),
                if (widget.existing != null)
                  GestureDetector(
                    onTap: _clear,
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
                    '${_selectedTeacher ?? "Teacher"} is already scheduled at this time on ${widget.day}.',
                    style:
                        TextStyle(color: Colors.orange.shade800, fontSize: 12),
                  )),
                ]),
              ),

            const SizedBox(height: 16),
            // Course dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('SELECT COURSE'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<Map<String, dynamic>>(
                      value: _selectedCourse,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text('Choose a course',
                          style: TextStyle(fontSize: 13)),
                      items: _courses
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text('${c['code']} — ${c['title']}',
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: _onCourseChanged,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('SELECT TEACHER'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                        color: _teachers.isEmpty
                            ? Colors.grey.shade100
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: _selectedTeacher,
                      isExpanded: true,
                      underline: const SizedBox(),
                      disabledHint: const Text('Select a course first',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      items: _teachers
                          .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t,
                                  style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: _teachers.isEmpty ? null : _onTeacherChanged,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallet.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed:
                          (_selectedCourse != null && _selectedTeacher != null)
                              ? _save
                              : null,
                      child: const Text('Assign Slot',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
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

// ── Mutable slot config (shared by create wizard + edit periods screen) ───────
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
