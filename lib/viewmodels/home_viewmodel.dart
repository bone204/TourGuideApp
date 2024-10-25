import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _profileImageUrl = '';

  String get name => _name;
  String get email => _email;
  String get profileImageUrl => _profileImageUrl;

  HomeViewModel() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserData();
      } else {
        _clearData();
      }
    });
  }

  // Hàm tải dữ liệu người dùng
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          _name = data?['name'] ?? 'Unknown';
          _email = data?['email'] ?? 'Unknown';
          _profileImageUrl = data?['profileImageUrl'] ?? '';
        } else {
          _clearData();
        }
      } catch (e) {
        _clearData();
      }
      notifyListeners();
    }
  }

  // Hàm xóa dữ liệu cũ
  void _clearData() {
    _name = 'Unknown';
    _email = 'Unknown';
    _profileImageUrl = '';
    notifyListeners();
  }
}

