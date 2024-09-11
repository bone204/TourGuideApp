import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// import '../../../global/common/toast.dart';


class FirebaseAuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {

      // if (e.code == 'email-already-in-use') {
      //   showToast(message: 'The email address is already in use.');
      // } else {
      //   showToast(message: 'An error occurred: ${e.code}');
      // }

      if (kDebugMode) {
        print("Some error occured");
      }
    }
    return null;

  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      // if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      //   showToast(message: 'Invalid email or password.');
      // } else {
      //   showToast(message: 'An error occurred: ${e.code}');
      // }
      if (kDebugMode) {
        print("Some error occured");
      }
    }
    return null;

  }
}