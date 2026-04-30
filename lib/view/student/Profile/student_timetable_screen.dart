import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/student_timetable_model.dart';
import 'package:flutter/material.dart';

const _weekdayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Full-semester timetable from `GET /api/v1/students/schedule/`.
class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  bool _loading = true;
  String? _error;
  StudentTimetableResponse? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await ApiManager.instance.getStudentSchedule();
      if (!mounted) return;
      setState(() {
        _data = d;
        _loading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _data = null;
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _data = null;
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<String> _orderedDays(StudentTimetableResponse t) {
    final present = <String>{};
    for (final e in t.entries) {
      if (e.day.isNotEmpty) present.add(e.day);
    }
    final out = <String>[];
    for (final d in _weekdayOrder) {
      if (present.contains(d)) out.add(d);
    }
    for (final d in present) {
      if (!out.contains(d)) out.add(d);
    }
    return out.isEmpty ? _weekdayOrder.sublist(0, 5) : out;
  }

  TimetableEntry? _entryFor(StudentTimetableResponse t, String day, String periodId) {
    for (final e in t.entries) {
      if (e.day == day && e.periodId == periodId) return e;
    }
    return null;
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
            'My Timetable',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 52),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
              ),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final t = _data!;
    if (t.periods.isEmpty) {
      return const Center(
        child: Text('No periods defined for this timetable.'),
      );
    }
    final days = _orderedDays(t);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(t),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _timetableTable(t, days),
          ),
        ],
      ),
    );
  }

  Widget _headerCard(StudentTimetableResponse t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.academicSession.isEmpty ? 'Current semester' : t.academicSession,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Semester ${t.semesterNumber} · Section ${t.section.isEmpty ? '—' : t.section}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Times shown as on timetable (wall clock, Asia/Karachi).',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _timetableTable(StudentTimetableResponse t, List<String> days) {
    const timeColWidth = 118.0;
    const dayColWidth = 112.0;

    final colWidths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(timeColWidth),
    };
    for (var i = 0; i < days.length; i++) {
      colWidths[i + 1] = const FixedColumnWidth(dayColWidth);
    }

    final headerCells = <Widget>[
      _cellHeader('Time'),
      ...days.map((d) => _cellHeader(d)),
    ];

    final rows = <TableRow>[
      TableRow(children: headerCells),
      ...t.periods.map((p) {
        final timeCell = _periodTimeCell(p);
        final dayCells = days.map((d) => _dayCell(t, p, d)).toList();
        return TableRow(children: [timeCell, ...dayCells]);
      }),
    ];

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
      columnWidths: colWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  Widget _cellHeader(String text) {
    return Container(
      color: ColorPallet.primaryBlue.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _periodTimeCell(TimetablePeriod p) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            p.label.isEmpty ? 'Period' : p.label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            '${p.startTime} – ${p.endTime}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(StudentTimetableResponse t, TimetablePeriod p, String day) {
    if (p.isBreak) {
      return _slotPadding(
        Text(
          'Break',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.brown.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      );
    }

    final e = _entryFor(t, day, p.id);
    if (e == null || e.isUnassigned) {
      return _slotPadding(
        Text(
          '—',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      );
    }

    final code = e.courseCode?.trim();
    final title = e.courseTitle?.trim();
    final teacher = e.teacherName?.trim();

    return _slotPadding(
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (code != null && code.isNotEmpty)
            Text(
              code,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          if (title != null && title.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
            ),
          ],
          if (teacher != null && teacher.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              teacher,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _slotPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Center(child: child),
    );
  }
}
