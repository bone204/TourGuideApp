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

  // Getters
  List<Province> get provinces => _filteredProvinces;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Thêm phương thức normalize text
  String _normalizeString(String text) {
    var output = text.toLowerCase();
    var vietnameseMap = {
      'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ|Â|À|Á|Ạ|Ả|Ã|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ằ|Ắ|Ặ|Ẳ|Ẵ': 'a',
      'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ|È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ': 'e',
      'ì|í|ị|ỉ|ĩ|Ì|Í|Ị|Ỉ|Ĩ': 'i',
      'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ|Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ': 'o',
      'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ|Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ': 'u',
      'ỳ|ý|ỵ|ỷ|ỹ|Ỳ|Ý|Ỵ|Ỷ|Ỹ': 'y',
      'đ|Đ': 'd'
    };

    vietnameseMap.forEach((key, value) {
      output = output.replaceAll(RegExp(key), value);
    });
    return output;
  }

  // Sửa lại phương thức search
  void searchProvinces(String query) {
    if (query.isEmpty) {
      _filteredProvinces = List.from(_provinces);
    } else {
      final normalizedQuery = _normalizeString(query);
      final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty).toList();

      _filteredProvinces = _provinces.where((province) {
        final normalizedName = _normalizeString(province.provinceName);
        
        return queryWords.every((word) {
          return normalizedName.split(' ').any((nameWord) => nameWord.startsWith(word));
        });
      }).toList();
    }
    notifyListeners();
  }

  // Sửa lại phương thức fetch để khởi tạo _filteredProvinces
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

      _filteredProvinces = List.from(_provinces);
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

  void filterProvinces(bool Function(Province) filter) {
    _filteredProvinces = _provinces.where(filter).toList();
    notifyListeners();
  }

  void resetSearch() {
    _filteredProvinces = List.from(_provinces);
    notifyListeners();
  }
} 