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
            backgroundColor: Colors.white,
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
                          'SnapTime sign-in',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.black,
                            fontFamily: 'pacifico',
                          ),
                        ),
                      ],
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

                    CustomLoginTextField(
                      validationRegEx: non_VALIDATION_REGEX,
                      labelText: "USERNAME",
                      secondaryText: "Use unique username",
                      hintText: "username",
                      onChanged: (value) {
                        userName = value;
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    CustomLoginTextField(
                      validationRegEx: PASSWORD_VALIDATION_REGEX,
                      labelText: "Password",
                      secondaryText: "Use Strong Password",
                      hintText: "password",
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed:() async {
                        if (formKey.currentState!.validate()) {
                          Cubit.registerUser(email: '$userName@chato.com', password: password! , userName: userName! );
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
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
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
