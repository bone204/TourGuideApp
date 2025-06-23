import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/bill_model.dart';
import '../models/rental_vehicle_model.dart';

class BillViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<BillModel> _userBills = [];

  List<BillModel> get userBills => _userBills;

  Future<void> fetchUserBills() async {
    try {
      // Lấy current user ID
      String? uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Lấy userId từ collection USER
      final userDoc = await _firestore
          .collection('USER')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) return;

      String userId = userDoc.docs.first['userId'];

      // Lấy bills của user
      final billsSnapshot = await _firestore
          .collection('BILL')
          .where('userId', isEqualTo: userId)
          .get();

      _userBills = billsSnapshot.docs
          .map((doc) => BillModel.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user bills: $e');
      }
    }
  }

  Future<RentalVehicleModel?> getVehicleDetails(
      String vehicleRegisterId) async {
    try {
      final vehicleDoc = await _firestore
          .collection('RENTAL_VEHICLE')
          .doc(vehicleRegisterId)
          .get();

      if (!vehicleDoc.exists) return null;

      return RentalVehicleModel.fromMap(vehicleDoc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching vehicle details: $e');
      }
      return null;
    }
  }

  // Cập nhật travelPoint của user
  Future<void> updateUserTravelPoint(
      String userId, int travelPointsUsed, double totalAmount) async {
    try {
      // Trừ điểm đã sử dụng
      if (travelPointsUsed > 0) {
        await _firestore.collection('USER').doc(userId).update({
          'travelPoint': FieldValue.increment(-travelPointsUsed),
        });
      }

      // Cộng điểm thưởng theo quy tắc
      final reward = totalAmount > 500000 ? 2000 : 1000;
      await _firestore.collection('USER').doc(userId).update({
        'travelPoint': FieldValue.increment(reward),
      });

      if (kDebugMode) {
        print(
            'Updated travel point for user $userId: -$travelPointsUsed +$reward');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating travel point: $e');
      }
      throw Exception('Không thể cập nhật điểm thưởng: $e');
    }
  }

  // Tạo bill mới với travelPoint
  Future<String> createBillWithTravelPoint({
    required String userId,
    required String billType,
    required double totalAmount,
    required int travelPointsUsed,
    required Map<String, dynamic> billData,
  }) async {
    try {
      // Tạo bill trong collection tương ứng
      String collectionName = '';
      switch (billType) {
        case 'hotel':
          collectionName = 'HOTEL_BILL';
          break;
        case 'restaurant':
          collectionName = 'RESTAURANT_BILL';
          break;
        case 'bus':
          collectionName = 'BUS_BILL';
          break;
        case 'delivery':
          collectionName = 'DELIVERY_BILL';
          break;
        case 'vehicle_rental':
          collectionName = 'VEHICLE_RENTAL_BILL';
          break;
        default:
          collectionName = 'BILL';
      }

      // Thêm travelPointsUsed vào billData
      billData['travelPointsUsed'] = travelPointsUsed;
      billData['totalAmount'] = totalAmount;

      final docRef = await _firestore.collection(collectionName).add(billData);
      final billId = docRef.id;

      // Cập nhật travelPoint của user
      await updateUserTravelPoint(userId, travelPointsUsed, totalAmount);

      if (kDebugMode) {
        print('Created bill $billId with travel point: $travelPointsUsed');
      }

      return billId;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating bill with travel point: $e');
      }
      throw Exception('Không thể tạo bill: $e');
    }
  }
}
