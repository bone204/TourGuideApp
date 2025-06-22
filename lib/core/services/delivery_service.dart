import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/cooperation_model.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách delivery brands từ Cooperation model
  Future<List<CooperationModel>> getDeliveryBrands() async {
    try {
      final snapshot = await _firestore
          .collection('COOPERATION')
          .where('type', isEqualTo: 'delivery')
          .get();

      return snapshot.docs
          .map((doc) => CooperationModel.fromMap({
                ...doc.data(),
                'cooperationId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching delivery brands: $e');
      return [];
    }
  }

  // Lấy delivery brand theo ID
  Future<CooperationModel?> getDeliveryBrandById(String brandId) async {
    try {
      final doc = await _firestore.collection('COOPERATION').doc(brandId).get();

      if (doc.exists) {
        return CooperationModel.fromMap({
          ...doc.data()!,
          'cooperationId': doc.id,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching delivery brand: $e');
      return null;
    }
  }

  // Lọc delivery brands theo rating
  List<CooperationModel> filterDeliveryBrandsByRating(
      List<CooperationModel> brands, double minRating) {
    return brands.where((brand) => brand.averageRating >= minRating).toList();
  }

  // Lọc delivery brands theo province
  List<CooperationModel> filterDeliveryBrandsByProvince(
      List<CooperationModel> brands, String province) {
    return brands.where((brand) => brand.province == province).toList();
  }
}
