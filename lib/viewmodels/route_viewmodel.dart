import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/models/travel_route_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/blocs/travel_route/travel_route_bloc.dart';

class RouteViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DestinationModel> _destinations = [];
  bool _isLoading = false;
  String _error = '';

  // State variables
  String? _selectedRouteTitle;
  List<DestinationModel>? _selectedDestinations;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProvinceName;

  // Thay thế _routes bằng _userRoutes để lưu routes của user hiện tại
  List<Map<String, dynamic>> _userRoutes = [];

  // Thêm biến để lưu trữ tất cả các routes
  List<Map<String, dynamic>> _savedRoutes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentRouteNumber = 0;

  // Thêm biến để lưu suggested routes
  List<Map<String, dynamic>> _suggestedRoutes = [];

  final TravelRouteBloc _travelRouteBloc;
  
  RouteViewModel({required TravelRouteBloc travelRouteBloc})
    : _travelRouteBloc = travelRouteBloc;

  // Getters
  List<Map<String, dynamic>> get routes => _userRoutes;
  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasSelectedRoute => _selectedRouteTitle != null;
  String? get selectedRouteTitle => _selectedRouteTitle;
  List<DestinationModel>? get selectedDestinations => _selectedDestinations;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedProvinceName => _selectedProvinceName;
  List<Map<String, dynamic>> get savedRoutes => _savedRoutes;
  List<Map<String, dynamic>> get suggestedRoutes => _suggestedRoutes;

  void loadRoutes({String? provinceName}) {
    _travelRouteBloc.add(LoadTravelRoutes(provinceName: provinceName));
  }

  void saveCustomRoute({
    required String routeTitle,
    required List<DestinationModel> destinations,
    required DateTime startDate,
    required DateTime endDate,
    required String provinceName,
    required List<Map<String, dynamic>> routes,
  }) {
    _travelRouteBloc.add(SaveCustomRoute(
      routeTitle: routeTitle,
      destinations: destinations,
      startDate: startDate,
      endDate: endDate,
      provinceName: provinceName,
      routes: routes,
    ));
  }

  void deleteRoute(String routeTitle) {
    _travelRouteBloc.add(DeleteTravelRoute(routeTitle: routeTitle));
  }

  Future<void> deleteRouteFromFirebase(String routeTitle) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      final currentUserId = userDoc.data()?['userId'] as String?;
      if (currentUserId == null) throw Exception('User information not found');

      final querySnapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .where('routeTitle', isEqualTo: routeTitle)
          .where('userId', isEqualTo: currentUserId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Route not found or you do not have permission to delete it');
      }

      // Xóa từ Firebase
      await querySnapshot.docs.first.reference.delete();

      // Xóa khỏi state local
      _userRoutes.removeWhere((r) => r['routeTitle'] == routeTitle);
      _savedRoutes.removeWhere((r) => r['title'] == routeTitle);

      // Reload routes và thông báo thay đổi
      await loadSavedRoutes();
      notifyListeners();
    } catch (e) {
      print('Error deleting route: $e');
      rethrow;
    }
  }

  void addDestinationToRoute({
    required String routeTitle,
    required DestinationModel destination,
  }) {
    _travelRouteBloc.add(AddDestinationToRoute(
      routeTitle: routeTitle,
      destination: destination,
    ));
  }

  Future<void> saveSelectedRoute({
    required String routeTitle,
    required List<DestinationModel> destinations,
    required DateTime startDate,
    required DateTime endDate,
    required String provinceName,
  }) async {
    // Tạo route mới
    final newRoute = {
      'title': routeTitle,
      'destinations': destinations,
      'startDate': startDate,
      'endDate': endDate,
      'provinceName': provinceName,
      'isCustom': routeTitle.startsWith("Your Custom Route"),
    };

    // Kiểm tra xem route đã tồn tại chưa
    final existingIndex = _savedRoutes.indexWhere((r) => r['title'] == routeTitle);
    if (existingIndex != -1) {
      // Nếu đã tồn tại thì cập nhật
      _savedRoutes[existingIndex] = newRoute;
    } else {
      // Nếu chưa tồn tại thì thêm mới
      _savedRoutes.add(newRoute);
    }

    // Cập nhật state hiện tại
    _selectedRouteTitle = routeTitle;
    _selectedDestinations = destinations;
    _startDate = startDate;
    _endDate = endDate;
    _selectedProvinceName = provinceName;

    notifyListeners();
  }

  Future<void> clearSelectedRoute() async {
    _selectedRouteTitle = null;
    _selectedDestinations = null;
    _startDate = null;
    _endDate = null;
    _selectedProvinceName = null;
    _savedRoutes.clear();
    notifyListeners();
  }

  // Fetch destinations theo province
  Future<void> fetchDestinationsByProvince(String provinceName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('DESTINATION')
          .where('province', isEqualTo: provinceName.trim())
          .get();

      _destinations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DestinationModel.fromMap(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error loading data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  String getImagePath(int index) {
    return 'assets/img/bg_route_${index + 1}.png';
  }

  String getDisplayTitle(String routeName) {
    return routeName.startsWith('by: ') 
        ? "${routeName.substring(4)}'s Route"
        : "$routeName Route";
  }

  List<DestinationModel> getDestinationsForRoute(int routeIndex) {
    if (routeIndex >= _userRoutes.length) return [];
    
    final route = _userRoutes[routeIndex];
    if (route['destinations'] == null) return [];
    
    return (route['destinations'] as List<dynamic>).map((dest) {
      return DestinationModel(
        destinationId: dest['destinationId'],
        destinationName: dest['destinationName'] ?? '',
        latitude: 0.0,
        longitude: 0.0,
        province: route['province'] ?? '',
        district: '',
        specificAddress: '',
        descriptionEng: '',
        descriptionViet: '',
        photo: [],
        video: [],
        createdDate: DateTime.now().toString(),
        categories: [],
      );
    }).toList();
  }

  Future<String> createNewCustomRoute({
    required String provinceName,
    required String routeTitle,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      final userId = userDoc.data()?['userId'] as String?;
      if (userId == null) throw Exception('User information not found');

      if (_currentRouteNumber == 0) {
        await _initializeRouteNumber();
      }

      final travelRouteId = _generateTravelRouteId();
      
      // Đảm bảo isCustom luôn được set là true khi tạo route mới
      final travelRoute = TravelRouteModel(
        travelRouteId: travelRouteId,
        userId: userId,
        routeTitle: routeTitle,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        createdDate: DateTime.now(),
        province: provinceName,
        avatar: 'assets/img/bg_route_1.png',
        number: _currentRouteNumber,
        routes: [],
        isCustom: true, // Đảm bảo set true
      );

      // Lưu lên Firebase
      await _firestore
          .collection('TRAVEL_ROUTE')
          .doc(travelRouteId)
          .set(travelRoute.toMap());

      _currentRouteNumber++;

      // Thêm vào state local
      _userRoutes.add({
        'routeTitle': routeTitle,
        'rating': 0.0,
        'travelRouteId': travelRouteId,
        'province': provinceName,
        'createdDate': DateTime.now(),
        'isCustom': true, // Đảm bảo set true
      });

      notifyListeners();
      return routeTitle;
    } catch (e) {
      print('Error creating new custom route: $e');
      rethrow;
    }
  }

  Future<void> _initializeRouteNumber() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .get();

      if (snapshot.docs.isEmpty) {
        _currentRouteNumber = 1;
        return;
      }

      // Tìm số lớn nhất trong các mã hiện có
      int maxNumber = 0;
      for (var doc in snapshot.docs) {
        final travelRouteId = doc['travelRouteId'] as String;
        if (travelRouteId.startsWith('TR')) {
          final number = int.parse(travelRouteId.substring(2));
          if (number > maxNumber) {
            maxNumber = number;
          }
        }
      }

      // Số tiếp theo sẽ là số lớn nhất + 1
      _currentRouteNumber = maxNumber + 1;
      print('Next route number: $_currentRouteNumber');
    } catch (e) {
      print('Error initializing route number: $e');
      _currentRouteNumber = 1;
    }
  }

  String _generateTravelRouteId() {
    return 'TR${_currentRouteNumber.toString().padLeft(5, '0')}';
  }

  Future<void> loadSavedRoutes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      final userId = userDoc.data()?['userId'] as String?;
      if (userId == null) throw Exception('User information not found');

      // Lấy tất cả routes của user hiện tại
      final QuerySnapshot snapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .where('userId', isEqualTo: userId)
          .get();

      _userRoutes.clear();
      _savedRoutes.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Thêm vào _userRoutes để hiển thị route cards
        _userRoutes.add({
          'routeTitle': data['routeTitle'],
          'rating': data['averageRating'] ?? 0.0,
          'travelRouteId': data['travelRouteId'],
          'province': data['province'],
          'createdDate': data['createdDate'],
        });

        // Lấy thông tin chi tiết của từng destination
        final List<DestinationModel> destinations = [];
        for (var route in (data['routes'] as List? ?? [])) {
          final destDoc = await _firestore
              .collection('DESTINATION')
              .doc(route['destinationId'])
              .get();
          
          if (destDoc.exists) {
            destinations.add(DestinationModel.fromMap(destDoc.data()!));
          }
        }

        // Thêm vào _savedRoutes với đầy đủ thông tin
        _savedRoutes.add({
          'title': data['routeTitle'],
          'destinations': destinations,
          'startDate': (data['startDate'] as Timestamp).toDate(),
          'endDate': (data['endDate'] as Timestamp).toDate(),
          'provinceName': data['province'],
          'isCustom': data['isCustom'] ?? false,
        });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Sửa lại hàm _formatTimeRange để hiển thị 24h
  String _formatTimeRange(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  Future<void> loadSuggestedRoutes(String provinceName) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      final currentUserId = userDoc.data()?['userId'] as String?;
      if (currentUserId == null) throw Exception('User information not found');

      // Chỉ query theo province, sau đó filter trong code
      final QuerySnapshot snapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .where('province', isEqualTo: provinceName)
          .get();

      _suggestedRoutes.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Filter trong code
        if (data['isCustom'] == true || data['userId'] == currentUserId) {
          continue; // Skip custom routes và routes của user hiện tại
        }

        final List<DestinationModel> destinations = [];
        
        for (var route in (data['routes'] as List? ?? [])) {
          final destDoc = await _firestore
              .collection('DESTINATION')
              .doc(route['destinationId'])
              .get();
          
          if (destDoc.exists) {
            destinations.add(DestinationModel.fromMap(destDoc.data()!));
          }
        }

        _suggestedRoutes.add({
          'routeTitle': data['routeTitle'],
          'rating': data['averageRating'] ?? 0.0,
          'travelRouteId': data['travelRouteId'],
          'province': data['province'],
          'routes': data['routes'] ?? [],
          'destinations': destinations,
          'createdDate': data['createdDate'],
          'isCustom': false,
          'userId': data['userId'],
        });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading suggested routes: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<String> createNewRouteFromSuggested({
    required String routeTitle,
    required List<DestinationModel> destinations,
    required DateTime startDate,
    required DateTime endDate,
    required String provinceName,
    required List routes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      final userId = userDoc.data()?['userId'] as String?;
      if (userId == null) throw Exception('User information not found');

      if (_currentRouteNumber == 0) {
        await _initializeRouteNumber();
      }

      final travelRouteId = 'TR${_currentRouteNumber.toString().padLeft(5, '0')}';
      
      // Tạo TravelRouteModel với isCustom = true
      final travelRoute = TravelRouteModel(
        travelRouteId: travelRouteId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        createdDate: DateTime.now(),
        province: provinceName,
        avatar: 'assets/img/bg_route_1.png',
        number: _currentRouteNumber,
        routes: routes.map((r) => RouteItinerary(
          destinationId: r['destinationId'],
          timeline: r['timeline'],
          isCompleted: false,
          completedTime: null,
        )).toList(),
        routeTitle: routeTitle,
        isCustom: true, // Đánh dấu là custom route
      );

      // Lưu lên Firebase
      await _firestore
          .collection('TRAVEL_ROUTE')
          .doc(travelRouteId)
          .set(travelRoute.toMap());

      _currentRouteNumber++;

      // Cập nhật state local
      _savedRoutes.add({
        'title': routeTitle,
        'destinations': destinations,
        'startDate': startDate,
        'endDate': endDate,
        'provinceName': provinceName,
        'isCustom': true, // Đánh dấu là custom route
      });

      // Thêm vào _userRoutes
      _userRoutes.add({
        'routeTitle': routeTitle,
        'rating': 0.0,
        'travelRouteId': travelRouteId,
        'province': provinceName,
        'createdDate': DateTime.now(),
        'isCustom': true, // Đánh dấu là custom route
      });

      notifyListeners();
      return routeTitle;
    } catch (e) {
      print('Error creating route from suggested: $e');
      rethrow;
    }
  }

  Future<void> saveExistingRoute({
    required Map<String, dynamic> route,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      final userId = userDoc.data()?['userId'] as String?;
      if (userId == null) throw Exception('User information not found');

      if (_currentRouteNumber == 0) {
        await _initializeRouteNumber();
      }

      final travelRouteId = 'TR${_currentRouteNumber.toString().padLeft(5, '0')}';

      // Tạo TravelRouteModel mới từ route gợi ý với isCustom = true
      final travelRoute = TravelRouteModel(
        travelRouteId: travelRouteId,
        userId: userId,
        routeTitle: route['routeTitle'],
        startDate: startDate,
        endDate: endDate,
        createdDate: DateTime.now(),
        averageRating: route['rating'],
        province: route['province'],
        avatar: 'assets/img/bg_route_1.png',
        number: _currentRouteNumber,
        routes: (route['routes'] as List).map((r) => RouteItinerary(
          destinationId: r['destinationId'],
          timeline: r['timeline'],
          isCompleted: false,
          completedTime: null,
        )).toList(),
        isCustom: true, // Đánh dấu là custom route
      );

      // Lưu lên Firebase
      await _firestore
          .collection('TRAVEL_ROUTE')
          .doc(travelRouteId)
          .set(travelRoute.toMap());

      _currentRouteNumber++;

      // Thêm vào savedRoutes
      _savedRoutes.add({
        'title': route['routeTitle'],
        'destinations': route['destinations'],
        'startDate': startDate,
        'endDate': endDate,
        'provinceName': route['province'],
        'isCustom': true, // Đánh dấu là custom route
      });

      // Thêm vào userRoutes
      _userRoutes.add({
        'routeTitle': route['routeTitle'],
        'rating': route['rating'],
        'travelRouteId': travelRouteId,
        'province': route['province'],
        'createdDate': DateTime.now(),
        'isCustom': true, // Đánh dấu là custom route
      });

      notifyListeners();
    } catch (e) {
      print('Error saving existing route: $e');
      rethrow;
    }
  }

  Future<void> updateDestinationTimeline({
    required String routeTitle,
    required String destinationId,
    required String newTimeline,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Tìm route trong routes
      final route = routes.firstWhere((r) => r['name'] == routeTitle);
      final travelRouteId = route['travelRouteId'];

      // Lấy document từ Firebase
      final docRef = _firestore.collection('TRAVEL_ROUTE').doc(travelRouteId);
      final doc = await docRef.get();
      
      if (!doc.exists) throw Exception('Route not found');

      // Lấy và cập nhật mảng routes
      List<Map<String, dynamic>> routesList = 
          List<Map<String, dynamic>>.from(doc.data()?['routes'] ?? []);

      final index = routesList.indexWhere((r) => r['destinationId'] == destinationId);
      if (index != -1) {
        routesList[index]['timeline'] = newTimeline;
        
        // Cập nhật lên Firebase
        await docRef.update({
          'routes': routesList,
        });

        print('Updated timeline for destination $destinationId to $newTimeline');
        notifyListeners();
      }
    } catch (e) {
      print('Error updating timeline: $e');
      rethrow;
    }
  }

  Future<void> removeDestinationFromRoute({
    required String routeTitle,
    required String destinationId,
  }) async {
    try {
      final route = _userRoutes.firstWhere((r) => r['name'] == routeTitle);
      final travelRouteId = route['travelRouteId'];

      final docRef = _firestore.collection('TRAVEL_ROUTE').doc(travelRouteId);
      final doc = await docRef.get();
      
      if (!doc.exists) throw Exception('Route not found');

      // Xóa khỏi routes trong Firebase
      List<Map<String, dynamic>> routes = 
          List<Map<String, dynamic>>.from(doc.data()?['routes'] ?? []);
      routes.removeWhere((r) => r['destinationId'] == destinationId);

      // Cập nhật lại timeline cho các destination còn lại
      for (int i = 0; i < routes.length; i++) {
        final startHour = 8 + i;
        final endHour = startHour + 1;
        routes[i]['timeline'] = '${_formatTimeRange(startHour)} - ${_formatTimeRange(endHour)}';
      }

      await docRef.update({'routes': routes});

      // Xóa khỏi destinations trong local state
      final routeIndex = _savedRoutes.indexWhere((r) => r['title'] == routeTitle);
      if (routeIndex != -1) {
        final destinations = _savedRoutes[routeIndex]['destinations'] as List;
        destinations.removeWhere((d) => d.destinationId == destinationId);
      }

      notifyListeners();
    } catch (e) {
      print('Error removing destination: $e');
      rethrow;
    }
  }
}