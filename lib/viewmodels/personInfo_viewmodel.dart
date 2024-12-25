import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class PersonInfoViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController citizenIdController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  
  bool isEditing = false;
  
  String? _gender;
  String? get gender => _gender;
  set gender(String? value) {
    _gender = value;
    notifyListeners();
  }
  
  String? _nationality;
  String? get nationality => _nationality;
  set nationality(String? value) {
    _nationality = value;
    notifyListeners();
  }
  
  String _selectedCountryCode = '+84'; // Thêm biến để lưu mã vùng
  String get selectedCountryCode => _selectedCountryCode;
  set selectedCountryCode(String value) {
    _selectedCountryCode = value;
    notifyListeners();
  }
  
  PersonInfoViewModel() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadData();
      } else {
        _clearData();
      }
    });
  }

  // Load data from Firestore
  Future<void> loadData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String uid = user.uid;
        DocumentSnapshot doc = await _firestore.collection('USER').doc(uid).get();
        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          
          // Xử lý số điện thoại
          String fullPhone = data?['phoneNumber'] ?? '';
          if (fullPhone.isNotEmpty) {
            // Loại bỏ khoảng trắng và ký tự không mong muốn
            fullPhone = fullPhone.trim();
            
            // Kiểm tra các mã vùng phổ biến
            final commonCodes = ['+84', '+1', '+44', '+91'];
            bool foundCode = false;
            
            for (String code in commonCodes) {
              if (fullPhone.startsWith(code)) {
                _selectedCountryCode = code;
                // Lấy phần số điện thoại sau mã vùng
                phoneNumberController.text = fullPhone.substring(code.length);
                foundCode = true;
                break;
              }
            }
            
            // Nếu không tìm thấy mã vùng, giữ nguyên số điện thoại
            if (!foundCode) {
              _selectedCountryCode = '+84'; // Mặc định
              phoneNumberController.text = fullPhone;
            }
          }

          // Load các trường khác
          fullnameController.text = data?['fullName'] ?? '';
          genderController.text = data?['gender'] ?? '';
          citizenIdController.text = data?['citizenId'] ?? '';
          addressController.text = data?['address'] ?? '';
          nationalityController.text = data?['nationality'] ?? '';
          birthdayController.text = data?['birthday'] ?? '';
          
          notifyListeners(); // Thông báo UI cập nhật
        } else {
          if (kDebugMode) {
            print('User document does not exist');
          }
          _clearData();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Lỗi khi đọc thông tin người dùng: $e');
        }
        _clearData();
      }
    }
  }

  // Save data to Firestore
  Future<void> saveData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String uid = user.uid;
        
        // Đảm bảo số điện thoại không có khoảng trắng
        String phoneNumber = phoneNumberController.text.trim();
        
        // Ghép mã vùng với số điện thoại
        String fullPhoneNumber = _selectedCountryCode + phoneNumber;

        await _firestore.collection('USER').doc(uid).update({
          'fullName': fullnameController.text,
          'gender': genderController.text,
          'citizenId': citizenIdController.text,
          'phoneNumber': fullPhoneNumber,
          'address': addressController.text,
          'nationality': nationalityController.text,
          'birthday': birthdayController.text,
        });
        
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Lỗi khi cập nhật thông tin người dùng: $e');
        }
      }
    }
  }

  // Clear data
  void _clearData() {
    fullnameController.text = '';
    genderController.text = '';
    citizenIdController.text = '';
    phoneNumberController.text = '';
    addressController.text = '';
    nationalityController.text = '';
    birthdayController.text = '';
    notifyListeners();
  }

  Icon getFieldIcon(String text) {
    if (text.trim().isEmpty) {
      return const Icon(Icons.warning_amber_rounded, color: Colors.red);
    }
    return const Icon(Icons.check_circle, color: Colors.green);
  }
}
