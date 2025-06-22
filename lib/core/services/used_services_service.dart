import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/hotel_bill_model.dart';

class UsedServicesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm dịch vụ đã sử dụng vào danh sách
  Future<void> addUsedService({
    required String userId,
    required String serviceType,
    required String serviceName,
    required String serviceId,
    required DateTime usedDate,
    required double amount,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.collection('USED_SERVICES').add({
        'userId': userId,
        'serviceType': serviceType, // 'hotel', 'bus', 'eatery', etc.
        'serviceName': serviceName,
        'serviceId': serviceId,
        'usedDate': usedDate.toIso8601String(),
        'amount': amount,
        'status': status,
        'additionalData': additionalData ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding used service: $e');
      throw Exception('Không thể thêm dịch vụ đã sử dụng: $e');
    }
  }

  // Thêm hotel booking vào used services
  Future<void> addHotelBookingToUsedServices(HotelBillModel booking) async {
    try {
      await addUsedService(
        userId: booking.userId,
        serviceType: 'hotel',
        serviceName: 'Đặt phòng khách sạn', // Tên dịch vụ chung
        serviceId: booking.billId,
        usedDate: DateTime.parse(booking.checkInDate),
        amount: booking.total,
        status: booking.status,
        additionalData: {
          'checkInDate': booking.checkInDate,
          'checkOutDate': booking.checkOutDate,
          'numberOfRooms': booking.numberOfRooms,
          'roomIds': booking.roomIds,
          'voucherId': booking.voucherId,
          'travelPointsUsed': booking.travelPointsUsed,
        },
      );
    } catch (e) {
      print('Error adding hotel booking to used services: $e');
      throw Exception('Không thể thêm đặt phòng vào dịch vụ đã sử dụng: $e');
    }
  }

  // Lấy danh sách dịch vụ đã sử dụng của user
  Future<List<Map<String, dynamic>>> getUsedServicesByUserId(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('USED_SERVICES')
          .where('userId', isEqualTo: userId)
          .orderBy('usedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error fetching used services: $e');
      return [];
    }
  }

  // Lấy danh sách dịch vụ đã sử dụng theo loại
  Future<List<Map<String, dynamic>>> getUsedServicesByType(
      String userId, String serviceType) async {
    try {
      final snapshot = await _firestore
          .collection('USED_SERVICES')
          .where('userId', isEqualTo: userId)
          .where('serviceType', isEqualTo: serviceType)
          .orderBy('usedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error fetching used services by type: $e');
      return [];
    }
  }

  // Cập nhật trạng thái dịch vụ đã sử dụng
  Future<void> updateUsedServiceStatus(String serviceId, String status) async {
    try {
      await _firestore
          .collection('USED_SERVICES')
          .doc(serviceId)
          .update({'status': status});
    } catch (e) {
      print('Error updating used service status: $e');
      throw Exception('Không thể cập nhật trạng thái: $e');
    }
  }
}
