import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/models/room_model.dart';
import 'package:tourguideapp/models/hotel_bill_model.dart';
import 'package:tourguideapp/models/room_availability_model.dart';
import 'package:tourguideapp/core/services/used_services_service.dart';
import 'package:tourguideapp/core/services/hotel_availability_service.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UsedServicesService _usedServicesService = UsedServicesService();
  final HotelAvailabilityService _availabilityService =
      HotelAvailabilityService();

  // Lấy danh sách khách sạn theo tỉnh
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

  // Lấy danh sách phòng của một khách sạn (thông tin công khai)
  Future<List<RoomModel>> getRoomsByHotelId(String hotelId) async {
    try {
      final snapshot = await _firestore
          .collection('ROOM')
          .where('hotelId', isEqualTo: hotelId)
          .get();

      return snapshot.docs
          .map((doc) => RoomModel.fromMap({
                ...doc.data(),
                'roomId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

  // Kiểm tra phòng trống theo ngày (gọi API đối tác)
  Future<List<RoomAvailabilityModel>> checkRoomAvailability({
    required String hotelId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? roomType,
  }) async {
    return await _availabilityService.checkRoomAvailability(
      hotelId: hotelId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      roomType: roomType,
    );
  }

  // Đặt phòng (gọi API đối tác)
  Future<bool> bookRoom({
    required String hotelId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfRooms,
  }) async {
    return await _availabilityService.bookRoom(
      hotelId: hotelId,
      roomId: roomId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      numberOfRooms: numberOfRooms,
    );
  }

  // Tạo booking mới và thêm vào used services
  Future<String> createHotelBooking(HotelBillModel booking) async {
    try {
      // Tạo booking trong collection HOTEL_BILL
      final docRef =
          await _firestore.collection('HOTEL_BILL').add(booking.toMap());
      final bookingId = docRef.id;

      // Cập nhật billId trong booking
      final updatedBooking = booking.copyWith(billId: bookingId);

      // Thêm vào used services
      await _usedServicesService.addHotelBookingToUsedServices(updatedBooking);

      // Cập nhật travelPoint của user nếu có sử dụng
      if (booking.travelPointsUsed > 0) {
        final userId = booking.userId;
        final totalAmount = booking.total;

        // Trừ điểm đã sử dụng
        await _firestore.collection('USER').doc(userId).update({
          'travelPoint': FieldValue.increment(-booking.travelPointsUsed),
        });

        // Cộng điểm thưởng theo quy tắc
        final reward = totalAmount > 500000 ? 2000 : 1000;
        await _firestore.collection('USER').doc(userId).update({
          'travelPoint': FieldValue.increment(reward),
        });
      }

      return bookingId;
    } catch (e) {
      print('Error creating hotel booking: $e');
      throw Exception('Không thể tạo booking: $e');
    }
  }

  // Cập nhật trạng thái booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection('HOTEL_BILL')
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
  Future<List<HotelBillModel>> getBookingsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('HOTEL_BILL')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HotelBillModel.fromMap({
                ...doc.data(),
                'bookingId': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }

  // Dữ liệu mẫu cho phòng (tạm thời)
  List<RoomModel> getSampleRooms(String hotelId) {
    return [
      RoomModel(
        roomId: 'R00001',
        hotelId: hotelId,
        roomName: 'Phòng Đơn Standard',
        numberOfBeds: 1,
        capacity: 2,
        area: 25.0,
        basePrice: 800000.0,
        photo:
            'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        description:
            'Phòng đơn tiện nghi với 1 giường đơn, phù hợp cho 1-2 người. Có đầy đủ tiện nghi cơ bản.',
        roomType: 'single',
        amenities: [
          'WiFi',
          'Điều hòa',
          'TV',
          'Tủ lạnh mini',
          'Phòng tắm riêng'
        ],
      ),
      RoomModel(
        roomId: 'R00002',
        hotelId: hotelId,
        roomName: 'Phòng Đôi Deluxe',
        numberOfBeds: 2,
        capacity: 4,
        area: 35.0,
        basePrice: 1200000.0,
        photo:
            'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400',
        description:
            'Phòng đôi rộng rãi với 2 giường đơn, view đẹp, phù hợp cho gia đình nhỏ.',
        roomType: 'double',
        amenities: [
          'WiFi',
          'Điều hòa',
          'TV',
          'Tủ lạnh mini',
          'Phòng tắm riêng',
          'Ban công'
        ],
      ),
      RoomModel(
        roomId: 'R00003',
        hotelId: hotelId,
        roomName: 'Suite Premium',
        numberOfBeds: 1,
        capacity: 3,
        area: 50.0,
        basePrice: 2500000.0,
        photo:
            'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400',
        description:
            'Suite cao cấp với phòng ngủ và phòng khách riêng biệt, view toàn cảnh thành phố.',
        roomType: 'suite',
        amenities: [
          'WiFi',
          'Điều hòa',
          'TV',
          'Tủ lạnh mini',
          'Phòng tắm riêng',
          'Ban công',
          'Bồn tắm',
          'Mini bar'
        ],
      ),
    ];
  }
}
