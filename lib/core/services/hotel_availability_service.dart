import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourguideapp/models/room_availability_model.dart';

class HotelAvailabilityService {
  // Giả lập API endpoint của đối tác
  static const String _mockApiUrl =
      'https://mock-hotel-api.example.com/api/availability';

  // Dữ liệu mẫu để giả lập
  static final Map<String, List<RoomAvailabilityModel>> _mockAvailabilityData =
      {
    'H00001': [
      // Hotel ID
      RoomAvailabilityModel(
        roomId: 'R00001',
        roomName: 'Phòng Standard',
        roomType: 'single',
        capacity: 2,
        availableRooms: 5,
        totalRooms: 10,
        price: 800000.0,
        photo:
            'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        amenities: ['WiFi', 'TV', 'Điều hòa', 'Tủ lạnh'],
        description: 'Phòng tiêu chuẩn với đầy đủ tiện nghi cơ bản',
      ),
      RoomAvailabilityModel(
        roomId: 'R00002',
        roomName: 'Phòng Deluxe',
        roomType: 'double',
        capacity: 3,
        availableRooms: 3,
        totalRooms: 8,
        price: 1200000.0,
        photo:
            'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400',
        amenities: ['WiFi', 'TV', 'Điều hòa', 'Tủ lạnh', 'Mini bar', 'Bồn tắm'],
        description: 'Phòng cao cấp với view đẹp và tiện nghi sang trọng',
      ),
      RoomAvailabilityModel(
        roomId: 'R00003',
        roomName: 'Phòng Suite',
        roomType: 'suite',
        capacity: 4,
        availableRooms: 1,
        totalRooms: 3,
        price: 2500000.0,
        photo:
            'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400',
        amenities: [
          'WiFi',
          'TV',
          'Điều hòa',
          'Tủ lạnh',
          'Mini bar',
          'Bồn tắm',
          'Phòng khách',
          'Ban công'
        ],
        description: 'Phòng suite sang trọng với không gian rộng rãi',
      ),
    ],
    'H00002': [
      RoomAvailabilityModel(
        roomId: 'R00004',
        roomName: 'Phòng Standard',
        roomType: 'single',
        capacity: 2,
        availableRooms: 8,
        totalRooms: 15,
        price: 600000.0,
        photo:
            'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        amenities: ['WiFi', 'TV', 'Điều hòa'],
        description: 'Phòng tiêu chuẩn giá rẻ',
      ),
      RoomAvailabilityModel(
        roomId: 'R00005',
        roomName: 'Phòng Deluxe',
        roomType: 'double',
        capacity: 3,
        availableRooms: 4,
        totalRooms: 6,
        price: 1000000.0,
        photo:
            'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400',
        amenities: ['WiFi', 'TV', 'Điều hòa', 'Tủ lạnh', 'Mini bar'],
        description: 'Phòng cao cấp với tiện nghi đầy đủ',
      ),
    ],
    'H00003': [
      RoomAvailabilityModel(
        roomId: 'R00006',
        roomName: 'Phòng Standard',
        roomType: 'single',
        capacity: 2,
        availableRooms: 0, // Hết phòng
        totalRooms: 5,
        price: 900000.0,
        photo:
            'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        amenities: ['WiFi', 'TV', 'Điều hòa', 'Tủ lạnh'],
        description: 'Phòng tiêu chuẩn chất lượng cao',
      ),
      RoomAvailabilityModel(
        roomId: 'R00007',
        roomName: 'Phòng Deluxe',
        roomType: 'double',
        capacity: 3,
        availableRooms: 2,
        totalRooms: 4,
        price: 1500000.0,
        photo:
            'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400',
        amenities: ['WiFi', 'TV', 'Điều hòa', 'Tủ lạnh', 'Mini bar', 'Bồn tắm'],
        description: 'Phòng cao cấp với view đẹp',
      ),
    ],
  };

  /// Giả lập API call để kiểm tra phòng trống
  /// Trong thực tế, đây sẽ là HTTP request đến API của đối tác
  Future<List<RoomAvailabilityModel>> checkRoomAvailability({
    required String hotelId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? roomType, // Optional: lọc theo loại phòng
  }) async {
    try {
      print('🏨 Đang kiểm tra phòng trống cho khách sạn $hotelId...');
      print('📅 Check-in: ${checkInDate.toString().split(' ')[0]}');
      print('📅 Check-out: ${checkOutDate.toString().split(' ')[0]}');
      if (roomType != null) {
        print('🏠 Loại phòng: $roomType');
      }

      // Giả lập delay network
      await Future.delayed(Duration(milliseconds: 800));

      // Lấy dữ liệu mẫu
      final availabilityData = _mockAvailabilityData[hotelId] ?? [];

      // Lọc theo loại phòng nếu có
      final filteredData = availabilityData.where((room) {
        // Lọc theo loại phòng nếu có
        final isTypeMatch = roomType == null || room.roomType == roomType;
        return isTypeMatch;
      }).toList();

      // Tạo dữ liệu mẫu động dựa trên ngày check-in/check-out
      print(
          '📊 Tạo dữ liệu mẫu cho ngày ${checkInDate.toString().split(' ')[0]} - ${checkOutDate.toString().split(' ')[0]}...');
      return _generateMockAvailabilityForDate(
          hotelId, checkInDate, checkOutDate, roomType);
    } catch (e) {
      print('❌ Lỗi khi kiểm tra phòng trống: $e');
      return [];
    }
  }

  /// Tạo dữ liệu mẫu cho ngày check-in/check-out
  List<RoomAvailabilityModel> _generateMockAvailabilityForDate(
    String hotelId,
    DateTime checkInDate,
    DateTime checkOutDate,
    String? roomType,
  ) {
    final roomTypes =
        roomType != null ? [roomType] : ['single', 'double', 'suite'];
    final results = <RoomAvailabilityModel>[];

    // Tính số ngày ở
    final numberOfDays = checkOutDate.difference(checkInDate).inDays;
    print('    📅 Số ngày ở: $numberOfDays ngày');

    for (final type in roomTypes) {
      // Tạo số phòng trống ngẫu nhiên dựa trên ngày
      final availableRooms =
          _getRandomAvailabilityForDate(type, checkInDate, checkOutDate);
      final totalRooms =
          availableRooms + [1, 2, 3].elementAt(DateTime.now().millisecond % 3);
      final basePrice = _getBasePriceForType(type);

      // Tính giá dựa trên ngày và số ngày ở
      final priceVariation = _getPriceVariation(checkInDate);
      final finalPrice = basePrice * priceVariation * numberOfDays;

      results.add(RoomAvailabilityModel(
        roomId: 'R${hotelId.substring(1)}${type[0].toUpperCase()}',
        roomName: _getRoomNameForType(type),
        roomType: type,
        capacity: _getCapacityForType(type),
        availableRooms: availableRooms,
        totalRooms: totalRooms,
        price: finalPrice,
        photo: _getPhotoForType(type),
        amenities: _getAmenitiesForType(type),
        description: _getDescriptionForType(type),
      ));
    }

    return results;
  }

  int _getRandomAvailabilityForDate(
      String roomType, DateTime checkInDate, DateTime checkOutDate) {
    // Giả lập logic: cuối tuần ít phòng trống hơn, ngày thường nhiều phòng trống hơn
    final isWeekend = checkInDate.weekday == DateTime.saturday ||
        checkInDate.weekday == DateTime.sunday;

    switch (roomType) {
      case 'single':
        return isWeekend
            ? [0, 1, 2].elementAt(DateTime.now().millisecond % 3)
            : [2, 3, 5, 8].elementAt(DateTime.now().millisecond % 4);
      case 'double':
        return isWeekend
            ? [0, 1].elementAt(DateTime.now().millisecond % 2)
            : [1, 2, 3, 4].elementAt(DateTime.now().millisecond % 4);
      case 'suite':
        return isWeekend
            ? 0
            : [0, 1, 2].elementAt(DateTime.now().millisecond % 3);
      default:
        return isWeekend
            ? [0, 1].elementAt(DateTime.now().millisecond % 2)
            : [1, 2, 3].elementAt(DateTime.now().millisecond % 3);
    }
  }

  String _getRoomNameForType(String roomType) {
    switch (roomType) {
      case 'single':
        return 'Phòng Standard';
      case 'double':
        return 'Phòng Deluxe';
      case 'suite':
        return 'Phòng Suite';
      default:
        return 'Phòng Standard';
    }
  }

  int _getCapacityForType(String roomType) {
    switch (roomType) {
      case 'single':
        return 2;
      case 'double':
        return 3;
      case 'suite':
        return 4;
      default:
        return 2;
    }
  }

  String _getPhotoForType(String roomType) {
    switch (roomType) {
      case 'single':
        return 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400';
      case 'double':
        return 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400';
      case 'suite':
        return 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400';
      default:
        return 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400';
    }
  }

  List<String> _getAmenitiesForType(String roomType) {
    switch (roomType) {
      case 'single':
        return ['WiFi', 'TV', 'Điều hòa'];
      case 'double':
        return ['WiFi', 'TV', 'Điều hòa', 'Tủ lạnh', 'Mini bar'];
      case 'suite':
        return [
          'WiFi',
          'TV',
          'Điều hòa',
          'Tủ lạnh',
          'Mini bar',
          'Bồn tắm',
          'Phòng khách'
        ];
      default:
        return ['WiFi', 'TV', 'Điều hòa'];
    }
  }

  String _getDescriptionForType(String roomType) {
    switch (roomType) {
      case 'single':
        return 'Phòng tiêu chuẩn với đầy đủ tiện nghi cơ bản';
      case 'double':
        return 'Phòng cao cấp với tiện nghi đầy đủ';
      case 'suite':
        return 'Phòng suite sang trọng với không gian rộng rãi';
      default:
        return 'Phòng tiêu chuẩn với đầy đủ tiện nghi cơ bản';
    }
  }

  double _getBasePriceForType(String roomType) {
    switch (roomType) {
      case 'single':
        return 600000.0;
      case 'double':
        return 1000000.0;
      case 'suite':
        return 2000000.0;
      default:
        return 800000.0;
    }
  }

  double _getPriceVariation(DateTime date) {
    // Giá cao hơn vào cuối tuần
    final weekday = date.weekday;
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return 1.2; // Tăng 20%
    }
    return 1.0; // Giá bình thường
  }

  /// Giả lập API call để đặt phòng
  Future<bool> bookRoom({
    required String hotelId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfRooms,
  }) async {
    try {
      print('📝 Đang đặt phòng...');
      print('🏨 Hotel ID: $hotelId');
      print('🏠 Room ID: $roomId');
      print('📅 Check-in: ${checkInDate.toString().split(' ')[0]}');
      print('📅 Check-out: ${checkOutDate.toString().split(' ')[0]}');
      print('🔢 Số phòng: $numberOfRooms');

      // Giả lập delay network
      await Future.delayed(Duration(seconds: 2));

      // Giả lập 90% thành công
      final isSuccess = DateTime.now().millisecond % 10 < 9;

      if (isSuccess) {
        print('✅ Đặt phòng thành công!');
        return true;
      } else {
        print('❌ Đặt phòng thất bại (phòng đã được đặt bởi người khác)');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi khi đặt phòng: $e');
      return false;
    }
  }
}
