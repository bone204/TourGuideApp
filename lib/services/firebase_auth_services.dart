import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart'; // Import model người dùng

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng ký bằng email và mật khẩu
  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, String fullName, String address, String gender, String citizenId, String phoneNumber, String nationality, String birthday) async {
    try {
      // Tạo tài khoản người dùng mới
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // Lấy userId mới
        String newUserId = await _generateNewUserId();

        // Nếu đăng ký thành công, tạo đối tượng UserModel
        UserModel newUser = UserModel(
          userId: newUserId,
          uid: user.uid,  
          name: name,
          fullName: fullName,
          email: email,
          address: address,
          gender: gender,
          citizenId: citizenId,
          phoneNumber: phoneNumber,
          nationality: nationality,
          birthday: birthday
        );

        // Lưu thông tin người dùng vào Firestore
        await saveUserData(newUser);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng ký: ${e.message}');
      } // In lỗi ra console
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi không xác định khi đăng ký: $e');
      } // In lỗi ra console
      throw Exception("Đã xảy ra lỗi không xác định khi đăng ký: $e");
    }
  }

  Future<String> _generateNewUserId() async {
    try {
      // Truy vấn Firestore để lấy userId lớn nhất
      QuerySnapshot snapshot = await _firestore.collection('USER')
        .orderBy('userId', descending: true)
        .limit(1)
        .get();

      if (snapshot.docs.isNotEmpty) {
        String lastUserId = snapshot.docs.first['userId'];
        int lastIdNumber = int.parse(lastUserId.substring(1));
        return 'U${(lastIdNumber + 1).toString().padLeft(5, '0')}';
      } else {
        return 'U00001'; // Nếu không có user nào, bắt đầu từ U00001
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi tạo userId mới: $e');
      }
      throw Exception("Lỗi khi tạo userId mới: $e");
    }
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
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng nhập: ${e.message}');
      } // In lỗi ra console
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi không xác định khi đăng nhập: $e');
      } // In lỗi ra console
      throw Exception("Đã xảy ra lỗi không xác định khi đăng nhập: $e");
    }
  }

  // Lưu thông tin người dùng vào Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore.collection('USER').doc(user.uid).set(user.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi lưu thông tin người dùng: $e');
      }
      throw Exception("Lỗi khi lưu thông tin người dùng: $e");
    }
  }

  // Lấy thông tin người dùng từ Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('USER').doc(userId).get();
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi lấy thông tin người dùng: $e');
      } // In lỗi ra console
      throw Exception("Lỗi khi lấy thông tin người dùng: $e");
    }
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'Không tìm thấy tài khoản với email này.';
        break;
      case 'wrong-password':
        errorMessage = 'Sai mật khẩu. Vui lòng kiểm tra lại.';
        break;
      case 'invalid-email':
        errorMessage = 'Email không hợp lệ.';
        break;
      case 'user-disabled':
        errorMessage = 'Tài khoản này đã bị vô hiệu hóa.';
        break;
      case 'email-already-in-use':
        errorMessage = 'Email này đã được sử dụng bởi một tài khoản khác.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Hoạt động này không được cho phép.';
        break;
      case 'weak-password':
        errorMessage = 'Mật khẩu quá yếu.';
        break;
      case 'network-request-failed':
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra lại kết nối internet của bạn.';
        break;
      case 'invalid-credential':
        errorMessage = 'Thông tin xác thực không hợp lệ hoặc đã hết hạn.';
        break;
      default:
        errorMessage = 'Đã xảy ra lỗi không xác định: ${e.message}';
    }

    if (kDebugMode) {
      print('FirebaseAuthException: $errorMessage');
    } // In lỗi ra console
    return errorMessage;
  }
}
