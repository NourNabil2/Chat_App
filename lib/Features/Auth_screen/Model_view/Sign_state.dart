part of 'Sign_cubit.dart';

@immutable
abstract class SignState {}

class SignInitial extends SignState {}

class LoginSuccess extends SignState {}
class LoginLoading extends SignState {}

class LoginError extends SignState {
 final String? messageErorr;
 LoginError(this.messageErorr);
}

class RegisterSuccess extends SignState {}
class RegisterLoading extends SignState {}
//ignore: must_be_immutable
class RegisterError extends SignState {
  String? messageError;
  RegisterError({required messageError});
}

