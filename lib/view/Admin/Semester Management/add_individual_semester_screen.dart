import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class AddIndividualSemesterScreen extends StatefulWidget {
  final Map<String, dynamic>? semester;
  final bool isEditing;

  const AddIndividualSemesterScreen({
    super.key,
    this.semester,
    this.isEditing = false,
  });

  @override
  State<AddIndividualSemesterScreen> createState() =>
      _AddIndividualSemesterScreenState();
}

class _AddIndividualSemesterScreenState
    extends State<AddIndividualSemesterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController sessionController;
  late String selectedSemester;
  late String selectedType;
  late String selectedStatus;
  late DateTime startDate;
  late DateTime endDate;

  final List<String> _semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];
  final List<String> _types = ["Spring", "Fall", "Summer"];
  final List<String> _statuses = ["Active", "Upcoming", "Completed"];

  @override
  void initState() {
    super.initState();
    sessionController = TextEditingController(
      text: widget.isEditing ? widget.semester!['session'].toString() : "",
    );
    selectedSemester = widget.isEditing
        ? widget.semester!['semesterNo'].toString()
        : "1";
    selectedType = widget.isEditing
        ? widget.semester!['type'].toString()
        : "Spring";
    selectedStatus = widget.isEditing
        ? widget.semester!['status'].toString()
        : "Active";
    startDate = widget.isEditing
        ? DateTime.parse(widget.semester!['startDate'])
        : DateTime.now();
    endDate = widget.isEditing
        ? DateTime.parse(widget.semester!['endDate'])
        : DateTime.now().add(const Duration(days: 120));
  }

  @override
  void dispose() {
    sessionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorPallet.primaryBlue,
              onPrimary: Colors.white,
              onSurface: ColorPallet.darkGray,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate.isBefore(startDate)) {
            endDate = startDate.add(const Duration(days: 120));
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            widget.isEditing ? "Modify Semester" : "Create New Semester",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  "Identification",
                  Icons.fingerprint_rounded,
                ),
                _buildModernContainer([
                  _buildTextField(
                    controller: sessionController,
                    label: "Academic Session",
                    hint: "e.g. 2021-2025",
                    icon: Icons.history_edu_rounded,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildCustomDropdown(
                          value: selectedSemester,
                          label: "No",
                          items: _semesters,
                          icon: Icons.layers_rounded,
                          onChanged: (val) =>
                              setState(() => selectedSemester = val!),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 6,
                        child: _buildCustomDropdown(
                          value: selectedType,
                          label: "Term Type",
                          items: _types,
                          icon: Icons.category_rounded,
                          onChanged: (val) =>
                              setState(() => selectedType = val!),
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 30),
                _buildSectionHeader(
                  "Timeline & Status",
                  Icons.shutter_speed_rounded,
                ),
                _buildModernContainer([
                  _buildCustomDropdown(
                    value: selectedStatus,
                    label: "Operating Status",
                    items: _statuses,
                    icon: Icons.info_outline_rounded,
                    onChanged: (val) => setState(() => selectedStatus = val!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernDatePicker(
                          label: "Start",
                          date: startDate,
                          onTap: () => _selectDate(context, true),
                          icon: Icons.event_available_rounded,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildModernDatePicker(
                          label: "End",
                          date: endDate,
                          onTap: () => _selectDate(context, false),
                          icon: Icons.event_busy_rounded,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 40),
                _buildGradientButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorPallet.primaryBlue.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.blueGrey.withOpacity(0.03)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: ColorPallet.primaryBlue,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFFBFBFE),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? "Field Required" : null,
    );
  }

  Widget _buildCustomDropdown({
    required String value,
    required String label,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorPallet.primaryBlue, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        filled: true,
        fillColor: const Color(0xFFFBFBFE),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
    );
  }

  Widget _buildModernDatePicker({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueGrey.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _formatDate(date),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: ColorPallet.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [ColorPallet.primaryBlue, Color(0xFF4F46E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPallet.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newSemester = {
              "session": sessionController.text,
              "semesterNo": selectedSemester,
              "type": selectedType,
              "status": selectedStatus,
              "startDate": startDate.toString().split(' ')[0],
              "endDate": endDate.toString().split(' ')[0],
            };
            Navigator.pop(context, newSemester);
          }
        },
        child: Text(
          widget.isEditing ? "UPDATE SEMESTER" : "INITIALIZE SEMESTER",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
