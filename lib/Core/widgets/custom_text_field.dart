import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Utils/Colors.dart';

class CustomFormTextField extends StatelessWidget {
  final String? hintText;
  final Function(String)? onChanged;
  final bool obscureText;
  final String? initialValue;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator; // Added validator parameter

  CustomFormTextField({
    this.hintText,
    this.onChanged,
    this.obscureText = false,
    this.initialValue,
    this.onSaved,
    this.validator, // Accept the validator
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsetsDirectional.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: TextFormField(
          initialValue: initialValue,
          onSaved: onSaved,
          cursorColor: Colors.black,
          style: TextStyle(color: ColorApp.kwhiteColor),
          obscureText: obscureText,
          validator: validator ?? (data) { // Use custom validator or default
            if (data == null || data.isEmpty) {
              return 'Field is required';
            }
            return null; // Return null if validation passes
          },
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.labelSmall,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
