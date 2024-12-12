import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:tourguideapp/models/rental_vehicle_model.dart';

class RentalVehicleViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
      return displayType; // Giữ nguyên nếu là tiếng Việt
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
            var data = doc.data();
            if (data['status'] != null) {
              _vehicles.add(RentalVehicleModel.fromMap(data));
            }
          }
          notifyListeners();
        }, onError: (error) {
          if (kDebugMode) {
            print("Error in rental vehicle stream: $error");
          }
        });
      }
    } catch (e, stack) {
      _logError("Error initializing rental vehicle stream", e, stack);
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

  Future<String> uploadVehiclePhoto(File photo, String vehicleRegisterId, String type) async {
    try {
      String fileName = '${vehicleRegisterId}_${type}_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
      
      final storageRef = _storage.ref().child('photos/$fileName');
      
      await storageRef.putFile(photo);
      String downloadUrl = await storageRef.getDownloadURL();
      
      if (kDebugMode) {
        print("Vehicle photo uploaded successfully: $downloadUrl");
      }
      
      return downloadUrl;
    } catch (e, stack) {
      if (kDebugMode) {
        print("Error uploading vehicle photo: $e");
        print("Stack trace: $stack");
      }
      rethrow;
    }
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

      // Upload ảnh đăng ký xe mặt trước
      String frontPhotoUrl = '';
      if (vehicleData['vehicleRegistrationFrontPhoto'] != null && 
          vehicleData['vehicleRegistrationFrontPhoto'] is File) {
        frontPhotoUrl = await uploadVehiclePhoto(
          vehicleData['vehicleRegistrationFrontPhoto'] as File,
          vehicleRegisterId,
          'registration_front'
        );
      }

      // Upload ảnh đăng ký xe mặt sau
      String backPhotoUrl = '';
      if (vehicleData['vehicleRegistrationBackPhoto'] != null && 
          vehicleData['vehicleRegistrationBackPhoto'] is File) {
        backPhotoUrl = await uploadVehiclePhoto(
          vehicleData['vehicleRegistrationBackPhoto'] as File,
          vehicleRegisterId,
          'registration_back'
        );
      }

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
        vehicleRegistrationFrontPhoto: frontPhotoUrl,
        vehicleRegistrationBackPhoto: backPhotoUrl,
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

  Future<void> updateVehicleStatus(String vehicleRegisterId, String newStatus) async {
    try {
      await _firestore
          .collection('RENTAL_VEHICLE')
          .doc(vehicleRegisterId)
          .update({'status': newStatus});
    } catch (e, stack) {
      _logError("Error updating vehicle status", e, stack);
      rethrow;
    }
  }

  Future<void> deleteOldPhoto(String photoUrl) async {
    try {
      if (photoUrl.isNotEmpty && photoUrl.startsWith('https://firebasestorage.googleapis.com')) {
        final ref = _storage.refFromURL(photoUrl);
        await ref.delete();
        if (kDebugMode) {
          print("Old photo deleted successfully");
        }
      }
    } catch (e, stack) {
      _logError("Error deleting old photo", e, stack);
    }
  }
}
