import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class PersonInfoViewModel extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController citizenIdController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  
  bool isEditing = false;

  // Load data from Firestore
  Future<void> loadData() async {
    // Lấy userId từ Firebase Authentication
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Get user data from Firestore
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        // Cập nhật giá trị của các controller
        usernameController.text = userDoc['name'] ?? '';
        genderController.text = userDoc['gender'] ?? '';
        citizenIdController.text = userDoc['citizenId'] ?? '';
        phoneNumberController.text = userDoc['phoneNumber'] ?? '';
        addressController.text = userDoc['address'] ?? '';
        nationalityController.text = userDoc['nationality'] ?? '';
        birthdayController.text = userDoc['birthday'] ?? '';
      } else {
        // Xử lý khi tài liệu không tồn tại
        if (kDebugMode) {
          print('User document does not exist');
        }
      }
    } else {
      // Xử lý khi người dùng không được xác thực
      if (kDebugMode) {
        print('User is not authenticated');
      }
    }
  }

  // Save data to Firestore
  Future<void> saveData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': usernameController.text,
        'gender': genderController.text,
        'citizenId': citizenIdController.text,
        'phoneNumber': phoneNumberController.text,
        'address': addressController.text,
        'nationality': nationalityController.text,
        'birthday': birthdayController.text,
      });
      isEditing = false;
      notifyListeners();
    } else {
      // Xử lý khi người dùng không được xác thực
      if (kDebugMode) {
        print('User is not authenticated');
      }
    }
  }

  // Toggle edit mode
  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }
}
