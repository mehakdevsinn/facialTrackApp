import 'package:facialtrackapp/constants/color_pallet.dart';
import 'package:flutter/material.dart';

Widget buildTextField({
  required String label,
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


