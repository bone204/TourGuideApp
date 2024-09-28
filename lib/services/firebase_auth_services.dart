import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception("Đã xảy ra lỗi không xác định khi đăng ký: $e");
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
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception("Đã xảy ra lỗi không xác định khi đăng nhập: $e");
    }
  }

  // Lưu thông tin người dùng vào Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).set(user.toMap());
    } catch (e) {
      throw Exception("Lỗi khi lưu thông tin người dùng: $e");
    }
  }

  // Lấy thông tin người dùng từ Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Lỗi khi lấy thông tin người dùng: $e");
    }
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Sai mật khẩu.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng bởi một tài khoản khác.';
      case 'operation-not-allowed':
        return 'Hoạt động này không được cho phép.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại kết nối internet của bạn.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }
}
