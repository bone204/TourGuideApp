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
  List<String> _availableBrands = [];
  Map<String, List<String>> _modelsByBrand = {};
  Map<String, List<String>> _colorsByModel = {};

  List<String> get availableBrands => _availableBrands;

  List<String> getModelsForBrand(String brand) {
    return _modelsByBrand[brand] ?? [];
  }

  List<String> getColorsForModel(String model, String locale) {
    final colors = _colorsByModel[model] ?? [];
    if (locale == 'en') {
      return colors.map((color) => getDisplayColor(color, locale)).toList();
    }
    return colors;
  }

  String _convertVehicleTypeToFirestore(String displayType, String locale) {
    // Luôn convert về tiếng Việt để lưu
    switch (displayType) {
      case 'Car':
      case 'Ô tô':
        return 'Ô tô';
      case 'Motorbike':
      case 'Xe máy':
        return 'Xe máy';
      default:
        return displayType;
    }
  }

  String _convertFirestoreTypeToDisplay(String dbType, String locale) {
    if (locale == 'en') {
      switch (dbType) {
        case 'Car':
          return 'Car';
        case 'Motorbike':
          return 'Motorbike';
        default:
          return dbType;
      }
    }
    return dbType;
  }

  // Chỉ giữ lại translations cho màu sắc
  final Map<String, String> _colorTranslations = {
    'Đen': 'Black',
    'Trắng': 'White',
    'Đỏ': 'Red',
    'Xanh Dương': 'Blue',
    'Xanh Lá': 'Green',
    'Bạc': 'Silver',
    'Xám': 'Gray',
    'Nâu': 'Brown',
    'Vàng': 'Yellow',
    'Cam': 'Orange',
    'Tím': 'Purple',
    'Hồng': 'Pink',
    'Kem': 'Beige',
    'Đồng': 'Bronze',
    'Vàng Cát': 'Sand',
  };

  String _translateColor(String colorName, String targetLocale) {
    if (targetLocale == 'vi') {
      // Chuyển từ tiếng Anh sang tiếng Việt
      return _colorTranslations.entries
          .firstWhere(
            (entry) => entry.value == colorName,
            orElse: () => MapEntry(colorName, colorName)
          )
          .key;
    } else {
      // Chuyển từ tiếng Việt sang tiếng Anh
      return _colorTranslations[colorName] ?? colorName;
    }
  }

  Future<void> loadVehicleInformation(String vehicleType, String locale) async {
    try {
      String queryType = _convertVehicleTypeToFirestore(vehicleType, 'vi');
      
      if (kDebugMode) {
        print('Loading vehicle information for type: $queryType');
      }

      final snapshot = await _firestore
          .collection('VEHICLE_INFORMATION')
          .where('type', isEqualTo: queryType)
          .get();

      Map<String, Set<String>> brandModels = {};
      Map<String, Set<String>> modelColors = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final brand = data['brand'] as String;
        final model = data['model'] as String;
        final color = data['color'] as String;

        if (!brandModels.containsKey(brand)) {
          brandModels[brand] = {};
        }
        brandModels[brand]!.add(model);

        if (!modelColors.containsKey(model)) {
          modelColors[model] = {};
        }
        modelColors[model]!.add(color);
      }

      _availableBrands = brandModels.keys.toList()..sort();
      _modelsByBrand = Map.fromEntries(
        brandModels.entries.map((e) => MapEntry(e.key, e.value.toList()..sort()))
      );
      _colorsByModel = Map.fromEntries(
        modelColors.entries.map((e) => MapEntry(e.key, e.value.toList()..sort()))
      );

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading vehicle information: $e');
      }
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

  Future<int> getSeatingCapacity(String vehicleId) async {
    try {
      final doc = await _firestore.collection('VEHICLE_INFORMATION').doc(vehicleId).get();
      if (doc.exists) {
        final data = doc.data();
        // Kiểm tra và chuyển seatingCapacity từ String sang int
        String? seatingCapacityString = data?['seatingCapacity'];
        if (seatingCapacityString != null) {
          // Cố gắng chuyển đổi từ String sang int
          return int.tryParse(seatingCapacityString) ?? 0;  // Trả về 0 nếu không thể chuyển đổi
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting seating capacity: $e");
      }
      return 0;
    }
  }

  Future<Map<String, dynamic>> getVehicleDetailsById(String vehicleId) async {
    try {
      final doc = await _firestore.collection('VEHICLE_INFORMATION').doc(vehicleId).get();
      if (doc.exists) {
        final data = doc.data();
        return {
          'brand': data?['brand'] ?? '',
          'fuelType': data?['fuelType'] ?? '',
          'transmission': data?['transmission'] ?? '',
          'maxSpeed': data?['maxSpeed'] ?? '',
        };
      }
      return {
        'brand': '',
        'fuelType': '',
        'transmission': '',
        'maxSpeed': '',
      };
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vehicle details: $e");
      }
      return {
        'brand': '',
        'fuelType': '',
        'transmission': '',
        'maxSpeed': '',
      };
    }
  }

  Future<void> createRentalVehicleForUser(String uid, Map<String, dynamic> vehicleData, String locale) async {
    try {
      String queryType = _convertVehicleTypeToFirestore(vehicleData['vehicleType'], 'vi');
      String queryColor = locale == 'en' 
          ? _translateColor(vehicleData['vehicleColor'], 'vi')
          : vehicleData['vehicleColor'];

      if (kDebugMode) {
        print("\n=== Query conditions to find vehicleId ===");
        print("type: $queryType");
        print("brand: ${vehicleData['vehicleBrand']}");
        print("model: ${vehicleData['vehicleModel']}");
        print("color: $queryColor");
      }

      final vehicleSnapshot = await _firestore
          .collection('VEHICLE_INFORMATION')
          .where('type', isEqualTo: queryType)
          .where('brand', isEqualTo: vehicleData['vehicleBrand'])
          .where('model', isEqualTo: vehicleData['vehicleModel'])
          .where('color', isEqualTo: queryColor)
          .get();

      if (kDebugMode) {
        print("\n=== Found matching vehicles ===");
        print("Number of matches: ${vehicleSnapshot.docs.length}");
        if (vehicleSnapshot.docs.isNotEmpty) {
          print("Selected vehicleId: ${vehicleSnapshot.docs.first.id}");
        }
        print("=====================================\n");
      }

      String vehicleId;
      if (vehicleSnapshot.docs.isEmpty) {
        throw Exception("Không tìm thấy thông tin xe phù hợp trong hệ thống");
      }
      
      vehicleId = vehicleSnapshot.docs.first.id;

      int seatingCapacity = await getSeatingCapacity(vehicleId);

      print("Seating capacity: $seatingCapacity");

      if (_currentUserId == null) {
        await _updateCurrentUserId(uid);
        if (_currentUserId == null) {
          throw Exception("Không tìm thấy UserId cho UID đã cho");
        }
      }

      final vehicleRegisterId = await _generateVehicleId();

      // Upload ảnh đăng ký xe
      String frontPhotoUrl = '';
      String backPhotoUrl = '';
      
      try {
        if (vehicleData['vehicleRegistrationFrontPhoto'] != null && 
            vehicleData['vehicleRegistrationFrontPhoto'] is File) {
          frontPhotoUrl = await uploadVehiclePhoto(
            vehicleData['vehicleRegistrationFrontPhoto'] as File,
            vehicleRegisterId,
            'registration_front'
          );
        }

        if (vehicleData['vehicleRegistrationBackPhoto'] != null && 
            vehicleData['vehicleRegistrationBackPhoto'] is File) {
          backPhotoUrl = await uploadVehiclePhoto(
            vehicleData['vehicleRegistrationBackPhoto'] as File,
            vehicleRegisterId,
            'registration_back'
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print("Lỗi khi upload ảnh: $e");
        }
        rethrow;
      }

      // Đảm bảo status luôn là tiếng Việt khi lưu
      String firestoreStatus = locale == 'vi' 
          ? vehicleData['status'] 
          : _convertStatusToFirestore(vehicleData['status'], locale);
      
      final newRentalVehicle = RentalVehicleModel(
        vehicleRegisterId: vehicleRegisterId,
        userId: _currentUserId!,
        licensePlate: vehicleData['licensePlate'] ?? '',
        vehicleRegistration: vehicleData['vehicleRegistration'] ?? '',
        vehicleType: queryType,
        maxSeats: seatingCapacity,
        vehicleBrand: vehicleData['vehicleBrand'],
        vehicleModel: vehicleData['vehicleModel'],
        vehicleColor: queryColor,  // Lưu màu tiếng Việt
        vehicleRegistrationFrontPhoto: frontPhotoUrl,
        vehicleRegistrationBackPhoto: backPhotoUrl,
        hour4Price: (vehicleData['hour4Price'] ?? 0).toDouble(),
        hour8Price: (vehicleData['hour8Price'] ?? 0).toDouble(),
        dayPrice: (vehicleData['dayPrice'] ?? 0).toDouble(),
        requirements: List<String>.from(vehicleData['requirements'] ?? []),
        contractId: vehicleData['contractId'] ?? '',
        status: firestoreStatus,
        vehicleId: vehicleId,
      );

      await _firestore
          .collection('RENTAL_VEHICLE')
          .doc(newRentalVehicle.vehicleRegisterId)
          .set(newRentalVehicle.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi trong quá trình tạo rental vehicle: $e");
      }
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
      }
      
      return 'assets/img/car_default.png';
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vehicle photo: $e");
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

  Stream<List<RentalVehicleModel>> getAvailableVehicles(
    String category,
    String rentOption,
    double minBudget,
    double maxBudget,
    DateTime startDate,
    DateTime endDate,
    String pickupProvince,
  ) {
    // Convert category sang tiếng Việt để query
    String queryType = _convertVehicleTypeToFirestore(category, 'vi');
    
    if (kDebugMode) {
      print('Querying vehicles for category: $queryType');
    }
    
    // Lấy danh sách các xe có trạng thái khả dụng và đúng loại xe
    return _firestore
        .collection('RENTAL_VEHICLE')
        .where('status', isEqualTo: 'Khả dụng')
        .where('vehicleType', isEqualTo: queryType)
        .snapshots()
        .asyncMap((vehicleSnapshot) async {
          List<RentalVehicleModel> availableVehicles = [];
          
          for (var doc in vehicleSnapshot.docs) {
            RentalVehicleModel vehicle = RentalVehicleModel.fromMap(doc.data());
            
            // Kiểm tra giá thuê có nằm trong khoảng budget không
           double relevantPrice = _getPriceForOption(rentOption, vehicle);
            if (relevantPrice < minBudget || relevantPrice > maxBudget) {
              continue;
            }

            // Kiểm tra địa điểm
            bool isLocationMatch = await _checkLocationMatch(vehicle.contractId, pickupProvince);
            if (!isLocationMatch) {
              continue;
            }

            // Kiểm tra thời gian có sẵn
            bool isTimeAvailable = await _checkTimeAvailability(
              vehicle.vehicleRegisterId,
              startDate,
              endDate,
              rentOption
            );
            if (!isTimeAvailable) {
              continue;
            }

            availableVehicles.add(vehicle);
          }

          return availableVehicles;
        });
  }

  Future<bool> _checkLocationMatch(String contractId, String fullAddress) async {
    try {
      final contractDoc = await _firestore
          .collection('CONTRACT')
          .doc(contractId)
          .get();

      if (!contractDoc.exists) return false;

      final contractData = contractDoc.data() as Map<String, dynamic>;
      String businessProvince = contractData['businessProvince'] as String;
      
      // Chuyển cả 2 chuỗi về lowercase để so sánh không phân biệt hoa thường
      return fullAddress.toLowerCase().contains(businessProvince.toLowerCase());
      
    } catch (e) {
      if (kDebugMode) {
        print("Error checking location match: $e");
      }
      return false;
    }
  }

  Future<bool> _checkTimeAvailability(
    String vehicleRegisterId,
    DateTime startDate,
    DateTime endDate,
    String rentOption,
  ) async {
    try {
      // Kiểm tra thời gian hợp lệ
      if (rentOption == 'Hourly') {
        // Kiểm tra giờ có nằm trong khoảng 6h-18h không
        if (startDate.hour < 6 || endDate.hour > 18) {
          return false;
        }
      }

      // Lấy tất cả các bill liên quan đến xe trong khoảng thời gian
      final billSnapshot = await _firestore
          .collection('BILL')
          .where('vehicleRegisterId', isEqualTo: vehicleRegisterId)
          .get();

      // Kiểm tra xem có trùng lịch với bill nào không
      for (var doc in billSnapshot.docs) {
        final billData = doc.data();
        final billStartDate = DateTime.parse(billData['startDate']);
        final billEndDate = DateTime.parse(billData['endDate']);

        // Nếu có bất kỳ sự chồng chéo nào về thời gian
        if (!(endDate.isBefore(billStartDate) || startDate.isAfter(billEndDate))) {
          return false;
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking time availability: $e");
      }
      return false;
    }
  }

  Future<Map<String, dynamic>> getVehicleDetails(String vehicleId, String locale) async {
    try {
      final doc = await _firestore.collection('VEHICLE_INFORMATION').doc(vehicleId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'requirements': data['requirements'] ?? [],
          'fuelType': getDisplayFuelType(data['fuelType'] ?? '', locale),
          'transmission': getDisplayTransmission(data['transmission'] ?? '', locale),
          'maxSpeed': data['maxSpeed'] ?? '',
        };
      }
      return {
        'requirements': [],
        'fuelType': '',
        'transmission': '',
        'maxSpeed': '',
      };
    } catch (e) {
      print('Error getting vehicle details: $e');
      return {
        'requirements': [],
        'fuelType': '',
        'transmission': '',
        'maxSpeed': '',
      };
    }
  }

  String getDisplayColor(String colorVi, String locale) {
    return locale == 'en' ? _translateColor(colorVi, 'en') : colorVi;
  }

  // Thêm phương thức để hiển thị vehicleType theo ngôn ngữ
  String getDisplayVehicleType(String vehicleTypeVi, String locale) {
    if (locale == 'en') {
      switch (vehicleTypeVi) {
        case 'Ô tô':
          return 'Car';
        case 'Xe máy':
          return 'Motorbike';
        default:
          return vehicleTypeVi;
      }
    }
    return vehicleTypeVi;
  }

  // Thêm các hằng số cho status
  final Map<String, String> _statusTranslations = {
    'Chờ duyệt': 'Pending Approval',
    'Đã duyệt': 'Approved',
    'Đang cho thuê': 'In Use',
    'Sẵn sàng': 'Available',
    'Đã từ chối': 'Rejected',
    'Tạm ngưng': 'Suspended',
  };

  String _convertStatusToFirestore(String displayStatus, String locale) {
    if (locale == 'vi') return displayStatus;
    
    // Chuyển từ tiếng Anh sang tiếng Việt để lưu
    return _statusTranslations.entries
        .firstWhere(
          (entry) => entry.value == displayStatus,
          orElse: () => MapEntry(displayStatus, displayStatus)
        )
        .key;
  }

  String getDisplayStatus(String firestoreStatus, String locale) {
    return firestoreStatus;
  }

  // Thêm translations cho fuel type
  final Map<String, String> _fuelTypeTranslations = {
    'Xăng': 'Gasoline',
    'Dầu': 'Diesel',
    'Điện': 'Electric',
    'Hybrid': 'Hybrid',
  };

  // Thêm translations cho transmission
  final Map<String, String> _transmissionTranslations = {
    'Tự động': 'Automatic',
    'Số sàn': 'Manual',
    'Số tự động': 'Automatic',
    'Không': 'None'
  };

  // Thêm phương thức dịch fuel type
  String getDisplayFuelType(String fuelTypeVi, String locale) {
    if (locale == 'en') {
      return _fuelTypeTranslations[fuelTypeVi] ?? fuelTypeVi;
    }
    return fuelTypeVi;
  }

  // Thêm phương thức dịch transmission
  String getDisplayTransmission(String transmissionVi, String locale) {
    if (locale == 'en') {
      return _transmissionTranslations[transmissionVi] ?? transmissionVi;
    }
    return transmissionVi;
  }

  // Thêm phương thức mới để xác định giá theo gói thuê
  double _getPriceForOption(String rentOption, RentalVehicleModel vehicle) {
    switch (rentOption) {
      case '4 Hours':
        return vehicle.hour4Price;
      case '8 Hours':
        return vehicle.hour8Price;
      case 'Daily':
        return vehicle.dayPrice;
      default:
        return vehicle.hour4Price;
    }
  }

  Future<void> updateVehicleDetails(String vehicleRegisterId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('RENTAL_VEHICLE')
          .doc(vehicleRegisterId)
          .update(updates);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating vehicle details: $e");
      }
      rethrow;
    }
  }
}


