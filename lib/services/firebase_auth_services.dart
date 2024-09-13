import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart'; // Import model người dùng

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng ký bằng email và mật khẩu
  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, String address) async {
    try {
      // Tạo tài khoản người dùng mới
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // Nếu đăng ký thành công, tạo đối tượng UserModel
        UserModel newUser = UserModel(
          userId: user.uid,
          name: name,
          email: email,
          address: address,
        );

        // Lưu thông tin người dùng vào Firestore
        await saveUserData(newUser);
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred during sign up: $e");
      }
    }
    return null;
  }

  // Đăng nhập bằng email và mật khẩu
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Đăng nhập người dùng hiện tại
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user;
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred during sign in: $e");
      }
    }
    return null;
  }

  // Lưu thông tin người dùng vào Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set(user.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Failed to save user data: $e");
      }
    }
  }

  // Lấy thông tin người dùng từ Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch user data: $e");
      }
    }
    return null;
  }
}
