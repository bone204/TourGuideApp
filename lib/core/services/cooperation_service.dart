import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/widgets/home_card.dart';

class CooperationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả dữ liệu từ COOPERATION
  Future<List<CooperationModel>> getAllCooperations() async {
    try {
      final snapshot = await _firestore.collection('COOPERATION').get();
      return snapshot.docs
          .map((doc) => CooperationModel.fromMap({
                ...doc.data(),
                'cooperationId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching cooperations: $e');
      return [];
    }
  }

  // Lấy khách sạn theo tỉnh
  Future<List<CooperationModel>> getHotelsByProvince(String province) async {
    try {
      final snapshot = await _firestore
          .collection('COOPERATION')
          .where('type', isEqualTo: 'hotel')
          .where('province', isEqualTo: province)
          .get();

      return snapshot.docs
          .map((doc) => CooperationModel.fromMap({
                ...doc.data(),
                'cooperationId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching hotels: $e');
      return [];
    }
  }

  // Lấy nhà hàng theo tỉnh
  Future<List<CooperationModel>> getRestaurantsByProvince(
      String province) async {
    try {
      final snapshot = await _firestore
          .collection('COOPERATION')
          .where('type', isEqualTo: 'restaurant')
          .where('province', isEqualTo: province)
          .get();

      return snapshot.docs
          .map((doc) => CooperationModel.fromMap({
                ...doc.data(),
                'cooperationId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  // Lấy eatery theo tỉnh
  Future<List<CooperationModel>> getEateriesByProvince(String province) async {
    try {
      final snapshot = await _firestore
          .collection('COOPERATION')
          .where('type', isEqualTo: 'eatery')
          .where('province', isEqualTo: province)
          .get();

      return snapshot.docs
          .map((doc) => CooperationModel.fromMap({
                ...doc.data(),
                'cooperationId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching eateries: $e');
      return [];
    }
  }

  // Lấy tất cả địa điểm có rating cao (sắp xếp theo averageRating giảm dần)
  Future<List<CooperationModel>> getHighRatedPlaces({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('COOPERATION')
          .where('averageRating', isGreaterThan: 0)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CooperationModel.fromMap({
                ...doc.data(),
                'cooperationId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching high rated places: $e');
      return [];
    }
  }

  // Chuyển đổi CooperationModel thành HomeCardData
  HomeCardData convertToHomeCardData(CooperationModel cooperation) {
    return HomeCardData(
      imageUrl: cooperation.photo.isNotEmpty ? cooperation.photo : '',
      placeName: cooperation.name,
      description: cooperation.province,
      rating: cooperation.averageRating,
      favouriteTimes: cooperation.bookingTimes,
      userRatingsTotal: 0, // COOPERATION không có userRatingsTotal
      priceLevel: cooperation.priceLevel,
    );
  }

  // Lấy danh sách HomeCardData cho khách sạn ở Bình Dương
  Future<List<HomeCardData>> getBinhDuongHotels() async {
    final hotels = await getHotelsByProvince('Bình Dương');
    return hotels.map((hotel) => HomeCardData(
      imageUrl: hotel.photo.isNotEmpty ? hotel.photo : '',
      placeName: hotel.name,
      description: hotel.province,
      rating: hotel.averageRating,
      favouriteTimes: hotel.bookingTimes,
      userRatingsTotal: 0,
      priceLevel: hotel.priceLevel,
    )).toList();
  }

  // Lấy danh sách HomeCardData cho nhà hàng ở Bình Dương
  Future<List<HomeCardData>> getBinhDuongRestaurants() async {
    final restaurants = await getRestaurantsByProvince('Bình Dương');
    return restaurants.map((restaurant) => HomeCardData(
      imageUrl: restaurant.photo.isNotEmpty ? restaurant.photo : '',
      placeName: restaurant.name,
      description: restaurant.province,
      rating: restaurant.averageRating,
      favouriteTimes: restaurant.bookingTimes,
      userRatingsTotal: 0,
      priceLevel: restaurant.priceLevel,
    )).toList();
  }

  // Lấy danh sách HomeCardData cho địa điểm có rating cao
  Future<List<HomeCardData>> getHighRatedPlacesData({int limit = 10}) async {
    final places = await getHighRatedPlaces(limit: limit);
    return places.map((place) => HomeCardData(
      imageUrl: place.photo.isNotEmpty ? place.photo : '',
      placeName: place.name,
      description: place.province,
      rating: place.averageRating,
      favouriteTimes: place.bookingTimes,
      userRatingsTotal: 0,
      priceLevel: place.priceLevel,
    )).toList();
  }
}
