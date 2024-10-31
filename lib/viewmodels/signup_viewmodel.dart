import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tourguideapp/services/firebase_auth_services.dart';

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<User?> signUp(String email, String password, String name, String fullName, String address, String gender, String citizenId, String phoneNumber, String nationality, String birthday) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password, name, fullName, address, gender, citizenId, phoneNumber, nationality, birthday);
      if (user != null) {
        return user;
      }
    } catch (e) {
      _errorMessage = 'Đăng ký không thành công. Vui lòng kiểm tra lại thông tin.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<User?> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      _errorMessage = 'Google sign-up failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<User?> signInWithFacebook() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      final accessToken = loginResult.accessToken;
      if (accessToken != null) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        return userCredential.user;
      } else {
        _errorMessage = 'Failed to get access token.';
      }
    } else {
      _errorMessage = 'Facebook sign-up failed: ${loginResult.message}';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}
