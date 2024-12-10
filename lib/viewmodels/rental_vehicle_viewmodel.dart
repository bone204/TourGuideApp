import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/models/rental_vehicle_model.dart';

class RentalVehicleViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<RentalVehicleModel> _vehicles = [];
  List<RentalVehicleModel> get vehicles => _vehicles;
  StreamSubscription<QuerySnapshot>? _rentalVehicleSubscription;
  String? _currentUserId;

  RentalVehicleViewModel() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _updateCurrentUserId(user.uid);
        _initRentalVehicleStream(user.uid);
      } else {
        _currentUserId = null;
        _clearRentalVehicleData();
      }
    });
  }

  Future<void> _updateCurrentUserId(String uid) async {
    try {
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
        await Future.delayed(const Duration(seconds: 1));
      }
    } on FirebaseException catch (e, stack) {
      _logError("FirebaseException when updating userId", e, stack);
    } catch (e, stack) {
      _logError("Unexpected error when updating userId", e, stack);
    }
  }

  void _initRentalVehicleStream(String uid) async {
    await _rentalVehicleSubscription?.cancel();

    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('USER')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        String userId = userSnapshot.docs.first['userId'];

        _rentalVehicleSubscription = _firestore
            .collection('RENTAL_VEHICLE')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .listen((snapshot) {
          _vehicles.clear();
          for (var doc in snapshot.docs) {
            _vehicles.add(RentalVehicleModel.fromMap(doc.data() as Map<String, dynamic>));
          }
          notifyListeners();
        });
      }
    } on FirebaseException catch (e, stack) {
      _logError("FirebaseException when initializing rental vehicle stream", e, stack);
    } catch (e, stack) {
      _logError("Unexpected error when initializing rental vehicle stream", e, stack);
    }
  }

  void _clearRentalVehicleData() {
    _rentalVehicleSubscription?.cancel();
    _rentalVehicleSubscription = null;
    _vehicles.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _rentalVehicleSubscription?.cancel();
    super.dispose();
  }

  Future<void> createRentalVehicleForUser(String uid, Map<String, dynamic> vehicleData) async {
    try {
      if (kDebugMode) {
        print("Dữ liệu vehicleData: $vehicleData");
      }

      if (_currentUserId == null) {
        await _updateCurrentUserId(uid);
      }

      if (_currentUserId == null) {
        throw Exception("UserId not found for the given UID");
      }

      await Future.delayed(const Duration(seconds: 1));

      final vehicleId = await _generateVehicleId();
      final newRentalVehicle = RentalVehicleModel(
        vehicleId: vehicleId,
        userId: _currentUserId!,
        licensePlate: vehicleData['licensePlate'],
        vehicleRegistration: vehicleData['vehicleRegistration'],
        vehicleType: vehicleData['vehicleType'],
        maxSeats: vehicleData['maxSeats'],
        vehicleBrand: vehicleData['vehicleBrand'],
        vehicleModel: vehicleData['vehicleModel'],
        description: vehicleData['description'],
        vehicleRegistrationFrontPhoto: vehicleData['vehicleRegistrationFrontPhoto'],
        vehicleRegistrationBackPhoto: vehicleData['vehicleRegistrationBackPhoto'],
        hourPrice: vehicleData['hourPrice'],
        dayPrice: vehicleData['dayPrice'],
        requirements: vehicleData['requirements'],
        contractId: vehicleData['contractId'],
        status: vehicleData['status'],
      );

      await _firestore.collection('RENTAL_VEHICLE').doc(newRentalVehicle.vehicleId).set(newRentalVehicle.toMap());
      _vehicles.add(newRentalVehicle);
      notifyListeners();
    } on FirebaseException catch (e, stack) {
      _logError("FirebaseException when creating rental vehicle", e, stack);
      rethrow;
    } catch (e, stack) {
      _logError("Unexpected error when creating rental vehicle", e, stack);
      rethrow;
    }
  }

  Future<String> _generateVehicleId() async {
    try {
      final querySnapshot = await _firestore.collection('RENTAL_VEHICLE').get();
      final currentCounter = querySnapshot.size + 1;
      return 'V${currentCounter.toString().padLeft(4, '0')}';
    } on FirebaseException catch (e, stack) {
      _logError("FirebaseException when generating vehicle ID", e, stack);
      rethrow;
    } catch (e, stack) {
      _logError("Unexpected error when generating vehicle ID", e, stack);
      rethrow;
    }
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
    } on FirebaseException catch (e, stack) {
      _logError("FirebaseException when getting user full name", e, stack);
      return 'Unknown';
    } catch (e, stack) {
      _logError("Unexpected error when getting user full name", e, stack);
      return 'Unknown';
    }
  }

  void _logError(String message, Object error, StackTrace stack) {
    if (kDebugMode) {
      print("$message: $error");
      print("Stack trace: $stack");
    }
  }
}
