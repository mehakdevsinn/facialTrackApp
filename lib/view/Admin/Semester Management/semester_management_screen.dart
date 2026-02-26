import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/controller/providers/admin_provider.dart';
import 'package:facialtrackapp/core/models/semester_model.dart';
import 'package:facialtrackapp/view/Admin/Semester%20Management/add_edit_semester_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SemesterManagementScreen extends StatefulWidget {
  const SemesterManagementScreen({super.key});

  @override
  State<SemesterManagementScreen> createState() =>
      _SemesterManagementScreenState();
}

class _SemesterManagementScreenState extends State<SemesterManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always force on first open so the list is fresh each session
      context.read<AdminProvider>().fetchSemesters(force: true);
    });
  }

  Future<void> _openAddScreen() async {
    final created = await Navigator.push<SemesterModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditSemesterScreen(),
      ),
    );
    // provider already updated inside AddEditSemesterScreen on success —
    // no setState needed here; Consumer rebuilds automatically.
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Semester "${created.displayName}" created!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Semester Management',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () =>
                  context.read<AdminProvider>().fetchSemesters(force: true),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddScreen,
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Semester'),
        ),
        body: Consumer<AdminProvider>(
          builder: (context, admin, _) {
            // Loading
            if (admin.isSemestersLoading) {
              return const Center(
                child:
                    CircularProgressIndicator(color: ColorPallet.primaryBlue),
              );
            }

            // Error (only semester-specific errors)
            if (admin.semestersError != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade300, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      admin.semestersError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => admin.fetchSemesters(force: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallet.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Empty
            if (admin.semesters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No semesters yet.\nTap "New Semester" to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            // List
            return RefreshIndicator(
              color: ColorPallet.primaryBlue,
              onRefresh: () => admin.fetchSemesters(force: true),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: admin.semesters.length,
                itemBuilder: (context, index) {
                  final sem = admin.semesters[index];
                  return _SemesterCard(
                    semester: sem,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditSemesterScreen(semester: sem),
                        ),
                      );
                      // Refresh list in case status/details changed
                      if (context.mounted) {
                        context
                            .read<AdminProvider>()
                            .fetchSemesters(force: true);
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Semester Card ────────────────────────────────────────────────────────────
class _SemesterCard extends StatelessWidget {
  final SemesterModel semester;
  final VoidCallback onTap;
  const _SemesterCard({required this.semester, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = semester.statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: semester.isActive
            ? Border.all(color: ColorPallet.primaryBlue, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    semester.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    semester.statusLabel,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.school_outlined,
                        size: 14, color: ColorPallet.primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      'Session: ${semester.academicSession}  •  '
                      '${semester.termLabel} Term  •  Sem ${semester.semesterNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorPallet.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${semester.startDate}  →  ${semester.endDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(
              Icons.edit_outlined,
              color: ColorPallet.primaryBlue,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
