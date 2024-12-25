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
  
  String? gender;
  String? nationality;
  String selectedCountryCode = '+84';
  
  bool isLoading = true;
  
  PersonInfoViewModel() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading = true;
      notifyListeners();
      
      final docSnapshot = await _firestore
          .collection('USER')
          .doc(_auth.currentUser?.uid)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        
        fullnameController.text = userData['fullName'] ?? '';
        
        // Cập nhật gender
        String genderValue = userData['gender'] ?? '';
        gender = genderValue;
        genderController.text = genderValue;
        
        citizenIdController.text = userData['citizenId'] ?? '';
        
        // Xử lý số điện thoại
        String fullPhone = userData['phoneNumber'] ?? '';
        if (fullPhone.isNotEmpty) {
          phoneNumberController.text = fullPhone.replaceFirst(selectedCountryCode, '');
        }
        
        addressController.text = userData['address'] ?? '';
        
        // Cập nhật nationality
        String nationalityValue = userData['nationality'] ?? '';
        nationality = nationalityValue;
        nationalityController.text = nationalityValue;
        
        birthdayController.text = userData['birthday'] ?? '';
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Error loading user data: $e');
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
        String fullPhoneNumber = selectedCountryCode + phoneNumber;

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
