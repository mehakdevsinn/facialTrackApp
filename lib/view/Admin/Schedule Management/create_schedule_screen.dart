import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/core/models/timetable_model.dart';
import 'package:facialtrackapp/utils/dummy/schedule_dummy_data.dart';
import 'package:facialtrackapp/view/Admin/Schedule%20Management/schedule_view_screen.dart';
import 'package:flutter/material.dart';

class CreateScheduleScreen extends StatefulWidget {
  const CreateScheduleScreen({super.key});

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  int _step = 0; // 0 = basic info, 1 = periods

  // ── Step 1 ─────────────────────────────────────────────────────────────────
  int _selectedSemester = 1;
  String _selectedSection = 'A';
  String _academicSession = '2024-28';

  final _sections = ['A', 'B', 'C', 'D', 'E'];
  final _semesters = List.generate(8, (i) => i + 1);

  // ── Step 2 ─────────────────────────────────────────────────────────────────
  // Each item is either a period Map or a break Map
  final List<_SlotConfig> _slots = [];
  bool _breakAdded = false;

  @override
  void initState() {
    super.initState();
    // Seed with 3 default periods so the screen isn't empty
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

  bool get _isDuplicate => ScheduleDummyData.all.any((t) =>
      t.semesterNumber == _selectedSemester && t.section == _selectedSection);

  void _addPeriod() {
    final last = _slots.lastWhere((s) => !s.isBreak,
        orElse: () => _SlotConfig(
            isBreak: false,
            start: const TimeOfDay(hour: 8, minute: 0),
            end: const TimeOfDay(hour: 9, minute: 0)));
    setState(() {
      _slots.add(_SlotConfig(isBreak: false, start: last.end, end: last.end));
    });
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

  void _removeSlot(int index) {
    setState(() {
      if (_slots[index].isBreak) _breakAdded = false;
      _slots.removeAt(index);
    });
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

  List<PeriodSlot> _buildPeriodSlots() {
    int pNum = 1;
    final result = <PeriodSlot>[];
    for (int i = 0; i < _slots.length; i++) {
      final s = _slots[i];
      if (s.isBreak) {
        result.add(PeriodSlot(
          id: 'brk',
          isBreak: true,
          label: 'Break',
          startTime: s.start,
          endTime: s.end,
        ));
      } else {
        result.add(PeriodSlot(
          id: 'p$pNum',
          isBreak: false,
          label: 'Period $pNum',
          startTime: s.start,
          endTime: s.end,
        ));
        pNum++;
      }
    }
    return result;
  }

  void _createTimetable() {
    if (_slots.where((s) => !s.isBreak).isEmpty) {
      _showSnack('Add at least one period before creating.');
      return;
    }
    final newTT = Timetable(
      id: ScheduleDummyData.generateId(),
      semesterNumber: _selectedSemester,
      semesterId: 'sem-$_selectedSemester',
      academicSession: _academicSession,
      section: _selectedSection,
      periods: _buildPeriodSlots(),
      entries: [],
    );
    ScheduleDummyData.addTimetable(newTT);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ScheduleViewScreen(timetable: newTT)),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade600,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _step == 0 ? _buildStep1() : _buildStep2(),
              ),
            ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (_step == 1) {
                  setState(() => _step = 0);
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
            ),
            Text(
              _step == 0 ? 'New Timetable' : 'Define Periods',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 24),
          ],
        ),
      );

  // ── Step indicator ─────────────────────────────────────────────────────────
  Widget _buildStepIndicator() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(children: [
          _stepDot(0, 'Basic Info'),
          Expanded(
              child: Container(
                  height: 2,
                  color: _step >= 1
                      ? ColorPallet.primaryBlue
                      : Colors.grey.shade300)),
          _stepDot(1, 'Periods'),
        ]),
      );

  Widget _stepDot(int n, String label) {
    final active = _step >= n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? ColorPallet.primaryBlue : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              '${n + 1}',
              style: TextStyle(
                  color: active ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: active ? ColorPallet.primaryBlue : Colors.grey.shade500,
                fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  // ── Step 1: Basic info ─────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isDuplicate)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                'A timetable already exists for Semester $_selectedSemester, Section $_selectedSection.',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
              )),
            ]),
          ),
        _card([
          _fieldLabel('SELECT SEMESTER'),
          _dropdown<int>(
            value: _selectedSemester,
            items: _semesters,
            labelBuilder: (v) => 'Semester $v',
            onChanged: (v) => setState(() => _selectedSemester = v!),
          ),
          const SizedBox(height: 14),
          _fieldLabel('SELECT SECTION'),
          _dropdown<String>(
            value: _selectedSection,
            items: _sections,
            labelBuilder: (v) => 'Section $v',
            onChanged: (v) => setState(() => _selectedSection = v!),
          ),
          const SizedBox(height: 14),
          _fieldLabel('ACADEMIC SESSION'),
          TextField(
            decoration: _inputDeco(Icons.date_range_outlined, 'e.g. 2024-28'),
            controller: TextEditingController(text: _academicSession),
            onChanged: (v) => _academicSession = v,
          ),
        ]),
      ],
    );
  }

  // ── Step 2: Define periods ─────────────────────────────────────────────────
  Widget _buildStep2() {
    int pNum = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoNote('Drag rows to reorder. Add a break between any two periods.'),
        const SizedBox(height: 10),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
            final displayLabel = isBreak ? 'Break' : 'Period ${pNum++}';
            if (!isBreak) {}
            return _slotRow(i, slot, displayLabel);
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addPeriod,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ColorPallet.primaryBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.add_rounded,
                    color: ColorPallet.primaryBlue, size: 18),
                label: const Text('Add Period',
                    style: TextStyle(
                        color: ColorPallet.primaryBlue,
                        fontWeight: FontWeight.bold)),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.coffee_rounded,
                    color: _breakAdded
                        ? Colors.grey.shade400
                        : Colors.orange.shade600,
                    size: 18),
                label: Text(_breakAdded ? 'Break Added' : 'Add Break',
                    style: TextStyle(
                        color: _breakAdded
                            ? Colors.grey.shade400
                            : Colors.orange.shade600,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _slotRow(int index, _SlotConfig slot, String label) {
    final isBreak = slot.isBreak;
    final color = isBreak ? Colors.orange.shade600 : ColorPallet.primaryBlue;

    return Container(
      key: ValueKey('slot-$index'),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isBreak ? Colors.orange.shade200 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(
              child: Icon(
                  isBreak ? Icons.coffee_rounded : Icons.access_time_rounded,
                  color: color,
                  size: 16)),
        ),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        subtitle: Row(
          children: [
            GestureDetector(
              onTap: () => _pickTime(index, true),
              child: _timeChip(slot.start, color),
            ),
            Text('  –  ',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            GestureDetector(
              onTap: () => _pickTime(index, false),
              child: _timeChip(slot.end, color),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade300, size: 18),
              onPressed: () => _removeSlot(index),
            ),
            const Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 20),
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
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text('$h:$m',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPallet.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          onPressed:
              _step == 0 ? () => setState(() => _step = 1) : _createTimetable,
          child: Text(
            _step == 0 ? 'Next: Define Periods' : 'Create Timetable',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.4)),
      );

  InputDecoration _inputDeco(IconData icon, String hint) => InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: Colors.grey, size: 18),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      );

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T?) onChanged,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          items: items
              .map((v) =>
                  DropdownMenuItem<T>(value: v, child: Text(labelBuilder(v))))
              .toList(),
          onChanged: onChanged,
        ),
      );

  Widget _infoNote(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ColorPallet.primaryBlue.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorPallet.primaryBlue.withOpacity(0.15)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded,
              color: ColorPallet.primaryBlue, size: 15),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: ColorPallet.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500))),
        ]),
      );
}

// ── Mutable slot config (local to wizard) ─────────────────────────────────────
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
