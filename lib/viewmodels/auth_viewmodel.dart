import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  String? currentUserId;

  AuthViewModel() {
    _initializeUser();
  }

  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      notifyListeners();
    }
  }

  // Thêm các phương thức khác nếu cần, ví dụ: đăng nhập, đăng xuất, v.v.
}