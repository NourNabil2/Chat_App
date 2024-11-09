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


class CustomLoginTextField extends StatefulWidget {
  final String? labelText;
  final String? secondaryText;
  final String? hintText;
  final Function(String)? onChanged;
  final bool obscureText;
  final String? initialValue;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final RegExp validationRegEx;

  CustomLoginTextField({
    this.labelText,
    this.secondaryText,
    this.onChanged,
    this.obscureText = false,
    this.initialValue,
    this.onSaved,
    this.validator,
    required this.validationRegEx,
    required this.hintText,

  });

  @override
  _CustomLoginTextFieldState createState() => _CustomLoginTextFieldState();
}

class _CustomLoginTextFieldState extends State<CustomLoginTextField> {
  final FocusNode _focusNode = FocusNode();
  Color _borderColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _borderColor = _focusNode.hasFocus ? Colors.blueAccent : Colors.grey.shade300;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null)
            Text(
              widget.labelText!,
              style: TextStyle(
                color: Colors.blueAccent, // Blue color for label text
                fontSize: 16, // Smaller font size
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4), // Spacing between label and input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white, // Light background color
              border: Border(
                bottom: BorderSide(
                  color: _borderColor, // Dynamic border color based on focus
                  width: 1.5,
                ),
              ),
            ),
            child: TextFormField(
              focusNode: _focusNode,
              initialValue: widget.initialValue,
              onSaved: widget.onSaved,
              cursorColor: Colors.black,
              style: TextStyle(
                color: Colors.black, // Text color set to black
                fontSize: 16, // Larger font size
              ),
              obscureText: widget.obscureText,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your ${widget.hintText!.toLowerCase()}";
                }
                // Check for email validation
                else if (widget.hintText!.toLowerCase() == "username") {
                  if (value.length < 4) {
                    return "username must be at least 4 characters long.";
                  }
                }
                // Check for password validation
                else if (widget.hintText!.toLowerCase() == "password") {
                  if (value.length < 8) {
                    return "Password must be at least 8 characters long.";
                  } else if (!RegExp(r".*[A-Z].*").hasMatch(value)) {
                    return "Password must contain at least one uppercase letter.";
                  } else if (!RegExp(r".*[a-z].*").hasMatch(value)) {
                    return "Password must contain at least one lowercase letter.";
                  } else if (!RegExp(r".*\d.*").hasMatch(value)) {
                    return "Password must contain at least one number.";
                  }
                }

                // If all validations pass
                return null;
              },
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade600, // Hint text color
                  fontSize: 14, // Slightly smaller than main text
                ),
                border: InputBorder.none, // Remove default border
              ),
            ),
          ),
          if (widget.secondaryText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: () {
                  // Define the action for secondary text (like toggling to use phone number)
                },
                child: Text(
                  widget.secondaryText!,
                  style: TextStyle(
                    color: Colors.blueAccent, // Blue color for secondary text
                    fontSize: 12, // Smaller font size for secondary text
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

