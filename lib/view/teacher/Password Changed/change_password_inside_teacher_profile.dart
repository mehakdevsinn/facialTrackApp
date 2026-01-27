import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers to get text values
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Default back button ko khatam kiya
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          
          title: Row(
            children: [
        IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
      Navigator.pop(context);
        },
      ),
        
              const Text("Change Password",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          ),   body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create New Password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Your new password must be different from previous used passwords.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Old Password
              _buildAnimatedTextField(
                label: "Old Password",
                hint: "Enter your current password",
                controller: _oldPassController,
                isObscure: _obscureOld,
                toggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter old password";
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // New Password
              _buildAnimatedTextField(
                label: "New Password",
                hint: "Enter new password",
                controller: _newPassController,
                isObscure: _obscureNew,
                toggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value == null || value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Confirm Password
              _buildAnimatedTextField(
                label: "Confirm Password",
                hint: "Repeat new password",
                controller: _confirmPassController,
                isObscure: _obscureConfirm,
                toggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value != _newPassController.text) {
                    return "Passwords do not match!";
                  }
                  if (value == null || value.isEmpty) return "Please confirm your password";
                  return null;
                },
              ),

              const SizedBox(height: 50),

              // Submit Button
              Center(
                child: SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Agar validation pass ho gayi (matching successful)
                        _showSuccessDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF27121),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      shadowColor: const Color(0xFFF27121).withOpacity(0.4),
                    ),
                    child: const Text(
                      "Update Password",
                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
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

  // Success Popup Logic
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            const Text("Success!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Your password has been updated successfully.", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to profile
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF27121)),
              child: const Text("Done", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback toggleVisibility,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction, // Real-time checking
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFF27121), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}