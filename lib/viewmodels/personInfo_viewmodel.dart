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
        // Sử dụng userId trực tiếp từ FirebaseAuth
        String uid = user.uid;

        // Truy vấn thông tin người dùng bằng userId từ collection 'USER'
        DocumentSnapshot doc = await _firestore.collection('USER').doc(uid).get();
        if (doc.exists) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          // Cập nhật giá trị của các controller
          fullnameController.text = data?['fullName'] ?? '';
          genderController.text = data?['gender'] ?? '';
          citizenIdController.text = data?['citizenId'] ?? '';
          phoneNumberController.text = data?['phoneNumber'] ?? '';
          addressController.text = data?['address'] ?? '';
          nationalityController.text = data?['nationality'] ?? '';
          birthdayController.text = data?['birthday'] ?? '';
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
        // Sử dụng userId trực tiếp từ FirebaseAuth
        String uid = user.uid;

        // Cập nhật thông tin người dùng bằng userId trong collection 'USER'
        await _firestore.collection('USER').doc(uid).update({
          'fullName': fullnameController.text,
          'gender': genderController.text,
          'citizenId': citizenIdController.text,
          'phoneNumber': phoneNumberController.text,
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
