import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/assignment_data_service.dart';
import 'package:facialtrackapp/view/Admin/Scheme%20of%20Study/add_edit_subject_screen.dart';
import 'package:flutter/material.dart';

class AnimatedAddButton extends StatefulWidget {
  final VoidCallback onTap;
  const AnimatedAddButton({super.key, required this.onTap});

  @override
  State<AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<AnimatedAddButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.9))
            : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ColorPallet.primaryBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ColorPallet.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 4),
            Text(
              "Add Subject",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchemeInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const SchemeInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SchemeDropdownCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SchemeDropdownCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 18,
              ),
              dropdownColor: ColorPallet.primaryBlue,
              isExpanded: true,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SchemeCourseCard extends StatelessWidget {
  final String title;
  final String code;
  final String credits;
  final VoidCallback onEdit;

  const SchemeCourseCard({
    super.key,
    required this.title,
    required this.code,
    required this.credits,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorPallet.primaryBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Side Accent
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                color: ColorPallet.primaryBlue.withOpacity(0.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorPallet.primaryBlue.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: ColorPallet.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF1A1C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      // Only this button should navigate to the edit screen
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorPallet.primaryBlue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: ColorPallet.primaryBlue,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildCourseBadge(
                            Icons.vpn_key_outlined,
                            code,
                            Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildCourseBadge(
                            Icons.stars_rounded,
                            "$credits Credits",
                            Colors.orange,
                          ),
                        ],
                      ),
                      // New Assign Button
                      TextButton.icon(
                        onPressed: () => SchemeDialogs.showAssignTeacherDialog(
                          context,
                          title,
                          code,
                          credits,
                        ),
                        icon: const Icon(Icons.link_rounded, size: 16),
                        label: const Text(
                          "Assign",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: ColorPallet.primaryBlue,
                          backgroundColor: ColorPallet.primaryBlue.withOpacity(
                            0.05,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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

  Widget _buildCourseBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SchemeLabel extends StatelessWidget {
  final String text;
  const SchemeLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10, top: 20),
      child: Text(
        text,
        style: TextStyle(
          color: ColorPallet.primaryBlue.withOpacity(0.6),
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class SchemeModernField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isNum;
  final int maxLines;

  const SchemeModernField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isNum = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: TextStyle(
          color: ColorPallet.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
            child: Icon(icon, color: ColorPallet.primaryBlue, size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
        ),
      ),
    );
  }
}

class SchemeToggleField extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const SchemeToggleField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorPallet.primaryBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: ColorPallet.primaryBlue.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ColorPallet.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class SchemeDialogs {
  static Future<void> showEditDialog({
    required BuildContext context,
    required List<Map<String, dynamic>> currentList,
    int? index,
    required VoidCallback onUpdate,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSubjectScreen(
          initialData: index != null ? currentList[index] : null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (index != null) {
        currentList[index] = result;
      } else {
        currentList.add(result);
      }
      onUpdate();
    }
  }

  static void showAssignTeacherDialog(
    BuildContext context,
    String title,
    String code,
    String credits,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assign Teacher",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: ColorPallet.primaryBlue,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Select faculty for $title ($code)",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ...<Map<String, dynamic>>[
              {
                "name": "Dr. Sarah Ahmed",
                "designation": "Associate Professor",
                "initials": "SA",
              },
              {
                "name": "Prof. Usman Khan",
                "designation": "Head of Department",
                "initials": "UK",
              },
              {
                "name": "Engr. Maria Ali",
                "designation": "Lecturer",
                "initials": "MA",
              },
            ].map(
              (t) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: ColorPallet.primaryBlue.withOpacity(0.1),
                  child: Text(
                    t['initials']!,
                    style: const TextStyle(
                      color: ColorPallet.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  t['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  t['designation']!,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.add_link_rounded,
                  color: ColorPallet.primaryBlue,
                ),
                onTap: () {
                  AssignmentDataService.addSubjectToTeacher(t['name']!, {
                    "course": title,
                    "semester": "2nd Sem",
                    "section": "Section A",
                    "code": code,
                    "credits": credits,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Course assigned to ${t['name']}"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
