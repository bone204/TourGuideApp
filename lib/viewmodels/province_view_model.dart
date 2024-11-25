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

  // Getters
  List<Province> get provinces => _searchQuery.isEmpty 
      ? _provinces 
      : _filteredProvinces;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch provinces từ Firebase
  Future<void> fetchProvinces() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore.collection('PROVINCE').get();
      
      _provinces = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Province.fromMap(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Có lỗi xảy ra khi tải dữ liệu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite status
  void toggleFavorite(String provinceId) {
    final index = _provinces.indexWhere((p) => p.provinceId == provinceId);
    if (index != -1) {
      _provinces[index].isFavorite = !_provinces[index].isFavorite;
      notifyListeners();
      
      // Có thể thêm logic để update favorite status lên Firebase
      // _updateFavoriteStatus(provinceId, _provinces[index].isFavorite);
    }
  }

  // Convert Province to ProvinceCard
  ProvinceCard provinceToCard(Province province) {
    return ProvinceCard(
      name: province.provinceName,
      imageUrl: province.imageUrl,
      rating: province.rating,
      isFavorite: province.isFavorite,
      onTap: () {
        // Xử lý khi tap vào card
        print('Tapped on province: ${province.provinceName}');
      },
      onFavoritePressed: () {
        toggleFavorite(province.provinceId);
      },
    );
  }

  // Get list of ProvinceCards
  List<ProvinceCard> get provinceCards => 
      provinces.map((province) => provinceToCard(province)).toList();

  // Thêm hàm chuyển đổi text không dấu
  String _removeDiacritics(String text) {
    var vietnameseMap = {
      'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ': 'a',
      'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ': 'e',
      'ì|í|ị|ỉ|ĩ': 'i',
      'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ': 'o',
      'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ': 'u',
      'ỳ|ý|ỵ|ỷ|ỹ': 'y',
      'đ': 'd',
      'À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ': 'A',
      'È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ': 'E',
      'Ì|Í|Ị|Ỉ|Ĩ': 'I',
      'Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ': 'O',
      'Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ': 'U',
      'Ỳ|Ý|Ỵ|Ỷ|Ỹ': 'Y',
      'Đ': 'D'
    };

    String result = text;
    vietnameseMap.forEach((key, value) {
      result = result.replaceAll(RegExp(key), value);
    });
    return result;
  }

  // Sửa lại hàm search
  void searchProvinces(String query) {
    _searchQuery = query.toLowerCase().trim();
    if (_searchQuery.isEmpty) {
      _filteredProvinces = _provinces;
    } else {
      _filteredProvinces = _provinces.where((province) {
        String normalizedProvinceName = _removeDiacritics(province.provinceName.toLowerCase());
        String normalizedQuery = _removeDiacritics(_searchQuery.toLowerCase());
        
        // Tách tên tỉnh và query thành các từ riêng biệt
        List<String> provinceWords = normalizedProvinceName.split(' ');
        List<String> queryWords = normalizedQuery.split(' ');
        
        // Kiểm tra từng từ trong query
        return queryWords.every((queryWord) {
          // Kiểm tra xem có từ nào trong tên tỉnh bắt đầu bằng từ trong query không
          return provinceWords.any((provinceWord) => 
            provinceWord.startsWith(queryWord)
          );
        });
      }).toList();
    }
    notifyListeners();
  }
} 