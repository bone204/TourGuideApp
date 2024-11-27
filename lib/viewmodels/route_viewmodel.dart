import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/destination_model.dart';

class RouteViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _routes = [
    {
      'name': 'by: Traveline',
      'rating': 4.5,
    },
    {
      'name': 'by: Thông Joker',
      'rating': 4.7,
    },
    {
      'name': 'by: Thông Tulen',
      'rating': 4.3,
    },
    {
      'name': 'by: Thiện Tank',
      'rating': 4.8,
    },
  ];
  
  List<DestinationModel> _destinations = [];
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> get routes => _routes;
  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch destinations theo province
  Future<void> fetchDestinationsByProvince(String provinceName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Đang tìm kiếm địa điểm cho tỉnh: $provinceName'); // Debug log

      final QuerySnapshot snapshot = await _firestore
          .collection('DESTINATION')
          .where('province', isEqualTo: provinceName.trim())
          .get();

      print('Số lượng kết quả: ${snapshot.docs.length}'); // Debug log

      _destinations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Dữ liệu địa điểm: $data'); // Debug log
        return DestinationModel.fromMap(data);
      }).toList();

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
}