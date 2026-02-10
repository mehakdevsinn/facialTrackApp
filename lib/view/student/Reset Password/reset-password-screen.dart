import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/utils/widgets/textfield_login.dart';
import 'package:facialtrackapp/view/Student/Password%20Changed/password-changed-screen.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final FocusNode newpasswordFocus = FocusNode();
  String password = "";

  final FocusNode confirmpasswordFocus = FocusNode();
  String confirmpassword = "";
  bool _obscureText = true;

  bool get isButtonEnabled => password.isNotEmpty && confirmpassword.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.white,
        backgroundColor: Colors.grey[100],

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Color.fromARGB(255, 77, 77, 77),
                ),
              ),
              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 232, 241, 248),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: ColorPallet.primaryBlue,
                ),
              ),

              SizedBox(height: 24),
              Text(
                "New Password",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Your new password must be unique from those previously used.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: 32),

              // // New Password
              // TextFormField(
              //   obscureText: _obscureNew,
              //   decoration: InputDecoration(
              //     labelText: "New Password",
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         _obscureNew ? Icons.visibility_off : Icons.visibility,
              //       ),
              //       onPressed: () {
              //         setState(() {
              //           _obscureNew = !_obscureNew;
              //         });
              //       },
              //     ),
              //   ),
              // ),
              buildTextField(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureNew = !_obscureNew);
                  },
                ),

                obscureText: _obscureNew,
                label: "Password",
                hint: "Enter your New Password ",
                icon: Icons.lock_outline,
                activeColor: ColorPallet.primaryBlue,
                inactiveColor: Colors.grey,
                focusNode: newpasswordFocus,

                onChange: (value) {
                  setState(() {
                    // _obscureNew = !_obscureNew;
                    password = value;
                  });
                },
              ),

              SizedBox(height: 20),
              buildTextField(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),

                obscureText: _obscureConfirm,
                label: "Confirm Password",
                hint: "Enter your Confirm Password ",
                icon: Icons.lock_outline,
                activeColor: ColorPallet.primaryBlue,
                inactiveColor: Colors.grey,
                focusNode: confirmpasswordFocus,
                onChange: (value) {
                  setState(() {
                    // _obscureConfirm = !_obscureConfirm;
                    confirmpassword = value;
                  });
                },
              ),
              // // Confirm Password
              // TextFormField(
              //   obscureText: _obscureConfirm,
              //   decoration: InputDecoration(
              //     labelText: "Confirm Password",
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         _obscureConfirm ? Icons.visibility_off : Icons.visibility,
              //       ),
              //       onPressed: () {
              //         setState(() {
              //           _obscureConfirm = !_obscureConfirm;
              //         });
              //       },
              //     ),
              //   ),
              // ),
              SizedBox(height: 40),

              // Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordChangedScreen(),
                            ),
                          );
                        }
                      : SizedBox.shrink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? ColorPallet.primaryBlue
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorPallet.white,
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
}
