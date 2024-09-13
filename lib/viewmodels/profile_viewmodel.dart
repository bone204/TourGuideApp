import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _name = '';
  String _email = '';

  ProfileViewModel() {
    _loadUserData();
  }

  String get name => _name;
  String get email => _email;

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          // Chuyển đổi doc.data() thành Map<String, dynamic> để truy cập các trường cụ thể
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          _name = data?['name'] ?? 'Unknown'; // Sử dụng giá trị mặc định nếu không có dữ liệu
          _email = data?['email'] ?? 'Unknown';
          notifyListeners();
        } else {
          if (kDebugMode) {
            print("Tài liệu người dùng không tồn tại");
          }
          _name = 'Unknown';
          _email = 'Unknown';
          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) {
          print("Lỗi khi đọc thông tin người dùng: $e");
        }
        _name = 'Unknown';
        _email = 'Unknown';
        notifyListeners();
      }
    } else {
      if (kDebugMode) {
        print("Người dùng không đăng nhập");
      }
      _name = 'Unknown';
      _email = 'Unknown';
      notifyListeners();
    }
  }
}
