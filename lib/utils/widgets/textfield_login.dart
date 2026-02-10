import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

Widget buildTextField({
  String? label,
  required String hint,
  required IconData icon,
  bool obscureText = false,
  Widget? suffixIcon,
  // required Color color,
  required final onChange,
  required FocusNode focusNode,
  required Color activeColor,
  required Color inactiveColor,
}) {
  return TextField(
    onChanged: onChange,
    obscureText: obscureText,
    style: TextStyle(color: focusNode.hasFocus ? activeColor : inactiveColor),
    decoration: InputDecoration(
      filled: true,
      fillColor: ColorPallet.lightGray,
      labelText: label ?? "",
      hintText: hint,
      prefixIcon: Icon(icon, color: ColorPallet.grey),
      suffixIcon: suffixIcon,
      suffixIconColor: Colors.grey,
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? activeColor : inactiveColor,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inactiveColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inactiveColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: activeColor, width: 2),
      ),
    ),
  );
}

Widget buildInfoTextField({
  String? label,
  required String hint,
  IconData? icon,
  bool obscureText = false,
  Widget? suffixIcon,
  // required Color color,
  required final onChange,
  required FocusNode focusNode,
  required Color activeColor,
  required Color inactiveColor,
}) {
  return TextField(
    onChanged: onChange,
    obscureText: obscureText,
    style: TextStyle(color: focusNode.hasFocus ? activeColor : inactiveColor),
    decoration: InputDecoration(
      filled: true,
      fillColor: ColorPallet.lightGray,
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: ColorPallet.grey),
      suffixIcon: suffixIcon,
      suffixIconColor: Colors.grey,
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? activeColor : inactiveColor,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inactiveColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inactiveColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: activeColor, width: 2),
      ),
    ),
  );
}

Widget buildTextFieldDescription({
  // String? label,
  String? counter,

  int? line,
  TextEditingController? controller,
  int? length,
  required String hint,
  // required IconData icon,
  bool obscureText = false,
  Widget? suffixIcon,
  // required Color color,
  required final onChange,
  required FocusNode focusNode,
  required Color activeColor,
  required Color inactiveColor,
}) {
  return TextField(
    maxLines: line ?? 1,

    maxLength: length ?? 700,

    controller: controller ?? null,
    onChanged: onChange,
    obscureText: obscureText,
    style: TextStyle(color: focusNode.hasFocus ? activeColor : inactiveColor),
    decoration: InputDecoration(
      counterText: counter ?? null,
      filled: true,
      fillColor: ColorPallet.lightGray,
      // labelText: label ?? "",
      hintText: hint,

      // prefixIcon: Icon(icon, color: ColorPallet.grey),
      suffixIcon: suffixIcon,
      suffixIconColor: Colors.grey,
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? activeColor : inactiveColor,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inactiveColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inactiveColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: activeColor, width: 2),
      ),
    ),
  );
}
