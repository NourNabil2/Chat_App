import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Core/widgets/custom_text_field.dart';
import 'package:chats/Features/Auth_screen/Model_view/Sign_cubit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String? email;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor:Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomLoginTextField(
                validationRegEx: EMAIL_VALIDATION_REGEX,
                labelText: "USERNAME",
                hintText: "Your username",
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
    if (formKey.currentState!.validate()) {
      BlocProvider.of<SignCubit>(context).sendPasswordResetEmail(email);
    }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Send Reset Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
