
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chats/Core/Functions/CashSaver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import '../../../Core/Network/API.dart';
part 'Sign_state.dart';

class SignCubit extends Cubit<SignState> {
  SignCubit() : super(SignInitial());

  Future<void> loginUser({required String username, required String password}) async {
    emit(LoginLoading());

    try {
      // Step 1: Retrieve email by username
      String email = await getEmailByUsername(username);

      // Step 2: Sign in with email and password
      UserCredential user = await APIs.auth.signInWithEmailAndPassword(email: email, password: password);

      if (user.user != null) {
        emit(LoginSuccess());
      } else {
        emit(LoginError('user-not-found'));
      }
    } on FirebaseAuthException catch (ex) {
      if (ex.code == 'user-not-found') {
        emit(LoginError('user-not-found'));
      } else if (ex.code == 'wrong-password') {
        emit(LoginError('wrong-password'));
      } else {
        emit(LoginError('Wrong Email or Password'));
      }
    } catch (e) {
      emit(LoginError('there was an error'));
    }
  }

// Function to retrieve email based on username
  Future<String> getEmailByUsername(String username) async {
    // Assume you have a Firestore collection named 'users' with 'username' and 'email' fields
    var querySnapshot = await APIs.firestore.collection('Users')
        .where('userName', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['email'];
    } else {
      throw Exception('Username not found');
    }
  }


  Future<void> registerUser({
    required String email,
    required String password,
    required String userName,
  }) async {
    emit(RegisterLoading());
    try {
      // Check if the username is already taken
      final usernameExists = await APIs.checkIfUsernameExists(userName);
      if (usernameExists) {
        emit(RegisterError(messageError: 'Username is already taken'));
        return;
      }

      // Create user with email and password
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Send email verification
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      // Create a new user in Firestore with additional fields
      await APIs.createUserInFirestore(
        user.user!.uid,
        userName,
        email,
      );

      emit(RegisterSuccess());
    } on FirebaseAuthException catch (ex) {
      if (ex.code == 'weak-password') {
        emit(RegisterError(messageError: 'Weak password'));
      } else if (ex.code == 'email-already-in-use') {
        emit(RegisterError(messageError: 'Email already in use'));
      }
      else {
        log('ERORRRRRRR: ');
        return;
      }
    } catch (e) {
      log('ERORRRRRRR: $e');
      emit(RegisterError(messageError: 'There was an error'));
    }
  }


  Future<UserCredential?> _signInWithGoogle() async {
    emit(LoginLoading());
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
       return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      emit(LoginError('Failed login with Google, try again'));

    }
  }

  Future<void> sendPasswordResetEmail(String? email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
      log("Password reset email sent!");
      // Show success message or navigate to confirmation screen
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log("No user found for that email.");
        // Show an appropriate error message to the user
      } else {
        log("Error: ${e.message}");
        // Handle other errors
      }
    }
  }



  handleGoogleBtnClick() {

    _signInWithGoogle().then((user) async {
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        emit(LoginSuccess());
      }
        // if ((await APIs.userExists())) {
        //   Navigator.pushReplacement(
        //       context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        // } else {
        //   await APIs.createUser().then((value) {
        //     Navigator.pushReplacement(
        //         context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        //   }

    });
  }

}
