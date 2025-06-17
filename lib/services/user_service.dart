import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserFromIdCard(Map<String, dynamic> idCardData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không tìm thấy người dùng đang đăng nhập');
      }

      // Map dữ liệu từ CMND/CCCD sang các trường trong user
      final Map<String, dynamic> updateData = {
        'fullName': idCardData['name'],
        'citizenId': idCardData['id'],
        'birthday': idCardData['dob'],
        'gender': idCardData['sex'],
        'address': idCardData['address'],
        'nationality': idCardData['nationality'],
      };

      // Cập nhật thông tin lên Firebase
      await _firestore.collection('USER').doc(user.uid).update(updateData);
    } catch (e) {
      print('Lỗi cập nhật thông tin người dùng: $e');
      throw Exception('Không thể cập nhật thông tin người dùng');
    }
  }
} 