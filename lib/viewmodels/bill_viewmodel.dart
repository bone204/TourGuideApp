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

  Future<RentalVehicleModel?> getVehicleDetails(String vehicleRegisterId) async {
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
} 