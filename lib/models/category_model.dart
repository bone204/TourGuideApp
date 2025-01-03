//import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String categoryId;
  final String categoryName;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }

  String getTranslatedName(String locale) {
    // Map các giá trị tiếng Việt sang tiếng Anh
    final Map<String, String> translationMap = {
      'Phiêu lưu': 'Adventure',
      'Giải trí': 'Entertainment',
      'Lịch sử': 'History',
      'Văn hóa': 'Culture',
      'Lễ hội': 'Festival',
      'Thiên nhiên': 'Nature',
      'Biển đảo': 'Beach & Islands',
      'Thể thao': 'Sports',
      'Nhiếp ảnh': 'Photography',
    };

    return locale == 'vi' ? categoryName : (translationMap[categoryName] ?? categoryName);
  }
}
