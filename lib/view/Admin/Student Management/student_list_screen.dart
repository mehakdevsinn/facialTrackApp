import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/utils/dummy/student_dummy_data.dart';
import 'package:facialtrackapp/view/Admin/Student%20Management/student_detail_screen.dart';
import 'package:flutter/material.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> _students = [];
  int? _selectedSemesterFilter;
  String _searchQuery = '';
  bool _bulkMode = false;
  final Set<String> _selectedIds = {};
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _students = StudentDummyData.students;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchQuery.toLowerCase();
    return _students.where((s) {
      final semMatch = _selectedSemesterFilter == null ||
          s['semesterNumber'] == _selectedSemesterFilter;
      final searchMatch = q.isEmpty ||
          (s['fullName'] as String).toLowerCase().contains(q) ||
          (s['rollNo'] as String).toLowerCase().contains(q);
      return semMatch && searchMatch;
    }).toList();
  }

  void _enterBulkMode() => setState(() {
        _bulkMode = true;
        _selectedIds.clear();
      });

  void _exitBulkMode() => setState(() {
        _bulkMode = false;
        _selectedIds.clear();
      });

  void _toggleSelect(String id) => setState(() {
        _selectedIds.contains(id)
            ? _selectedIds.remove(id)
            : _selectedIds.add(id);
      });

  void _selectAll() => setState(
      () => _selectedIds.addAll(_filtered.map((s) => s['id'] as String)));

  void _clearAll() => setState(() => _selectedIds.clear());

  void _deleteSingle(String id) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Student',
        message: 'This student will be permanently removed. Are you sure?',
        confirmLabel: 'Delete',
        confirmColor: Colors.red.shade600,
        onConfirm: () {
          StudentDummyData.deleteStudent(id);
          setState(() => _students = StudentDummyData.students);
          _showSnack('Student removed successfully');
        },
      ),
    );
  }

  void _bulkDelete() {
    final count = _selectedIds.length;
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete $count Student${count > 1 ? 's' : ''}',
        message:
            'Permanently remove $count selected student${count > 1 ? 's' : ''}? This cannot be undone.',
        confirmLabel: 'Delete All',
        confirmColor: Colors.red.shade600,
        onConfirm: () {
          StudentDummyData.bulkDelete(_selectedIds.toList());
          setState(() {
            _students = StudentDummyData.students;
            _bulkMode = false;
            _selectedIds.clear();
          });
          _showSnack('$count student${count > 1 ? 's' : ''} deleted');
        },
      ),
    );
  }

  void _bulkPromote() {
    final sems = _students
        .where((s) => _selectedIds.contains(s['id']))
        .map((s) => s['semesterNumber'] as int)
        .toSet();
    final semText =
        sems.length == 1 ? 'Semester ${sems.first}' : 'selected semesters';
    final count = _selectedIds.length;
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Promote $count Student${count > 1 ? 's' : ''}',
        message:
            'Move $count student${count > 1 ? 's' : ''} from $semText to the next semester?',
        confirmLabel: 'Promote',
        confirmColor: ColorPallet.primaryBlue,
        onConfirm: () {
          StudentDummyData.promoteStudents(_selectedIds.toList());
          setState(() {
            _students = StudentDummyData.students;
            _bulkMode = false;
            _selectedIds.clear();
          });
          _showSnack('Students promoted successfully!');
        },
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(filtered.length),
                _buildSemesterFilter(),
                if (_bulkMode) _buildBulkBanner(),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _buildStudentCard(filtered[i]),
                        ),
                ),
              ],
            ),
            if (_bulkMode && _selectedIds.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBulkBar(),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header  ────────────────────────────────────────────────────────────────
  Widget _buildHeader(int showing) {
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
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
              ),
              Text(
                _bulkMode
                    ? '${_selectedIds.length} Selected'
                    : 'Student Management',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              _bulkMode
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _selectedIds.length == _filtered.length
                              ? _clearAll
                              : _selectAll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedIds.length == _filtered.length
                                  ? 'Deselect All'
                                  : 'Select All',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _exitBulkMode,
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: _enterBulkMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.checklist_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Select',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 16),
          // Stat pills
          Row(
            children: [
              _statPill(Icons.people_rounded, '${_students.length}',
                  'Total Students'),
              const SizedBox(width: 10),
              _statPill(Icons.filter_list_rounded, '$showing', 'Showing'),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.white70, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.close,
                          color: Colors.white70, size: 18),
                    )
                  : null,
              hintText: 'Search by name or roll number...',
              hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 17)),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Semester filter ────────────────────────────────────────────────────────
  Widget _buildSemesterFilter() {
    final tabs = ['All', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8'];
    final values = [null, 1, 2, 3, 4, 5, 6, 7, 8];

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: tabs.length,
              itemBuilder: (_, i) {
                final selected = _selectedSemesterFilter == values[i];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedSemesterFilter = values[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? ColorPallet.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? ColorPallet.primaryBlue
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey.shade600,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
        ],
      ),
    );
  }

  // ── Bulk mode banner ───────────────────────────────────────────────────────
  Widget _buildBulkBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorPallet.primaryBlue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPallet.primaryBlue.withOpacity(0.18)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded,
            color: ColorPallet.primaryBlue, size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Tap cards to select. Use Promote or Delete from the action bar.',
            style: TextStyle(
                color: ColorPallet.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }

  // ── Student card ────────────────────────────────────────────────────
  Widget _buildStudentCard(Map<String, dynamic> s) {
    final id = s['id'] as String;
    final isSelected = _selectedIds.contains(id);
    final color = StudentDummyData.avatarColor(id);
    final sem = s['semesterNumber'] as int;
    final faceEnrolled = s['faceEnrolled'] as bool;

    return GestureDetector(
      onTap: () {
        if (_bulkMode) {
          _toggleSelect(id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StudentDetailScreen(student: Map.from(s))),
          ).then((_) => setState(() => _students = StudentDummyData.students));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: ColorPallet.primaryBlue, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
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
            // Checkbox in bulk mode
            if (_bulkMode)
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelect(id),
                    activeColor: ColorPallet.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),

            // Circle avatar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    StudentDummyData.initials(s['fullName'] as String),
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                ),
              ),
            ),

            // Main info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s['fullName'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: faceEnrolled
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                faceEnrolled
                                    ? Icons.face_retouching_natural
                                    : Icons.face_outlined,
                                size: 11,
                                color: faceEnrolled
                                    ? Colors.green.shade600
                                    : Colors.orange.shade700,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                faceEnrolled ? 'Enrolled' : 'Pending',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: faceEnrolled
                                        ? Colors.green.shade600
                                        : Colors.orange.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(s['rollNo'] as String,
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _tag('S$sem', ColorPallet.primaryBlue),
                        const SizedBox(width: 6),
                        _tag('Sec ${s['section']}', const Color(0xFF6366F1)),
                        const SizedBox(width: 6),
                        _tag(s['enrollmentDate'] as String,
                            Colors.grey.shade500),
                        const Spacer(),
                        if (!_bulkMode)
                          GestureDetector(
                            onTap: () => _deleteSingle(id),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.delete_outline_rounded,
                                  color: Colors.red.shade400, size: 17),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // ── Bulk action bottom bar ─────────────────────────────────────────────────
  Widget _buildBulkBar() {
    final canPromote = _students
        .where((s) => _selectedIds.contains(s['id']))
        .any((s) => (s['semesterNumber'] as int) < 8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, -6))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2)),
          ),
          Text(
              '${_selectedIds.length} student${_selectedIds.length > 1 ? 's' : ''} selected',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canPromote ? _bulkPromote : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPallet.primaryBlue,
                    disabledBackgroundColor:
                        ColorPallet.primaryBlue.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded,
                      color: Colors.white, size: 17),
                  label: const Text('Promote',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _bulkDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.delete_forever_rounded,
                      color: Colors.white, size: 17),
                  label: const Text('Delete',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorPallet.primaryBlue.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.school_outlined,
                size: 56, color: ColorPallet.primaryBlue.withOpacity(0.4)),
          ),
          const SizedBox(height: 18),
          Text('No students found',
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Try adjusting the semester filter or search',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Confirm dialog ─────────────────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      content: Text(message,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade500)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(confirmLabel,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
