import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _name = '';
  String _email = '';
  String _profileImageUrl = '';

  String get name => _name;
  String get email => _email;
  String get profileImageUrl => _profileImageUrl;

  HomeViewModel() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          // Convert doc.data() to Map<String, dynamic> to access specific fields
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          _name = data?['name'] ?? 'Unknown'; // Use default values if data is missing
          _email = data?['email'] ?? 'Unknown';
          _profileImageUrl = data?['profileImageUrl'] ?? ''; // Add a field for profile image URL
          notifyListeners();
        } else {
          if (kDebugMode) {
            print("User document does not exist");
          }
          _name = 'Unknown';
          _email = 'Unknown';
          _profileImageUrl = '';
          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user data: $e");
        }
        _name = 'Unknown';
        _email = 'Unknown';
        _profileImageUrl = '';
        notifyListeners();
      }
    } else {
      if (kDebugMode) {
        print("User not logged in");
      }
      _name = 'Unknown';
      _email = 'Unknown';
      _profileImageUrl = '';
      notifyListeners();
    }
  }
}
