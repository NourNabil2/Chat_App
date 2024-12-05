import 'package:chats/Core/Functions/CashSaver.dart';
import 'package:chats/Core/Functions/show_snack_bar.dart';
import 'package:chats/Core/Network/API.dart';
import 'package:chats/Core/Utils/Colors.dart';
import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Core/widgets/custom_text_field.dart';
import 'package:chats/Features/Auth_screen/Model_view/Sign_cubit.dart';
import 'package:chats/Features/Auth_screen/View/ForgetPassword_Page.dart';
import 'package:chats/Features/Home_Screen/View/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Login extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  static String id = 'login page';

  GlobalKey<FormState> formKey = GlobalKey();
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
            await CashSaver.SaveData(key: 'Login', value: true).then((
                value) async {
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
        builder: (context, state) =>
            ModalProgressHUD(
              progressIndicator: Image.asset(kindicator),
              inAsyncCall: isLoading,
              child: Scaffold(
                body: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Form(
                    key: formKey,
                    child: ListView(
                      children: [
                        // Login button
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomLoginTextField(
                          validationRegEx: non_VALIDATION_REGEX,
                          labelText: "USERNAME",
                          hintText: "Your username",
                          onChanged: (value) {
                            email = value;
                          },
                        ),

                        const SizedBox(height: 20),

                        CustomLoginTextField(
                          validationRegEx: non_VALIDATION_REGEX,
                          labelText: "PASSWORD",
                          hintText: "Your password",
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              Cubit.loginUser(username: email!, password: password!);
                            } else {}
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage(),));
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      );
    }

}