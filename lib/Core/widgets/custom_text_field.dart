import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Utils/Colors.dart';

class CustomFormTextField extends StatelessWidget {
  CustomFormTextField({this.hintText, this.onChanged , this.obscureText =false,this.initialValue,this.onSaved});
  Function(String)? onChanged;
  String? hintText;
  String? initialValue;
  Function(dynamic)? onSaved;
  bool? obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsetsDirectional.all(2),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor,borderRadius: BorderRadius.circular(40)),
        child: TextFormField(
          initialValue: initialValue,
          onSaved: onSaved,
          cursorColor: Colors.black,
          style: TextStyle(color: ColorApp.kwhiteColor),
          obscureText:obscureText!,
          validator: (data) {
            if (data!.isEmpty) {
              return '        field is required';
            }
          },
          onChanged: onChanged,
          decoration: InputDecoration(

            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.labelSmall,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none
          ),
          ),
        ),
      ),
    );
  }
}