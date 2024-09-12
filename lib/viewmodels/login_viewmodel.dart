import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/services/firebase_auth_services.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool isLoading = false;

  Future<User?> signIn(String email, String password) async {
    isLoading = true;
    notifyListeners(); // Notify the view to rebuild if needed

    User? user = await _authService.signInWithEmailAndPassword(email, password);

    isLoading = false;
    notifyListeners(); // Notify again after operation completes
    return user;
  }
}
