import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourguideapp/viewmodels/base_user_viewmodel.dart';

class AccountInfoViewModel extends BaseUserViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  
  Future<void> changeProfileImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      final user = _auth.currentUser;
      if (user == null) return;

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${user.uid}.jpg');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore
      await _firestore.collection('USER').doc(user.uid).update({
        'avatar': downloadUrl,
      });

      // Update local state
      await loadUserData();
    } catch (e) {
      print('Error changing profile image: $e');
    }
  }

  Future<void> updateName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Update Firestore
      await _firestore.collection('USER').doc(user.uid).update({
        'name': newName,
      });

      // Update local state
      await loadUserData();
    } catch (e) {
      print('Error updating name: $e');
    }
  }
}
