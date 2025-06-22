import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_storage/firebase_storage.dart';

class IdCardService {
  final String _apiUrl = 'https://api.fpt.ai/vision/idr/vnm';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _apiKey {
    final apiKey = dotenv.env['CCCD_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key không được cấu hình. Vui lòng kiểm tra file .env');
    }
    return apiKey;
  }

  Future<Map<String, dynamic>> processIdCardImage(String imagePath) async {
    try {
      // Kiểm tra API key
      if (_apiKey.isEmpty) {
        throw Exception('API key không hợp lệ');
      }

      // Kiểm tra file tồn tại
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('File ảnh không tồn tại');
      }

      // Kiểm tra kích thước file
      final int fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) { // 5MB
        throw Exception('Kích thước ảnh vượt quá 5MB');
      }

      // Tạo multipart request
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      
      // Thêm headers
      request.headers.addAll({
        'api-key': _apiKey,
      });

      // Thêm file ảnh
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ),
      );

      // Thêm các tham số khác
      request.fields['type'] = 'id_card';
      request.fields['version'] = 'v2';
      request.fields['format'] = 'json';

      print('Sending request to FPT API...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errorCode'] != null && data['errorCode'] != 0) {
          throw Exception(data['errorMessage'] ?? 'Lỗi xử lý ảnh');
        }
        
        // Xử lý response là một list
        if (data['data'] is List) {
          final List<dynamic> dataList = data['data'];
          if (dataList.isEmpty) {
            throw Exception('Không nhận dạng được thông tin CCCD');
          }
          // Lấy phần tử đầu tiên của list
          return dataList.first;
        }
        
        return data['data'] ?? {};
      } else {
        throw Exception('Lỗi API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lỗi xử lý ảnh CCCD: $e');
      rethrow;
    }
  }

  Future<void> saveIdCardInfo(Map<String, dynamic> idCardData) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Người dùng chưa đăng nhập');

      // Map dữ liệu từ API FPT sang cấu trúc của ứng dụng
      final userInfo = {
        'citizenId': idCardData['id'] ?? '',
        'fullName': idCardData['name'] ?? '',
        'birthday': idCardData['dob'] ?? '',
        'gender': idCardData['sex'] ?? '',
        'address': idCardData['address'] ?? '',
        'nationality': idCardData['nationality'] ?? '',
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Cập nhật thông tin vào Firestore
      await _firestore.collection('USER').doc(userId).update(userInfo);
      
      print('Đã lưu thông tin CCCD thành công');
    } catch (e) {
      print('Lỗi lưu thông tin CCCD: $e');
      throw Exception('Lỗi lưu thông tin CCCD: $e');
    }
  }

  Future<String> uploadIdCardImage(File imageFile, String userId) async {
    try {
      // Lưu vào folder mới: id_card_images/
      final storageRef = FirebaseStorage.instance.ref().child('id_card_images/$userId.jpg');
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Lỗi upload ảnh CCCD: $e');
      throw Exception('Lỗi upload ảnh CCCD: $e');
    }
  }
} 