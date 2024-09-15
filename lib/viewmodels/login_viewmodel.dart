import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tourguideapp/services/firebase_auth_services.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool isLoading = false;
  String? errorMessage; // Biến lưu trữ thông báo lỗi

  // Đăng nhập với Email và Password
  Future<User?> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null; // Xóa lỗi trước đó
    notifyListeners(); // Thông báo cho View cập nhật trạng thái

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'Login failed. Please try again later.';
      }
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners(); // Thông báo cho View khi quá trình hoàn tất hoặc gặp lỗi
    }
    return null;
  }

  // Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading = false;
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
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with a different credential.';
          break;
        case 'invalid-credential':
          errorMessage = 'The credential is invalid or expired.';
          break;
        default:
          errorMessage = 'Login with Google failed. Please try again.';
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error during Google sign-in: $e');
      }
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
      errorMessage = 'An unexpected error occurred during Google login.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
