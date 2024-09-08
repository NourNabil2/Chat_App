import 'package:chats/Core/Utils/constants.dart';
import 'package:chats/Core/widgets/custom_button.dart';
import 'package:chats/Core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../../Core/Functions/show_snack_bar.dart';
import '../../../Core/Utils/Colors.dart';
import '../../Home_Screen/View/MainScreen.dart';
import '../Model_view/Sign_cubit.dart';


class RegisterPage extends StatelessWidget {
  static String id = 'RegisterPage';

  String? email;

  String? userName;

  String? password;

  bool isLoading = false;

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SignCubit Cubit = BlocProvider.of<SignCubit>(context);


    return BlocConsumer<SignCubit, SignState>(
      listener: (context, state) {
        if (state is RegisterLoading)
        {
          isLoading = true;
        }
        else if (state is RegisterSuccess)
        {
          Navigator.pushNamed(context, MainScreen.id);
        }
        else if (state is RegisterError)
        {
          showSnackBar(context, state.messageError!);
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Scaffold(
            backgroundColor: ColorApp.kPrimaryColor,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                  const SizedBox(
                      height: 75,
                    ),
                    Image.asset(
                      kLogo,
                      height: 100,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ChatO sign-in',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontFamily: 'pacifico',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 75,
                    ),
                    const Row(
                      children: [
                        Text(
                          'REGISTER',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomFormTextField(
                      onChanged: (data) {
                        email = data;
                      },
                      hintText: 'Email',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomFormTextField(
                      onChanged: (data) {
                        userName = data;
                      },
                      hintText: 'User Name',
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    CustomFormTextField(
                      onChanged: (data) {
                        password = data;
                      },
                      hintText: 'Password',
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButon(
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          Cubit.registerUser(email: email!, password: password! , userName: userName! );
                        } else {}
                      },
                      text: 'REGISTER',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'already have an account?',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            '  Login',
                            style: TextStyle(
                              color: Color(0xffC7EDE6),
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
        );
      },
    );
  }


}
