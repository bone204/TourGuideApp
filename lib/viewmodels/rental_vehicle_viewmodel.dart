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
  final Map<String, List<String>> _brandModels = {};
  final Map<String, List<String>> _modelColors = {};
  List<String> _availableBrands = [];

  List<String> get availableBrands => _availableBrands;

  List<String> getModelsForBrand(String brand) {
    return _brandModels[brand] ?? [];
  }

  List<String> getColorsForModel(String model) {
    return _modelColors[model] ?? [];
  }

  String _convertVehicleTypeToFirestore(String displayType, String locale) {
    if (locale == 'vi') {
      return displayType; // Giữ nguyên nếu là ti��ng Việt
    }
    // Chuyển đổi từ tiếng Anh sang tiếng Việt để query
    switch (displayType) {
      case 'Car':
        return 'Ô tô';
      case 'Motorbike':
        return 'Xe máy';
      default:
        return displayType;
    }
  }

  String _convertFirestoreTypeToDisplay(String dbType, String locale) {
    if (locale == 'vi') {
      return dbType; // Giữ nguyên nếu là tiếng Việt
    }
    // Chuyển đổi từ tiếng Việt sang tiếng Anh để hiển thị
    switch (dbType) {
      case 'Ô tô':
        return 'Car';
      case 'Xe máy':
        return 'Motorbike';
      default:
        return dbType;
    }
  }

  Future<void> loadVehicleInformation(String selectedType, String locale) async {
    try {
      final firestoreType = _convertVehicleTypeToFirestore(selectedType, locale);
      
      final snapshot = await _firestore
          .collection('VEHICLE_INFORMATION')
          .where('type', isEqualTo: firestoreType)
          .get();
      
      // Tạo map tạm thời để lưu trữ dữ liệu
      final Map<String, Set<String>> brandModelsTemp = {};
      final Map<String, Set<String>> modelColorsTemp = {};
      final Set<String> brandsSet = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final brand = data['brand'] as String;
        final model = data['model'] as String;
        final color = data['color'] as String;

        brandsSet.add(brand);
        
        // Thêm model vào brand
        if (!brandModelsTemp.containsKey(brand)) {
          brandModelsTemp[brand] = {};
        }
        brandModelsTemp[brand]!.add(model);

        // Thêm color vào model
        if (!modelColorsTemp.containsKey(model)) {
          modelColorsTemp[model] = {};
        }
        modelColorsTemp[model]!.add(color);
      }

      // Chuyển đổi Set thành List và cập nhật state
      _availableBrands = brandsSet.toList()..sort();
      _brandModels.clear();
      _modelColors.clear();

      brandModelsTemp.forEach((brand, models) {
        _brandModels[brand] = models.toList()..sort();
      });

      modelColorsTemp.forEach((model, colors) {
        _modelColors[model] = colors.toList()..sort();
      });

      notifyListeners();
    } catch (e, stack) {
      _logError("Error loading vehicle information", e, stack);
    }
  }

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

  Future<void> createRentalVehicleForUser(String uid, Map<String, dynamic> vehicleData, String locale) async {
    try {
      if (kDebugMode) {
        print("Dữ liệu vehicleData: $vehicleData");
      }

      // Lấy vehicleId từ VEHICLE_INFORMATION
      String vehicleId = '';
      final vehicleSnapshot = await _firestore
          .collection('VEHICLE_INFORMATION')
          .where('brand', isEqualTo: vehicleData['vehicleBrand'])
          .where('model', isEqualTo: vehicleData['vehicleModel'])
          .where('color', isEqualTo: vehicleData['vehicleColor'])
          .get();

      if (kDebugMode) {
        print("Query conditions:");
        print("Brand: ${vehicleData['vehicleBrand']}");
        print("Model: ${vehicleData['vehicleModel']}");
        print("Color: ${vehicleData['vehicleColor']}");
        print("Found documents: ${vehicleSnapshot.docs.length}");
        
        for (var doc in vehicleSnapshot.docs) {
          print("Document ID: ${doc.id}");
          print("Document data: ${doc.data()}");
        }
      }

      if (vehicleSnapshot.docs.isNotEmpty) {
        // Lấy document đầu tiên khớp với điều kiện
        final vehicleDoc = vehicleSnapshot.docs.first;
        vehicleId = vehicleDoc.id;
        
        if (kDebugMode) {
          print("Selected vehicle document ID: $vehicleId");
          print("Vehicle data: ${vehicleDoc.data()}");
          print("Photo URL: ${vehicleDoc.data()['photo']}");
        }
      } else {
        throw Exception("Không tìm thấy thông tin xe phù hợp");
      }

      if (_currentUserId == null) {
        await _updateCurrentUserId(uid);
      }

      if (_currentUserId == null) {
        throw Exception("Không tìm thấy UserId cho UID đã cho");
      }

      final vehicleRegisterId = await _generateVehicleId();
      final newRentalVehicle = RentalVehicleModel(
        vehicleRegisterId: vehicleRegisterId,
        userId: _currentUserId!,
        licensePlate: vehicleData['licensePlate'] ?? '',
        vehicleRegistration: vehicleData['vehicleRegistration'] ?? '',
        vehicleType: _convertFirestoreTypeToDisplay(vehicleData['vehicleType'], locale),
        maxSeats: vehicleData['maxSeats'] ?? 0,
        vehicleBrand: vehicleData['vehicleBrand'],
        vehicleModel: vehicleData['vehicleModel'],
        vehicleColor: vehicleData['vehicleColor'],
        vehicleRegistrationFrontPhoto: vehicleData['vehicleRegistrationFrontPhoto'] ?? '',
        vehicleRegistrationBackPhoto: vehicleData['vehicleRegistrationBackPhoto'] ?? '',
        hourPrice: (vehicleData['hourPrice'] ?? 0).toDouble(),
        dayPrice: (vehicleData['dayPrice'] ?? 0).toDouble(),
        requirements: List<String>.from(vehicleData['requirements'] ?? []),
        contractId: vehicleData['contractId'] ?? '',
        status: vehicleData['status'] ?? 'Pending Approval',
        vehicleId: vehicleId,
      );

      if (kDebugMode) {
        print("Saving rental vehicle with vehicleId: ${vehicleId}");
      }

      await _firestore
          .collection('RENTAL_VEHICLE')
          .doc(newRentalVehicle.vehicleRegisterId)
          .set(newRentalVehicle.toMap());
        
      _vehicles.add(newRentalVehicle);
      notifyListeners();
    } catch (e, stack) {
      _logError("Error creating rental vehicle", e, stack);
      rethrow;
    }
  }

  Future<String> _generateVehicleId() async {
    try {
      final querySnapshot = await _firestore.collection('RENTAL_VEHICLE').get();
      final currentCounter = querySnapshot.size + 1;
      return 'VR${currentCounter.toString().padLeft(4, '0')}';
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

  Future<String> getVehiclePhoto(String vehicleId) async {
    try {
      if (kDebugMode) {
        print("Getting photo for vehicleId: $vehicleId");
      }

      // Kiểm tra vehicleId có giá trị hợp lệ
      if (vehicleId.isEmpty) {
        return 'assets/img/car_default.png';
      }

      final doc = await _firestore
          .collection('VEHICLE_INFORMATION')
          .doc(vehicleId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final photo = data?['photo'] as String?;
        
        if (kDebugMode) {
          print("Document found with ID: $vehicleId");
          print("Photo URL: $photo");
        }
        
        if (photo != null && photo.isNotEmpty) {
          return photo;
        }
      } else {
        if (kDebugMode) {
          print("No document found for vehicleId: $vehicleId");
        }
      }
      
      return 'assets/img/car_default.png';
    } catch (e, stack) {
      if (kDebugMode) {
        print("Error getting vehicle photo: $e");
        print("Stack trace: $stack");
      }
      return 'assets/img/car_default.png';
    }
  }
}
