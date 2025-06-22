import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/models/table_model.dart';
import 'package:tourguideapp/models/restaurant_bill_model.dart';
import 'package:tourguideapp/models/table_availability_model.dart';
import 'package:tourguideapp/core/services/used_services_service.dart';
import 'package:tourguideapp/core/services/restaurant_availability_service.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UsedServicesService _usedServicesService = UsedServicesService();
  final RestaurantAvailabilityService _availabilityService =
      RestaurantAvailabilityService();

  // Lấy danh sách nhà hàng theo tỉnh
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

  // Lấy danh sách bàn của một nhà hàng (thông tin công khai)
  Future<List<TableModel>> getTablesByRestaurantId(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection('TABLE')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      return snapshot.docs
          .map((doc) => TableModel.fromMap({
                ...doc.data(),
                'tableId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching tables: $e');
      return [];
    }
  }

  // Kiểm tra bàn trống theo ngày (gọi API đối tác)
  Future<List<TableAvailabilityModel>> checkTableAvailability({
    required String restaurantId,
    required DateTime checkInDate,
    required TimeOfDay checkInTime,
    String? tableType,
  }) async {
    return await _availabilityService.checkTableAvailability(
      restaurantId: restaurantId,
      checkInDate: checkInDate,
      checkInTime: checkInTime,
      tableType: tableType,
    );
  }

  // Đặt bàn (gọi API đối tác)
  Future<bool> bookTable({
    required String restaurantId,
    required String tableId,
    required DateTime checkInDate,
    required TimeOfDay checkInTime,
    required int numberOfPeople,
  }) async {
    return await _availabilityService.bookTable(
      restaurantId: restaurantId,
      tableId: tableId,
      checkInDate: checkInDate,
      checkInTime: checkInTime,
      numberOfPeople: numberOfPeople,
    );
  }

  // Tạo booking mới và thêm vào used services
  Future<String> createRestaurantBooking(RestaurantBillModel booking) async {
    try {
      // Tạo booking trong collection RESTAURANT_BILL
      final docRef =
          await _firestore.collection('RESTAURANT_BILL').add(booking.toMap());
      final bookingId = docRef.id;

      // Cập nhật billId trong booking
      final updatedBooking = booking.copyWith(billId: bookingId);

      // Thêm vào used services
      await _usedServicesService
          .addRestaurantBookingToUsedServices(updatedBooking);

      return bookingId;
    } catch (e) {
      print('Error creating restaurant booking: $e');
      throw Exception('Không thể tạo booking: $e');
    }
  }

  // Cập nhật trạng thái booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection('RESTAURANT_BILL')
          .doc(bookingId)
          .update({'status': status});

      // Cập nhật trạng thái trong used services
      await _usedServicesService.updateUsedServiceStatus(bookingId, status);
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Không thể cập nhật trạng thái: $e');
    }
  }

  // Lấy booking theo userId
  Future<List<RestaurantBillModel>> getBookingsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('RESTAURANT_BILL')
          .where('userId', isEqualTo: userId)
          .orderBy('createdDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RestaurantBillModel.fromMap({
                ...doc.data(),
                'billId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }

  // Dữ liệu mẫu cho bàn (tạm thời)
  List<TableModel> getSampleTables(String restaurantId) {
    return [
      TableModel(
        tableId: 'T00001',
        restaurantId: restaurantId,
        tableName: 'Bàn VIP Cửa Sổ',
        numberOfTables: 5,
        dishType: 'Vietnamese Cuisine',
        priceRange: '500,000 - 1,000,000',
        maxPeople: 4,
        note: 'View đẹp, phù hợp cho bữa tối lãng mạn',
        price: 500000.0,
        photo:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
        description:
            'Bàn VIP với view cửa sổ đẹp, phù hợp cho bữa tối lãng mạn',
        isAvailable: true,
      ),
      TableModel(
        tableId: 'T00002',
        restaurantId: restaurantId,
        tableName: 'Bàn Thường',
        numberOfTables: 12,
        dishType: 'Vietnamese Cuisine',
        priceRange: '300,000 - 500,000',
        maxPeople: 6,
        note: 'Không gian rộng, phù hợp gia đình',
        price: 300000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        description: 'Bàn thường với không gian rộng rãi, phù hợp cho gia đình',
        isAvailable: true,
      ),
      TableModel(
        tableId: 'T00003',
        restaurantId: restaurantId,
        tableName: 'Bàn Ngoài Trời',
        numberOfTables: 4,
        dishType: 'Vietnamese Cuisine',
        priceRange: '400,000 - 600,000',
        maxPeople: 8,
        note: 'Không gian mở, gió mát',
        price: 400000.0,
        photo:
            'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
        description: 'Bàn ngoài trời với không gian mở, gió mát',
        isAvailable: true,
      ),
    ];
  }

  // Lọc nhà hàng theo budget
  List<CooperationModel> filterRestaurantsByBudget(
      List<CooperationModel> restaurants, double minBudget, double maxBudget) {
    // TODO: Implement budget filtering logic
    return restaurants;
  }

  // Lọc nhà hàng theo specialty
  List<CooperationModel> filterRestaurantsBySpecialty(
      List<CooperationModel> restaurants, String specialty) {
    // TODO: Implement specialty filtering logic
    return restaurants;
  }
}
