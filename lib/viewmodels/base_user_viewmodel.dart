import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BaseUserViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _profileImageUrl = '';
  String _avatar = '';
  int _travelPoint = 0;
  int _travelTrip = 0;
  int _feedbackTimes = 0;
  int _dayParticipation = 0;
  String? _phoneNumber;
  String? _address;
  String? _gender;
  String _userTier = 'Bronze';
  DateTime? _createdAt;
  double _walletBalance = 0.0;

  String get name => _name;
  String get email => _email;
  String get profileImageUrl => _profileImageUrl;
  String get avatar => _avatar;
  int get travelPoint => _travelPoint;
  int get travelTrip => _travelTrip;
  int get feedbackTimes => _feedbackTimes;
  int get dayParticipation => _dayParticipation;
  String? get phoneNumber => _phoneNumber;
  String? get address => _address;
  String? get gender => _gender;
  String get userTier => _userTier;
  DateTime? get createdAt => _createdAt;
  double get walletBalance => _walletBalance;

  BaseUserViewModel() {
    _initUserDataStream();
  }

  void _initUserDataStream() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _firestore
            .collection('USER')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            _name = data['name'] ?? 'Unknown';
            _email = data['email'] ?? 'Unknown';
            _profileImageUrl = data['profileImageUrl'] ?? '';
            _avatar = data['avatar'] ?? '';
            _travelPoint = data['travelPoint'] ?? 0;
            _travelTrip = data['travelTrip'] ?? 0;
            _feedbackTimes = data['feedbackTimes'] ?? 0;
            _createdAt = data['createdAt'] != null
                ? (data['createdAt'] is Timestamp
                    ? (data['createdAt'] as Timestamp).toDate()
                    : DateTime.tryParse(data['createdAt'].toString()))
                : null;
            _dayParticipation = _createdAt == null
                ? 0
                : DateTime.now().difference(_createdAt!).inDays + 1;
            _phoneNumber = data['phoneNumber'];
            _address = data['address'];
            _gender = data['gender'];
            _userTier = data['userTier'] ?? 'Bronze';
            _walletBalance = (data['walletBalance'] ?? 0.0).toDouble();
            notifyListeners();
          } else {
            _clearUserData();
          }
        });
      } else {
        _clearUserData();
      }
    });
  }

  void _clearUserData() {
    _name = 'Unknown';
    _email = 'Unknown';
    _profileImageUrl = '';
    _avatar = '';
    _travelPoint = 0;
    _travelTrip = 0;
    _feedbackTimes = 0;
    _dayParticipation = 0;
    _phoneNumber = null;
    _address = null;
    _gender = null;
    _userTier = 'Bronze';
    _walletBalance = 0.0;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('USER')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          _avatar = userData.data()?['avatar'] ?? '';
          // ... load other user data ...
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Cập nhật số dư ví tiền
  void updateWalletBalance(double newBalance) {
    _walletBalance = newBalance;
    notifyListeners();
  }
}
