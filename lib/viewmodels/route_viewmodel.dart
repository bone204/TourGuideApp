import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/destination_model.dart';

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

  final List<Map<String, dynamic>> _routes = [
    {
      'name': 'by: Traveline',
      'rating': 4.5,
      'destinations': [0, 1, 2, 3],
    },
    {
      'name': 'by: Thông Joker',
      'rating': 4.7,
      'destinations': [2, 0, 3, 1],
    },
    {
      'name': 'by: Thông Tulen',
      'rating': 4.3,
      'destinations': [1, 3, 0, 2],
    },
    {
      'name': 'by: Thiện Tank',
      'rating': 4.8,
      'destinations': [3, 2, 1, 0],
    },
  ];

  // Add these variables
  List<Map<String, dynamic>> _customRoutes = [];
  int _customRouteCount = 0;

  // Thêm biến để lưu trữ tất cả các routes
  List<Map<String, dynamic>> _savedRoutes = [];

  // Getters
  List<Map<String, dynamic>> get routes => _routes;
  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasSelectedRoute => _selectedRouteTitle != null;
  String? get selectedRouteTitle => _selectedRouteTitle;
  List<DestinationModel>? get selectedDestinations => _selectedDestinations;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedProvinceName => _selectedProvinceName;
  List<Map<String, dynamic>> get customRoutes => _customRoutes;
  List<Map<String, dynamic>> get savedRoutes => _savedRoutes;

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
    _customRouteCount = 0;
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

      for (var route in _routes) {
        (route['destinations'] as List<int>).shuffle();
      }

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
    if (routeIndex >= _routes.length) return [];
    
    final List<int> order = List<int>.from(_routes[routeIndex]['destinations']);
    final selectedDestinations = order.map((index) {
      if (index < _destinations.length) {
        return _destinations[index];
      }
      return _destinations.first;
    }).take(4).toList();

    return selectedDestinations;
  }

  // Add method to create new custom route
  String createNewCustomRoute() {
    _customRouteCount++;
    String routeTitle = _customRouteCount == 1 
        ? "Your Custom Route" 
        : "Your Custom Route ${_customRouteCount}";
    
    _customRoutes.add({
      'title': routeTitle,
      'destinations': <DestinationModel>[],
      'startDate': null,
      'endDate': null,
      'provinceName': null,
    });
    
    notifyListeners();
    return routeTitle;
  }

  // Thêm method mới để xóa một route cụ thể
  void deleteRoute(String routeTitle) {
    // Xóa route khỏi danh sách saved routes
    _savedRoutes.removeWhere((route) => route['title'] == routeTitle);
    
    // Reset custom route count nếu xóa custom route
    if (routeTitle.startsWith("Your Custom Route")) {
      // Tìm số lớn nhất trong các custom route còn lại
      int maxNumber = 0;
      for (var route in _savedRoutes) {
        String title = route['title'] as String;
        if (title.startsWith("Your Custom Route")) {
          // Lấy số từ title (nếu có)
          String numberStr = title.replaceAll("Your Custom Route", "").trim();
          if (numberStr.isEmpty) {
            maxNumber = max(maxNumber, 1);
          } else {
            maxNumber = max(maxNumber, int.parse(numberStr));
          }
        }
      }
      _customRouteCount = maxNumber;
    }
    
    // Cập nhật selected route
    if (_selectedRouteTitle == routeTitle) {
      if (_savedRoutes.isNotEmpty) {
        final firstRoute = _savedRoutes.first;
        _selectedRouteTitle = firstRoute['title'] as String;
        _selectedDestinations = firstRoute['destinations'] as List<DestinationModel>;
        _startDate = firstRoute['startDate'] as DateTime;
        _endDate = firstRoute['endDate'] as DateTime;
        _selectedProvinceName = firstRoute['provinceName'] as String;
      } else {
        _selectedRouteTitle = null;
        _selectedDestinations = null;
        _startDate = null;
        _endDate = null;
        _selectedProvinceName = null;
      }
    }
    
    notifyListeners();
  }
}