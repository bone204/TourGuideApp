import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tourguideapp/services/firebase_auth_services.dart';

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<User?> signUp(String email, String password, String name, String address, String gender, String citizenId, String phoneNumber, String nationality, String birthday) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password, name, address,gender, citizenId, phoneNumber, nationality, birthday);
      if (user != null) {
        // Đăng ký thành công và người dùng đã được lưu vào Firestore
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
}
