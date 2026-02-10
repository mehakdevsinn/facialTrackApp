import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/Admin/Student%20Enrollment/student-enrollment-face.dart';
import 'package:facialtrackapp/view/Student/Face%20Enrolment/student-face-enrolment.dart';
import 'package:facialtrackapp/widgets/textfield_login.dart';
import 'package:flutter/material.dart';

class StudentEnrollmentScreen extends StatefulWidget {
  const StudentEnrollmentScreen({super.key});

  @override
  State<StudentEnrollmentScreen> createState() =>
      _StudentEnrollmentScreenState();
}

class _StudentEnrollmentScreenState extends State<StudentEnrollmentScreen> {
  final FocusNode nameFocus = FocusNode();
  String name = "";

  final FocusNode rollNoFocus = FocusNode();
  String rollNo = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorPallet.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          onPressed: () {},
        ),
        title: const Text(
          "Student Enrollment",
          style: TextStyle(
            color: Colors.white,
            // fontSize: 28,
            // fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: CircleAvatar(
        //       radius: 15,
        //       backgroundColor: Colors.purple.withOpacity(0.3),
        //       child: const Icon(
        //         Icons.person,
        //         size: 18,
        //         color: Colors.purpleAccent,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Basic Information",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter student details before facial tracking.",
              style: TextStyle(
                color: Color.fromARGB(255, 118, 117, 117),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 30),

            // Full Name Field
            _buildLabel("FULL NAME"),
            // _buildTextField(
            //   hint: "e.g. Mehak Fatima",
            //   icon: Icons.person_outline,
            // ),
            buildInfoTextField(
              // suffixIcon: IconButton(
              //   icon: Icon(
              //     _obscureNew ? Icons.visibility_off : Icons.visibility,
              //   ),
              //   onPressed: () {
              //     setState(() => _obscureNew = !_obscureNew);
              //   },
              // ),

              // obscureText: _obscureNew,
              // label: "Password",
              hint: "Enter your Name ",
              icon: Icons.person_2_outlined,
              activeColor: ColorPallet.primaryBlue,
              inactiveColor: Colors.grey,
              focusNode: nameFocus,

              onChange: (value) {
                setState(() {
                  name = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Roll Number Field
            _buildLabel("ROLL NUMBER"),
            buildInfoTextField(
              hint: "E.G. FA21-BCS-089",
              icon: Icons.qr_code_scanner,

              activeColor: ColorPallet.primaryBlue,
              inactiveColor: Colors.grey,
              focusNode: rollNoFocus,

              onChange: (value) {
                setState(() {
                  rollNo = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Semester & Section Row
            // Row(
            //   children: [
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           _buildLabel("SEMESTER"),
            //           buildInfoTextField(hint: "4th Sem",
            //               activeColor: ColorPallet.primaryBlue,
            //   inactiveColor: Colors.grey,
            //   focusNode: rollNoFocus,

            //   onChange: (value) {
            //     setState(() {
            //       rollNo = value;
            //     });
            //   },

            //           ),
            //         ],
            //       ),
            //     ),
            //     const SizedBox(width: 15),
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           _buildLabel("SECTION"),
            //           buildInfoTextField(hint: "Section A",

            //               activeColor: ColorPallet.primaryBlue,
            //   inactiveColor: Colors.grey,
            //   focusNode: rollNoFocus,

            //   onChange: (value) {
            //     setState(() {
            //       rollNo = value;
            //     });
            //   },),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            _buildLabel("SEMESTER"),
            buildInfoTextField(
              hint: "4th Sem",

              icon: Icons.menu_book,
              activeColor: ColorPallet.primaryBlue,
              inactiveColor: Colors.grey,
              focusNode: rollNoFocus,

              onChange: (value) {
                setState(() {
                  rollNo = value;
                });
              },
            ),

            const Spacer(),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPallet.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentFaceEnrolements(),
                      //  FaceEnrollmentScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Proceed to Facial Scan",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Label Widget Helper
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // TextField Widget Helper
  Widget _buildTextField({required String hint, IconData? icon}) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.white38, size: 20)
            : null,
        filled: true,
        fillColor: const Color(0xFF1A1A1C), // Field Background
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }
}
