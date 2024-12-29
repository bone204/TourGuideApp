import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RouteViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DestinationModel> _destinations = [];
  bool _isLoading = false;
  String _error = '';

  // Thêm biến để lưu trạng thái route đã chọn
  String? _selectedRouteTitle;
  List<DestinationModel>? _selectedDestinations;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, dynamic>> _routes = [
    {
      'name': 'by: Traveline',
      'rating': 4.5,
      'destinations': [0, 1, 2, 3], // Thứ tự các địa điểm cho route này
    },
    {
      'name': 'by: Thông Joker',
      'rating': 4.7,
      'destinations': [2, 0, 3, 1], // Thứ tự khác
    },
    {
      'name': 'by: Thông Tulen',
      'rating': 4.3,
      'destinations': [1, 3, 0, 2], // Thứ tự khác nữa
    },
    {
      'name': 'by: Thiện Tank',
      'rating': 4.8,
      'destinations': [3, 2, 1, 0], // Thứ tự khác nữa
    },
  ];

  List<Map<String, dynamic>> get routes => _routes;
  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Getters
  bool get hasSelectedRoute => _selectedRouteTitle != null;
  String? get selectedRouteTitle => _selectedRouteTitle;
  List<DestinationModel>? get selectedDestinations => _selectedDestinations;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  RouteViewModel() {
    _loadSavedRoute();
  }

  Future<void> _loadSavedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedRouteTitle = prefs.getString('selectedRouteTitle');
    _selectedDestinations = _loadDestinations(prefs.getString('selectedDestinations'));
    final startDateStr = prefs.getString('startDate');
    final endDateStr = prefs.getString('endDate');
    
    if (startDateStr != null) _startDate = DateTime.parse(startDateStr);
    if (endDateStr != null) _endDate = DateTime.parse(endDateStr);
    notifyListeners();
  }

  List<DestinationModel>? _loadDestinations(String? json) {
    if (json == null) return null;
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => DestinationModel.fromMap(e)).toList();
  }

  Future<void> saveSelectedRoute({
    required String routeTitle,
    required List<DestinationModel> destinations,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRouteTitle', routeTitle);
    await prefs.setString('selectedDestinations', jsonEncode(destinations.map((e) => e.toMap()).toList()));
    await prefs.setString('startDate', startDate.toIso8601String());
    await prefs.setString('endDate', endDate.toIso8601String());

    _selectedRouteTitle = routeTitle;
    _selectedDestinations = destinations;
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }

  Future<void> clearSelectedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedRouteTitle');
    await prefs.remove('selectedDestinations');
    await prefs.remove('startDate');
    await prefs.remove('endDate');

    _selectedRouteTitle = null;
    _selectedDestinations = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // Fetch destinations theo province
  Future<void> fetchDestinationsByProvince(String provinceName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Đang tìm kiếm địa điểm cho tỉnh: $provinceName');

      final QuerySnapshot snapshot = await _firestore
          .collection('DESTINATION')
          .where('province', isEqualTo: provinceName.trim())
          .get();

      print('Số lượng kết quả: ${snapshot.docs.length}');

      _destinations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Dữ liệu địa điểm: $data');
        return DestinationModel.fromMap(data);
      }).toList();

      // Xáo trộn thứ tự destinations cho mỗi route
      for (var route in _routes) {
        (route['destinations'] as List<int>).shuffle();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Có lỗi xảy ra khi tải dữ liệu: $e';
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

  // Lấy destinations theo thứ tự của route
  List<DestinationModel> getDestinationsForRoute(int routeIndex) {
    if (routeIndex >= _routes.length) return [];
    
    final List<int> order = List<int>.from(_routes[routeIndex]['destinations']);
    return order.map((index) {
      if (index < _destinations.length) {
        return _destinations[index];
      }
      // Trả về destination đầu tiên nếu index vượt quá
      return _destinations.first;
    }).toList();
  }
}