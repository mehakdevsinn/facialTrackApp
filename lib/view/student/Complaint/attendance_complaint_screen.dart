import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/api/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Student → teacher attendance dispute. `POST /students/complaints`
class AttendanceComplaintScreen extends StatefulWidget {
  final String sessionId;
  final String courseName;
  final String teacherName;
  final DateTime date;

  /// When true, this session is excused leave — complaints are blocked (UI + API).
  final bool sessionMarkedOnLeave;

  const AttendanceComplaintScreen({
    super.key,
    required this.sessionId,
    required this.courseName,
    required this.teacherName,
    required this.date,
    this.sessionMarkedOnLeave = false,
  });

  @override
  State<AttendanceComplaintScreen> createState() =>
      _AttendanceComplaintScreenState();
}

class _AttendanceComplaintScreenState extends State<AttendanceComplaintScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedIssue;
  bool _isLoading = false;

  static const List<String> _issueTypes = [
    'Attendance Not Marked',
    'Marked Absent by Mistake',
    'Wrong Entry/Exit Time',
  ];

  static const String _leaveBlockUserMessage =
      'Attendance complaints are not accepted for sessions marked on excused leave. '
      'If that marking is wrong, contact your administration.';

  static bool _apiMessageSuggestsLeaveComplaintBlock(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('on leave') ||
        s.contains('on_leave') ||
        s.contains('excused leave') ||
        s.contains('marked on leave')) {
      return true;
    }
    if (s.contains('leave') &&
        (s.contains('complaint') ||
            s.contains('dispute') ||
            s.contains('cannot') ||
            s.contains('not allowed') ||
            s.contains('ineligible') ||
            s.contains('blocked'))) {
      return true;
    }
    return false;
  }

  Future<void> _submitComplaint() async {
    if (widget.sessionMarkedOnLeave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_leaveBlockUserMessage)),
      );
      return;
    }
    if (widget.sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing session. Open Report Issue from a session row.')),
      );
      return;
    }
    if (_selectedIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue type')),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    final reason =
        '[${_selectedIssue!}] ${_descriptionController.text.trim()}';

    setState(() => _isLoading = true);
    try {
      await ApiManager.instance.postStudentAttendanceComplaint(
        sessionId: widget.sessionId,
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted to your teacher'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      final msg = _apiMessageSuggestsLeaveComplaintBlock(e.message)
          ? _leaveBlockUserMessage
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blockedByLeave = widget.sessionMarkedOnLeave;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Report Attendance Issue',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (blockedByLeave) ...[
                Material(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade900),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _leaveBlockUserMessage,
                            style: TextStyle(
                              color: Colors.brown.shade900,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.class_outlined,
                          color: ColorPallet.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.courseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.person_outline,
                      'Teacher',
                      widget.teacherName,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'Date',
                      DateFormat('MMM dd, yyyy').format(widget.date),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'What went wrong?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorPallet.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                hint: const Text('Select Issue Type'),
                value: _selectedIssue,
                items: _issueTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged:
                    blockedByLeave ? null : (val) => setState(() => _selectedIssue = val),
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                readOnly: blockedByLeave,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText:
                      'Please describe why you think the attendance is incorrect...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorPallet.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || blockedByLeave) ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPallet.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Complaint',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
