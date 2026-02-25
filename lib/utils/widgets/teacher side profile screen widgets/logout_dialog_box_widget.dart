import 'package:facialtrackapp/controller/providers/auth_provider.dart';
import 'package:facialtrackapp/controller/providers/teacher_provider.dart';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Role%20Selection/role_selcetion_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogoutDialog {
  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -200, 0.0),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side:
                    BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              content: Container(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: ColorPallet.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.power_settings_new_rounded,
                        size: 50,
                        color: ColorPallet.orange,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Ready to Leave?",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Are you sure you\nwant to logout?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Not yet",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _logoutConfirmButton(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _logoutConfirmButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: ColorPallet.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.pop(context); // close dialog first
          final auth = context.read<AuthProvider>();
          context.read<TeacherProvider>().clear();
          await auth.logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              (route) => false,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPallet.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("Yes, Logout"),
      ),
    );
  }
}
