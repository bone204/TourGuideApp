import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/contract_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContractViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<ContractModel> _contracts = [];
  List<ContractModel> get contracts => _contracts;
  StreamSubscription<QuerySnapshot>? _contractSubscription;

  ContractViewModel() {
    // Lắng nghe sự thay đổi trạng thái đăng nhập
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _initContractStream(user.uid);
      } else {
        // Hủy subscription cũ và xóa dữ liệu khi đăng xuất
        _clearContractData();
      }
    });
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
            _contracts.add(ContractModel.fromMap(doc.data() as Map<String, dynamic>));
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

  Future<void> createContractForUser(String uid, Map<String, dynamic> contractData) async {
    String? userId = await _getUserIdFromUid(uid);
    if (userId == null) {
      if (kDebugMode) {
        print("Không tìm thấy userId cho uid: $uid");
      }
      return;
    }

    final contractId = await _generateContractId();
    final newContract = ContractModel(
      contractId: contractId,
      userId: userId,
      businessType: contractData['businessType'],
      businessName: contractData['businessName'],
      businessProvince: contractData['businessProvince'],
      businessAddress: contractData['businessAddress'],
      taxCode: contractData['taxCode'],
      businessRegisterPhoto: contractData['businessRegisterPhoto'],
      citizenFrontPhoto: contractData['citizenFrontPhoto'],
      citizenBackPhoto: contractData['citizenBackPhoto'],
      contractTerm: contractData['contractTerm'],
      contractStatus: contractData['contractStatus'],
    );

    _contracts.add(newContract);
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('CONTRACT')
          .doc(newContract.contractId)
          .set(newContract.toMap());
      if (kDebugMode) {
        print("Hợp đồng đã được lưu vào Firestore");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi lưu hợp đồng vào Firestore: $e");
      }
    }
  }

  Future<String?> _getUserIdFromUid(String uid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('USER')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['userId'] as String?;
      } else {
        if (kDebugMode) {
          print("Không tìm thấy tài liệu người dùng với uid: $uid");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi tìm userId: $e");
      }
      return null;
    }
  }

  Future<String> _generateContractId() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('CONTRACT').get();
    final currentCounter = querySnapshot.size + 1;
    return 'C${currentCounter.toString().padLeft(4, '0')}';
  }
}