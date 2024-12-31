import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BaseUserViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _name = '';
  String _email = '';
  String _profileImageUrl = '';
  String _avatar = '';

  String get name => _name;
  String get email => _email;
  String get profileImageUrl => _profileImageUrl;
  String get avatar => _avatar;

  BaseUserViewModel() {
    _initUserDataStream();
  }

  void _initUserDataStream() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        // Sử dụng stream thay vì Future
        _firestore
            .collection('USER')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            _name = data['name'] ?? 'Unknown';
            _email = data['email'] ?? 'Unknown';
            _profileImageUrl = data['profileImageUrl'] ?? '';
            _avatar = data['avatar'] ?? '';
            notifyListeners();
          } else {
            _clearUserData();
          }
        });
      } else {
        _clearUserData();
      }
    });
  }

  void _clearUserData() {
    _name = 'Unknown';
    _email = 'Unknown';
    _profileImageUrl = '';
    _avatar = '';
    notifyListeners();
  }

  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('USER')
            .doc(user.uid)
            .get();
            
        if (userData.exists) {
          _avatar = userData.data()?['avatar'] ?? '';
          // ... load other user data ...
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
} 