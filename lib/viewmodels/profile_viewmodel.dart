import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _name = '';
  String _profileImageUrl = '';
  String _email = '';

  String get name => _name;
  String get profileImageUrl => _profileImageUrl;
  String get email => _email;

  ProfileViewModel() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserData();
      } else {
        _clearUserData();
      }
    });
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          _name = data?['name'] ?? 'Unknown';
          _profileImageUrl = data?['profileImageUrl'] ?? ''; // Thêm thuộc tính ảnh đại diện
          _email = data?['email'] ?? 'Unknown';
          notifyListeners();
        } else {
          if (kDebugMode) {
            print("Tài liệu người dùng không tồn tại");
          }
          _clearUserData();
        }
      } catch (e) {
        if (kDebugMode) {
          print("Lỗi khi đọc thông tin người dùng: $e");
        }
        _clearUserData();
      }
    } else {
      if (kDebugMode) {
        print("Người dùng không đăng nhập");
      }
      _clearUserData();
    }
  }

  void _clearUserData() {
    _name = 'Unknown';
    _profileImageUrl = '';
    _email = 'Unknown';
    notifyListeners();
  }
}
