import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/user_model.dart';
import 'package:facialtrackapp/view/Admin/Manage%20Teachers/teacher_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  // Local filtered list — derived from provider data
  List<UserModel> _displayedTeachers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AdminProvider>();
      // Always refresh on first open so the list is fresh
      admin.fetchTeachers().then((_) {
        _displayedTeachers = List.from(admin.teachers);
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter(String keyword) {
    final all = context.read<AdminProvider>().teachers;
    setState(() {
      _displayedTeachers = keyword.isEmpty
          ? List.from(all)
          : all
              .where((t) =>
                  t.fullName.toLowerCase().contains(keyword.toLowerCase()) ||
                  (t.designation ?? '')
                      .toLowerCase()
                      .contains(keyword.toLowerCase()) ||
                  t.email.toLowerCase().contains(keyword.toLowerCase()))
              .toList();
    });
  }

  void _showAddTeacherSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final designationCtrl = TextEditingController();
    final qualificationCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sheet handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Teacher',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'A secure password will be auto-generated and emailed to the teacher.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),

                _buildLabel('FULL NAME *'),
                _buildTextField(nameCtrl, 'Dr. John Doe', Icons.person_outline),
                const SizedBox(height: 14),

                _buildLabel('EMAIL ADDRESS *'),
                _buildTextField(
                    emailCtrl, 'john.doe@university.edu', Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),

                _buildLabel('PHONE NUMBER'),
                _buildTextField(phoneCtrl, '0300-1234567', Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 14),

                _buildLabel('DESIGNATION'),
                _buildTextField(
                    designationCtrl, 'Associate Professor', Icons.work_outline),
                const SizedBox(height: 14),

                _buildLabel('QUALIFICATION'),
                _buildTextField(qualificationCtrl, 'PhD Computer Science',
                    Icons.school_outlined),
                const SizedBox(height: 28),

                Consumer<AdminProvider>(
                  builder: (ctx, admin, _) {
                    final isSubmitting = admin.isLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isEmpty ||
                                    emailCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text(
                                        'Name and Email are required.'),
                                    backgroundColor: Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: const EdgeInsets.all(16),
                                  ));
                                  return;
                                }

                                final success = await admin.createTeacher(
                                  fullName: nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  phoneNumber: phoneCtrl.text.trim(),
                                  designation: designationCtrl.text.trim(),
                                  qualification: qualificationCtrl.text.trim(),
                                );

                                if (!mounted) return;

                                if (success) {
                                  Navigator.pop(sheetContext);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text(
                                        'Teacher created! Login credentials have been emailed.'),
                                    backgroundColor: Colors.green.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: const EdgeInsets.all(16),
                                  ));
                                  // Sync local display list
                                  setState(() {
                                    _displayedTeachers =
                                        List.from(admin.teachers);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(admin.errorMessage ??
                                        'Something went wrong. Please try again.'),
                                    backgroundColor: Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: const EdgeInsets.all(16),
                                  ));
                                }
                              },
                        icon: isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Icon(Icons.check_circle_outline,
                                color: Colors.white),
                        label: Text(
                          isSubmitting ? 'Creating...' : 'Register Teacher',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPallet.primaryBlue,
                          disabledBackgroundColor:
                              ColorPallet.primaryBlue.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: ColorPallet.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
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
                'Manage Teachers',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddTeacherSheet,
                icon: const Icon(Icons.person_add_alt_1,
                    size: 16, color: ColorPallet.primaryBlue),
                label: const Text('Add New',
                    style: TextStyle(
                        color: ColorPallet.primaryBlue, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _runFilter,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              hintText: 'Search by name, email or designation...',
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isTeachersLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorPallet.primaryBlue),
          );
        }
        if (admin.teachersError != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                const SizedBox(height: 12),
                Text(admin.teachersError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => admin.fetchTeachers().then((_) {
                    setState(() {
                      _displayedTeachers = List.from(admin.teachers);
                    });
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallet.primaryBlue,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        }
        final list = _searchController.text.isEmpty
            ? admin.teachers
            : _displayedTeachers;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_off_outlined,
                    color: Colors.grey.shade300, size: 64),
                const SizedBox(height: 12),
                Text(
                  _searchController.text.isEmpty
                      ? 'No teachers found.\nTap "Add New" to create one.'
                      : 'No results for "${_searchController.text}".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: ColorPallet.primaryBlue,
          onRefresh: () => admin.fetchTeachers().then((_) {
            setState(() {
              _displayedTeachers = List.from(admin.teachers);
            });
          }),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final teacher = list[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeacherDetailScreen(teacher: teacher),
                    ),
                  );
                  // Refresh list in case admin edited details
                  await admin.fetchTeachers();
                  if (mounted) {
                    setState(() {
                      _displayedTeachers = List.from(admin.teachers);
                    });
                  }
                },
                child: _TeacherCard(teacher: teacher),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Teacher Card ─────────────────────────────────────────────────────────────
class _TeacherCard extends StatelessWidget {
  final UserModel teacher;
  const _TeacherCard({required this.teacher});

  String get _initials {
    final parts = teacher.fullName.trim().split(' ');
    return parts
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE8EAF6),
            child: Text(
              _initials,
              style: const TextStyle(
                  color: ColorPallet.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  teacher.designation?.isNotEmpty == true
                      ? teacher.designation!
                      : 'Teacher',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
