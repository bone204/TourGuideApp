import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourguideapp/models/province_model.dart';
import 'package:tourguideapp/widgets/province_card.dart';

class ProvinceViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Province> _provinces = [];
  List<Province> _filteredProvinces = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  List<Province> get provinces => _searchQuery.isEmpty 
      ? _provinces 
      : _filteredProvinces;

  bool get isLoading => _isLoading;
  String get error => _error;
  
  List<ProvinceCard> get provinceCards => provinces
      .map((p) => ProvinceCard(
            name: p.provinceName,
            imageUrl: p.imageUrl,
            rating: 5.0,
            isFavorite: false,
          ))
      .toList();

  Future<void> fetchProvinces() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('PROVINCE').get();
      _provinces = snapshot.docs.map((doc) => Province.fromMap(doc.data())).toList();
      _applySearch(); // Áp dụng tìm kiếm nếu có
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tải danh sách tỉnh thành: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProvinces(String query) {
    _searchQuery = _normalizeString(query);
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredProvinces = [];
      return;
    }

    _filteredProvinces = _provinces.where((province) {
      final normalizedName = _normalizeString(province.provinceName);
      return normalizedName.contains(_searchQuery);
    }).toList();
  }

  void filterProvinces(bool Function(Province) filter) {
    _filteredProvinces = _provinces.where(filter).toList();
    notifyListeners();
  }

  String _normalizeString(String text) {
    var output = text.toLowerCase();
    var vietnameseMap = {
      'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ': 'a',
      'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ': 'e',
      'ì|í|ị|ỉ|ĩ': 'i',
      'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ': 'o',
      'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ': 'u',
      'ỳ|ý|ỵ|ỷ|ỹ': 'y',
      'đ': 'd',
    };

    vietnameseMap.forEach((key, value) {
      output = output.replaceAll(RegExp(key), value);
    });
    return output;
  }
}
