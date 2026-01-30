import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

class AdminEditProfileScreen extends StatefulWidget {
  const AdminEditProfileScreen({super.key});

  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController(
    text: "Administrator",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "admin@facialtrack.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+92 300 1234567",
  );
  final TextEditingController _departmentController = TextEditingController(
    text: "Administration",
  );
  final TextEditingController _idController = TextEditingController(
    text: "ADM-2024-001",
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: ColorPallet.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Update Information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Update your personal details below.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // Name
                _buildTextField(
                  label: "Full Name",
                  hint: "Enter your full name",
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                // Email
                _buildTextField(
                  label: "Email Address",
                  hint: "Enter your email",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Phone
                _buildTextField(
                  label: "Phone Number",
                  hint: "Enter your phone number",
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                // Department (ReadOnly maybe? No, let's allow edit for now or read only if strict)
                // User said "data update kar sakye", implying editability.
                _buildTextField(
                  label: "Department",
                  hint: "Enter department",
                  controller: _departmentController,
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 20),

                // ID (Usually ReadOnly)
                _buildTextField(
                  label: "Employee ID",
                  hint: "ID",
                  controller: _idController,
                  icon: Icons.badge_outlined,
                  isReadOnly: true, // Typically IDs shouldn't change easily
                ),

                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Simulate Save
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile Updated Successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Future.delayed(
                          const Duration(milliseconds: 500),
                          () => Navigator.pop(context),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallet.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: ColorPallet.primaryBlue.withOpacity(0.4),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          style: isReadOnly ? TextStyle(color: Colors.grey.shade600) : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(
              icon,
              color: isReadOnly ? Colors.grey.shade300 : Colors.grey.shade400,
              size: 22,
            ),
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade50 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: ColorPallet.primaryBlue,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (!isReadOnly && (value == null || value.isEmpty)) {
              return "Please enter $label";
            }
            return null;
          },
        ),
      ],
    );
  }
}
