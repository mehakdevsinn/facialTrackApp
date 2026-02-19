import 'dart:async';
import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:facialtrackapp/view/teacher/Reset%20Password/reset-password-screen.dart';
import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool isButtonEnabled = false;

  late List<FocusNode> focusNodes;

  // @override
  // void initState() {
  //   super.initState();
  //   startTimer();

  //   focusNodes = List.generate(4, (index) => FocusNode());
  // }
  @override
  void initState() {
    super.initState();
    startTimer();

    focusNodes = List.generate(4, (index) => FocusNode());

    for (var controller in otpControllers) {
      controller.addListener(checkIfAllFieldsFilled);
    }
  }

  void checkIfAllFieldsFilled() {
    bool allFilled = otpControllers.every(
      (ctrl) => ctrl.text.trim().isNotEmpty,
    );

    if (allFilled != isButtonEnabled) {
      setState(() {
        isButtonEnabled = allFilled;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  Timer? _timer;
  int _start = 50;

  // @override
  // void initState() {
  //   super.initState();
  //   startTimer();
  // }

  void startTimer() {
    _start = 50;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  // @override
  // void dispose() {
  //   _timer?.cancel();
  //   for (var controller in otpControllers) {
  //     controller.dispose();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Color.fromARGB(255, 77, 77, 77),
                ),
              ),

              const SizedBox(height: 36),

              // Icon Box
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 232, 241, 248),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 32,
                  color: ColorPallet.primaryBlue,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "OTP Verification",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter the verification code we just sent on your\nemail address.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 32),

              // OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                // children: List.generate(4, (index) {
                //   return _otpTextField(otpControllers[index], context);
                // }),
                children: List.generate(4, (index) {
                  return _otpTextField(
                    otpControllers[index],
                    focusNodes[index],
                    index == 0, // first one autoFocus
                  );
                }),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen(),
                            ),
                          );
                        }
                      : SizedBox.shrink,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? ColorPallet.primaryBlue
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    "Verify",
                    style: TextStyle(fontSize: 18, color: ColorPallet.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  _start > 0
                      ? "Didn’t receive code? Resend in 00:${_start.toString().padLeft(2, '0')}"
                      : "Didn't receive code? Resend now",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),

              if (_start == 0)
                Center(
                  child: TextButton(
                    onPressed: () {
                      startTimer();
                      // TODO: resend OTP logic
                    },
                    child: const Text("Resend", style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpTextField(
    TextEditingController controller,
    FocusNode focusNode,
    bool autoFocus,
  ) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: focusNode.hasFocus
                ? const Color.fromARGB(255, 184, 173, 237).withOpacity(
                    0.9,
                  ) // focused shadow
                : Colors.white, // normal shadow
            spreadRadius: focusNode.hasFocus ? 2 : 2,
            blurRadius: focusNode.hasFocus ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color.fromARGB(255, 212, 211, 211),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: ColorPallet.primaryBlue,
              width: 2.5,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            focusNode.nextFocus();
          } else if (value.isEmpty) {
            focusNode.previousFocus();
          }
        },
      ),
    );
  }

  // Widget _otpTextField(TextEditingController controller, BuildContext context) {
  //   return SizedBox(
  //     height: 60,
  //     width: 60,
  //     child: TextField(
  //       controller: controller,
  //       keyboardType: TextInputType.number,
  //       textAlign: TextAlign.center,
  //       maxLength: 1,
  //       style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //       decoration: InputDecoration(
  //         counterText: "",
  //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  //       ),
  //       onChanged: (value) {
  //         if (value.length == 1) {
  //           FocusScope.of(context).nextFocus();
  //         }
  //       },
  //     ),
  //   );
  // }
}
