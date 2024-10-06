import 'dart:developer';

import 'package:chats/Core/widgets/custom_button.dart';
import 'package:chats/Core/widgets/custom_text_field.dart';
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
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
            decoration: const BoxDecoration(
              color: ColorApp.kPrimaryColor,
                image: DecorationImage(
                    image: AssetImage(kLogoscreen), fit: BoxFit.cover)),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  Image.asset(
                    kLogo,
                    height: 200,
                  ),
                  Center(
                    child: Text(
                      'Wellcome to Chato',
                    style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Box(height: 120),
                  CustomFormTextField(
                    obscureText: false,
                    onChanged: (data) {
                      email = data;
                    },
                    hintText: 'User Name',
                  ),
                  CustomFormTextField(
                    obscureText: true,
                    onChanged: (data) {
                      password = data;
                    },
                    hintText: 'Password',
                  ),
                  Box(height: 20),
                  CustomButon(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        Cubit.loginUser(username: email!, password: password!);
                      } else {}
                    },
                    text: 'LOGIN',
                  ),
                  Box(height: 20),
                  signInWithText(),
                  Box(height: 20),
                  // GoogleButon(
                  //   onTap: () {
                  //     Cubit.handleGoogleBtnClick();
                  //   },
                  //   text: 'Sgin In With Google',
                  // ),
                  Box(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'dont\'t have an account?',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, RegisterPage.id);
                        },
                        child: Text(
                          '  Register',
                          style: TextStyle(
                            color: Color(0xffC7EDE6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Box(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
