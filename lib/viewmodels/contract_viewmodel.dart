import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/contract_model.dart';

class ContractViewModel extends ChangeNotifier {
  final List<ContractModel> _contracts = [];

  Future<bool> checkContractExistsForUser(String userId) async {
    return _contracts.any((contract) => contract.userId == userId);
  }

  Future<void> createContractForUser(String userId, Map<String, dynamic> contractData) async {
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

    // Lưu hợp đồng vào Firestore
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

  Future<String> _generateContractId() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('CONTRACT').get();
    final currentCounter = querySnapshot.size + 1; // Đếm số lượng tài liệu và tăng thêm 1

    return 'C${currentCounter.toString().padLeft(4, '0')}';
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      } else {
        if (kDebugMode) {
          print("Tài liệu người dùng không tồn tại");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi đọc thông tin người dùng: $e");
      }
    }
    return null;
  }
}