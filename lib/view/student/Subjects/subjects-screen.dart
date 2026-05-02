import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:facialtrackapp/core/models/student_report_models.dart';
import 'package:facialtrackapp/view/student/Subjects/subject-detail.dart';
import 'package:flutter/material.dart';

const List<Color> _subjectColors = [
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.indigo,
  Colors.deepOrange,
];

class MySubjectsScreen extends StatefulWidget {
  const MySubjectsScreen({super.key});

  @override
  State<MySubjectsScreen> createState() => _MySubjectsScreenState();
}

class _MySubjectsScreenState extends State<MySubjectsScreen> {
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<StudentCourseSummary> _courses = [];

  List<StudentCourseSummary> _filtered = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterSubjects);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiManager.instance.getStudentSubjectsReport();
      if (!mounted) return;
      setState(() {
        _courses = res.courses;
        _filtered = List.from(_courses);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _courses = [];
        _filtered = [];
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterSubjects() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_courses);
      } else {
        _filtered = _courses.where((c) {
          return c.courseName.toLowerCase().contains(query) ||
              c.teacherName.toLowerCase().contains(query) ||
              c.courseCode.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  ({int n, int weightedPct, int attended, int total}) _stats() {
    if (_courses.isEmpty) {
      return (n: 0, weightedPct: 0, attended: 0, total: 0);
    }
    var totalSess = 0;
    var attended = 0;
    for (final c in _courses) {
      totalSess += c.totalSessions;
      attended += c.sessionsAttended;
    }
    final pct = totalSess > 0 ? ((attended * 100) / totalSess).round() : 0;
    return (
      n: _courses.length,
      weightedPct: pct,
      attended: attended,
      total: totalSess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _stats();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            Container(
              height: isSearching ? 80 : 108,
              color: ColorPallet.primaryBlue,
            ),
            Positioned(
              top: isSearching ? 18 : 22,
              left: 18,
              right: 18,
              child: isSearching ? buildSearchField() : buildHeader(),
            ),
            if (!isSearching) ...[
              Positioned(
                top: 70,
                left: 16,
                right: 16,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22, right: 22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: 14,
                      bottom: 15,
                    ),
                    decoration: BoxDecoration(
                      color: ColorPallet.white,
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statColumn(
                                Icons.menu_book,
                                Colors.blue,
                                '${s.n}',
                                'Subjects',
                              ),
                              const SizedBox(
                                height: 40,
                                child: VerticalDivider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              _statColumn(
                                Icons.percent,
                                Colors.green,
                                '${s.weightedPct}%',
                                'Overall',
                              ),
                              const SizedBox(
                                height: 40,
                                child: VerticalDivider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              _statColumn(
                                Icons.event_available,
                                Colors.orange,
                                '${s.attended}',
                                'Present',
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.only(top: isSearching ? 120 : 180),
              child: _buildListBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_courses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No subjects assigned.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Text(
          'No subjects match your search.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final c = _filtered[index];
        final globalIndex = _courses.indexOf(c);
        final color = _subjectColors[
            (globalIndex >= 0 ? globalIndex : index) % _subjectColors.length];
        final pct = c.attendancePercentage.round();
        return SubjectCard(
          courseId: c.courseId,
          subject: c.courseName,
          teacher: c.teacherName,
          code: c.courseCode,
          attendance: pct,
          presentDays: c.sessionsAttended,
          absentDays: c.sessionsAbsent,
          color: color,
        );
      },
    );
  }

  Widget _statColumn(
    IconData icon,
    Color iconColor,
    String value,
    String label,
  ) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search subjects...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              isSearching = false;
              searchController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Subjects',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search, size: 30, color: Colors.white),
          onPressed: () {
            setState(() => isSearching = true);
          },
        ),
      ],
    );
  }
}

class SubjectCard extends StatelessWidget {
  final String courseId;
  final String subject;
  final String teacher;
  final String code;
  final int attendance;
  final int presentDays;
  final int absentDays;
  final Color color;

  const SubjectCard({
    super.key,
    required this.courseId,
    required this.subject,
    required this.teacher,
    required this.code,
    required this.attendance,
    required this.presentDays,
    required this.absentDays,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final initials = subject.length >= 2
        ? subject.substring(0, 2).toUpperCase()
        : subject.toUpperCase();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailScreen(
              courseId: courseId,
              subject: subject,
              teacher: teacher,
              attendance: attendance,
              presentDays: presentDays,
              absentDays: absentDays,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 54,
                      width: 54,
                      child: CircularProgressIndicator(
                        value: (attendance / 100).clamp(0.0, 1.0),
                        strokeWidth: 6,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$attendance%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Attendance',
                          style: TextStyle(fontSize: 8, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            subject.replaceAll('\n', ' ').replaceAll('\r', ''),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          code.isEmpty ? '—' : code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      teacher.replaceAll('\n', ' ').replaceAll('\r', ''),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      _infoDot(
                        Colors.green,
                        '$presentDays',
                        'Present',
                        context,
                      ),
                      const SizedBox(width: 16),
                      _infoDot(
                        Colors.red,
                        '$absentDays',
                        'Absent',
                        context,
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoDot(
      Color color, String value, String label, BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width <= 350
        ? Column(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 11)),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          )
        : Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 4),
              Text(value, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          );
  }
}
