import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/services/firebase_auth_services.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool isLoading = false;
  String? errorMessage; // Thêm biến để lưu trữ lỗi

  Future<User?> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // Thông báo cho View biết trạng thái loading và xóa lỗi trước đó

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      return user;
    } catch (e) {
      errorMessage = 'Login failed. Please check your credentials.';
    } finally {
      isLoading = false;
      notifyListeners(); // Thông báo cho View khi quá trình hoàn tất hoặc gặp lỗi
    }
    return null;
  }
}

