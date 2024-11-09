import 'dart:developer';

import 'package:chats/Core/widgets/custom_button.dart';
import 'package:chats/Core/widgets/custom_text_field.dart';
import 'package:chats/Features/Auth_screen/View/login_main.dart';
import 'package:chats/Features/Auth_screen/View/resgister_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../../Core/Functions/CashSaver.dart';
import '../../../Core/Network/API.dart';
import '../../../Core/Utils/Colors.dart';
import '../../../Core/Utils/constants.dart';
import '../../../Core/Functions/show_snack_bar.dart';
import '../../../Core/widgets/component.dart';
import '../../Home_Screen/View/MainScreen.dart';
import '../Model_view/Sign_cubit.dart';

class LoginPage extends StatelessWidget {
  bool isLoading = false;

  static String id = 'login page';

  GlobalKey<FormState> formKey = GlobalKey();
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? email, password;
    SignCubit Cubit = BlocProvider.of<SignCubit>(context);
    return BlocConsumer<SignCubit, SignState>(
      listener: (context, state) async {
        if (state is LoginLoading) {
          isLoading = true;
        } else if (state is LoginSuccess) {
          isLoading = false;
          await CashSaver.SaveData(key: 'Login', value: true).then((value) async {
            if ((await APIs.userExists())) {
            Navigator.pushNamedAndRemoveUntil(
            context,
              MainScreen.id,
            (route) => false,
            );
            } else {
            await APIs.createUser().then((value) {
            Navigator.pushNamed(context, MainScreen.id);
            });
            }

          });
        } else if (state is LoginError) {
          isLoading = false;
          showSnackBar(context, state.messageErorr!);
        }
      },
      builder: (context, state) => ModalProgressHUD(
        progressIndicator: Image.asset(kindicator),
        inAsyncCall: isLoading,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              color: ColorApp.whitechat,
                ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo image at the top
                  Padding(
                    padding: const EdgeInsets.only(top: 100), // Adjust padding as needed
                    child: Image.asset(
                      kLogo, // Replace with your logo path (e.g., kLogo)
                      height: 200,
                    ),
                  ),

                  // Buttons at the bottom
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: Container(
                          color: Color(0xFFFF3B30), // Red color for Login button
                          height: 60,
                          alignment: Alignment.center,
                          child: Text(
                            'LOG IN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterPage()),
                          );
                        },
                        child: Container(
                          color: Color(0xFF007AFF), // Blue color for Sign Up button
                          height: 60,
                          alignment: Alignment.center,
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
