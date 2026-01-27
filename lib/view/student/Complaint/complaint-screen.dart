import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/student/Complaint/submit-complaint-screen.dart';
import 'package:facialtrackapp/widgets/textfield_login.dart';
import 'package:flutter/material.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  bool isDateSelected = false;

  bool isTypeSelected = false;

  String? selectedIssue;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final FocusNode description = FocusNode();
  String descriptions = "";

  bool get isButtonEnabled => descriptions.isNotEmpty;
  final List<String> issueTypes = [
    'Attendance Not Marked',
    'Wrong Entry/Exit Time',
    'App Technical Issue',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },

          child: Icon(Icons.arrow_back, color: ColorPallet.white),
        ),
        title: Text(
          "New Complaint",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorPallet.primaryBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 33,
          left: 20,
          bottom: 20,
          right: 20,
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 11,
                spreadRadius: 3,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Issue Type",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[900],
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  menuMaxHeight: 300,
                  borderRadius: BorderRadius.circular(12),
                  alignment: AlignmentDirectional.bottomStart,
                  dropdownColor: Colors.grey[300],
                  hint: Text(
                    "Select Issue Type",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: ColorPallet.lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isTypeSelected
                            ? ColorPallet.primaryBlue
                            : Colors.grey,
                        width: 2.0,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isTypeSelected
                            ? ColorPallet.primaryBlue
                            : ColorPallet.primaryBlue,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                  ),
                  value: selectedIssue,
                  items: issueTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedIssue = newValue;
                      isTypeSelected = true;
                    });
                  },
                ),
                SizedBox(height: 20),

                Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[900],
                  ),
                ),
                SizedBox(height: 8),
                buildTextFieldDescription(
                  controller: _descriptionController,
                  line: 5,
                  length: 500,

                  activeColor: ColorPallet.primaryBlue,
                  inactiveColor: Colors.grey,
                  focusNode: description,
                  counter:
                      "${_descriptionController.text.length}/500 characters",
                  hint: "Please explain the issue in detail...",

                  onChange: (text) => setState(() {
                    descriptions = text;
                  }),
                ),
                SizedBox(height: 20),

                Text(
                  "Date of Incident",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[900],
                  ),
                ),
                SizedBox(height: 8),

                TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: ColorPallet.lightGray,
                    hintText: "mm/dd/yyyy",
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDateSelected
                            ? ColorPallet.primaryBlue
                            : Colors.grey,
                        width: 2.0,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDateSelected
                            ? ColorPallet.primaryBlue
                            : ColorPallet.primaryBlue,
                        width: 2.0,
                      ),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: const Color.fromARGB(255, 156, 155, 155),
                              onPrimary: Colors.black,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: ColorPallet.primaryBlue,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text =
                            "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
                        isDateSelected = true;
                      });
                    }
                  },
                ),
                SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: isButtonEnabled
                        ? () {
                            // Dialog(child: ComplaintSubmittedScreen());
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         ComplaintSubmittedScreen(),
                            //   ),
                            // );

                            showComplaintSubmittedDialog(context);
                          }
                        : SizedBox.shrink,
                    icon: Icon(Icons.send_outlined, size: 18),
                    label: Text(
                      "Submit Complaint",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? ColorPallet.primaryBlue
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
}
