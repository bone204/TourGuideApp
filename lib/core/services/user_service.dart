import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy user ID hiện tại
  Future<String?> getCurrentUserId() async {
    try {
      // Thử lấy từ Firebase Auth trước
      final user = _auth.currentUser;
      if (user != null) {
        return user.uid;
      }

      // Nếu không có user đăng nhập, lấy từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_user_id');
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  // Lưu user ID vào SharedPreferences
  Future<void> saveCurrentUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', userId);
    } catch (e) {
      print('Error saving current user ID: $e');
    }
  }

  // Xóa user ID khỏi SharedPreferences
  Future<void> clearCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
    } catch (e) {
      print('Error clearing current user ID: $e');
    }
  }

  // Kiểm tra xem user có đăng nhập không
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Lấy thông tin user hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }
} 