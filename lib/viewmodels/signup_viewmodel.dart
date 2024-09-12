import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/services/firebase_auth_services.dart';

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<User?> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    _isLoading = false;
    notifyListeners();
    return user;
  }
}
