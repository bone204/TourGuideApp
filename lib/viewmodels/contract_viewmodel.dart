import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourguideapp/models/contract_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ContractViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<ContractModel> _contracts = [];
  List<ContractModel> get contracts => _contracts;
  StreamSubscription<QuerySnapshot>? _contractSubscription;
  String? _currentUserId;

  ContractViewModel() {
    // Lắng nghe sự thay đổi trạng thái đăng nhập
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // Cập nhật userId mới khi user thay đổi
        await _updateCurrentUserId(user.uid);
        _initContractStream(user.uid);
      } else {
        _currentUserId = null;
        _clearContractData();
      }
    });
  }

  Future<void> _updateCurrentUserId(String uid) async {
    try {
      // Thử lấy userId vài lần nếu không tìm thấy ngay
      for (int i = 0; i < 3; i++) {
        QuerySnapshot userSnapshot = await _firestore
            .collection('USER')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          _currentUserId = userSnapshot.docs.first['userId'];
          notifyListeners();
          break;
        }

        // Đợi một chút trước khi thử lại
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi cập nhật userId: $e");
      }
    }
  }

  void _initContractStream(String uid) async {
    // Hủy subscription cũ nếu có
    await _contractSubscription?.cancel();
    
    // Lấy userId từ uid
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('USER')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        String userId = userSnapshot.docs.first['userId'];
        
        // Tạo subscription mới
        _contractSubscription = _firestore
            .collection('CONTRACT')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .listen((snapshot) {
          _contracts.clear();
          for (var doc in snapshot.docs) {
            _contracts.add(ContractModel.fromMap(doc.data()));
          }
          notifyListeners();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi khởi tạo contract stream: $e");
      }
    }
  }

  void _clearContractData() {
    _contractSubscription?.cancel();
    _contractSubscription = null;
    _contracts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _contractSubscription?.cancel();
    super.dispose();
  }

  Future<String> uploadContractPhoto(File photo, String contractId, String type) async {
    try {
      String fileName = '${contractId}_${type}_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
      
      final storageRef = _storage.ref().child('photos/$fileName');
      
      await storageRef.putFile(photo);
      String downloadUrl = await storageRef.getDownloadURL();
      
      if (kDebugMode) {
        print("Contract photo uploaded successfully: $downloadUrl");
      }
      
      return downloadUrl;
    } catch (e, stack) {
      if (kDebugMode) {
        print("Error uploading contract photo: $e");
        print("Stack trace: $stack");
      }
      rethrow;
    }
  }

  Future<void> createContractForUser(String uid, Map<String, dynamic> contractData, String locale) async {
    try {
      if (_currentUserId == null) {
        await _updateCurrentUserId(uid);
      }

      if (_currentUserId == null) {
        throw Exception("Không tìm thấy UserId cho UID đã cho");
      }

      final contractId = await _generateContractId();

      // Upload các ảnh
      String businessRegisterPhotoUrl = '';
      if (contractData['businessRegisterPhoto'] != null && 
          contractData['businessRegisterPhoto'] is File) {
        businessRegisterPhotoUrl = await uploadContractPhoto(
          contractData['businessRegisterPhoto'] as File,
          contractId,
          'business'
        );
      }

      String citizenFrontPhotoUrl = '';
      if (contractData['citizenFrontPhoto'] != null && 
          contractData['citizenFrontPhoto'] is File) {
        citizenFrontPhotoUrl = await uploadContractPhoto(
          contractData['citizenFrontPhoto'] as File,
          contractId,
          'citizen_front'
        );
      }

      String citizenBackPhotoUrl = '';
      if (contractData['citizenBackPhoto'] != null && 
          contractData['citizenBackPhoto'] is File) {
        citizenBackPhotoUrl = await uploadContractPhoto(
          contractData['citizenBackPhoto'] as File,
          contractId,
          'citizen_back'
        );
      }

      final newContract = ContractModel(
        contractId: contractId,
        userId: _currentUserId!,
        businessType: contractData['businessType'],
        businessName: contractData['businessName'],
        businessProvince: contractData['businessProvince'],
        businessAddress: contractData['businessAddress'],
        taxCode: contractData['taxCode'],
        businessRegisterPhoto: businessRegisterPhotoUrl,
        citizenFrontPhoto: citizenFrontPhotoUrl,
        citizenBackPhoto: citizenBackPhotoUrl,
        contractTerm: contractData['contractTerm'],
        contractStatus: contractData['contractStatus'],
        businessLocation: contractData['businessLocation'],
        businessCity: contractData['businessCity'],
        businessDistrict: contractData['businessDistrict'],
      );

      // Lưu contract
      await _firestore
          .collection('CONTRACT')
          .doc(newContract.contractId)
          .set(newContract.toMap());

      // Cập nhật thông tin ngân hàng vào USER collection
      await _firestore
          .collection('USER')
          .where('userId', isEqualTo: _currentUserId)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final userDoc = snapshot.docs.first;
          userDoc.reference.update({
            'bankName': contractData['bankName'],
            'bankAccountNumber': contractData['bankAccountNumber'],
            'bankAccountName': contractData['bankAccountName'],
          });
        }
      });

      _contracts.add(newContract);
      notifyListeners();
    } catch (e, stack) {
      if (kDebugMode) {
        print("Error creating contract: $e");
        print("Stack trace: $stack");
      }
      rethrow;
    }
  }

  Future<String> _generateContractId() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('CONTRACT').get();
    final currentCounter = querySnapshot.size + 1;
    return 'C${currentCounter.toString().padLeft(4, '0')}';
  }

  Future<String> getUserFullName(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('USER')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first['fullName'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi lấy thông tin user: $e");
      }
      return 'Unknown';
    }
  }

  // Thêm các hằng số cho contract status
  final Map<String, String> _contractStatusTranslations = {
    'Chờ duyệt': 'Pending Approval',
    'Đã duyệt': 'Approved',
    'Đã từ chối': 'Rejected',
    'Đã hủy': 'Cancelled',
    'Hết hạn': 'Expired',
  };


  String getDisplayContractStatus(String firestoreStatus, String locale) {
    if (locale == 'vi') return firestoreStatus;
    return _contractStatusTranslations[firestoreStatus] ?? firestoreStatus;
  }
}