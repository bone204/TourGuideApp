import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tourguideapp/models/table_availability_model.dart';

class RestaurantAvailabilityService {
  // Giả lập API endpoint của đối tác
  static const String _mockApiUrl =
      'https://mock-restaurant-api.example.com/api/availability';

  // Dữ liệu mẫu để giả lập
  static final Map<String, List<TableAvailabilityModel>> _mockAvailabilityData =
      {
    'R00001': [
      // Restaurant ID
      TableAvailabilityModel(
        tableId: 'T00001',
        tableName: 'Bàn VIP Cửa Sổ',
        tableType: 'vip',
        capacity: 4,
        availableTables: 3,
        totalTables: 5,
        price: 500000.0,
        photo:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
        amenities: ['View đẹp', 'Yên tĩnh', 'Phục vụ riêng'],
        description:
            'Bàn VIP với view cửa sổ đẹp, phù hợp cho bữa tối lãng mạn',
        location: 'Window Side',
      ),
      TableAvailabilityModel(
        tableId: 'T00002',
        tableName: 'Bàn Thường',
        tableType: 'standard',
        capacity: 6,
        availableTables: 8,
        totalTables: 12,
        price: 300000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        amenities: ['Không gian rộng', 'Phù hợp gia đình'],
        description: 'Bàn thường với không gian rộng rãi, phù hợp cho gia đình',
        location: 'Indoor',
      ),
      TableAvailabilityModel(
        tableId: 'T00003',
        tableName: 'Bàn Ngoài Trời',
        tableType: 'outdoor',
        capacity: 8,
        availableTables: 2,
        totalTables: 4,
        price: 400000.0,
        photo:
            'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
        amenities: ['Không gian mở', 'Gió mát', 'View đẹp'],
        description: 'Bàn ngoài trời với không gian mở, gió mát',
        location: 'Garden',
      ),
    ],
    'R00002': [
      TableAvailabilityModel(
        tableId: 'T00004',
        tableName: 'Bàn VIP',
        tableType: 'vip',
        capacity: 4,
        availableTables: 1,
        totalTables: 3,
        price: 600000.0,
        photo:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
        amenities: ['Phục vụ riêng', 'Menu đặc biệt'],
        description: 'Bàn VIP với phục vụ riêng và menu đặc biệt',
        location: 'Private Area',
      ),
      TableAvailabilityModel(
        tableId: 'T00005',
        tableName: 'Bàn Thường',
        tableType: 'standard',
        capacity: 6,
        availableTables: 5,
        totalTables: 8,
        price: 250000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        amenities: ['Không gian thoải mái'],
        description: 'Bàn thường với không gian thoải mái',
        location: 'Main Hall',
      ),
    ],
    'R00003': [
      TableAvailabilityModel(
        tableId: 'T00006',
        tableName: 'Bàn VIP',
        tableType: 'vip',
        capacity: 4,
        availableTables: 0, // Hết bàn
        totalTables: 2,
        price: 800000.0,
        photo:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
        amenities: ['Phục vụ cao cấp', 'Menu đặc biệt', 'View đẹp'],
        description: 'Bàn VIP cao cấp với phục vụ đặc biệt',
        location: 'VIP Area',
      ),
      TableAvailabilityModel(
        tableId: 'T00007',
        tableName: 'Bàn Thường',
        tableType: 'standard',
        capacity: 8,
        availableTables: 3,
        totalTables: 6,
        price: 350000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        amenities: ['Không gian rộng', 'Phù hợp nhóm'],
        description: 'Bàn thường với không gian rộng, phù hợp cho nhóm',
        location: 'Main Hall',
      ),
    ],
  };

  /// Giả lập API call để kiểm tra bàn trống
  /// Trong thực tế, đây sẽ là HTTP request đến API của đối tác
  Future<List<TableAvailabilityModel>> checkTableAvailability({
    required String restaurantId,
    required DateTime checkInDate,
    required TimeOfDay checkInTime,
    String? tableType, // Optional: lọc theo loại bàn
  }) async {
    try {
      print('🍽️ Đang kiểm tra bàn trống cho nhà hàng $restaurantId...');
      print('📅 Ngày: ${checkInDate.toString().split(' ')[0]}');
      print(
          '🕐 Giờ: ${checkInTime.hour}:${checkInTime.minute.toString().padLeft(2, '0')}');
      if (tableType != null) {
        print('🍽️ Loại bàn: $tableType');
      }

      // Giả lập delay network
      await Future.delayed(Duration(milliseconds: 800));

      // Lấy dữ liệu mẫu
      final availabilityData = _mockAvailabilityData[restaurantId] ?? [];

      // Lọc theo loại bàn nếu có
      final filteredData = availabilityData.where((table) {
        // Lọc theo loại bàn nếu có
        final isTypeMatch = tableType == null || table.tableType == tableType;
        return isTypeMatch;
      }).toList();

      // Tạo dữ liệu mẫu động dựa trên ngày và giờ
      print(
          '📊 Tạo dữ liệu mẫu cho ngày ${checkInDate.toString().split(' ')[0]} - ${checkInTime.hour}:${checkInTime.minute.toString().padLeft(2, '0')}...');
      return _generateMockAvailabilityForDateTime(
          restaurantId, checkInDate, checkInTime, tableType);
    } catch (e) {
      print('❌ Lỗi khi kiểm tra bàn trống: $e');
      return [];
    }
  }

  /// Tạo dữ liệu mẫu cho ngày và giờ cụ thể
  List<TableAvailabilityModel> _generateMockAvailabilityForDateTime(
    String restaurantId,
    DateTime checkInDate,
    TimeOfDay checkInTime,
    String? tableType,
  ) {
    final tableTypes =
        tableType != null ? [tableType] : ['vip', 'standard', 'outdoor'];
    final results = <TableAvailabilityModel>[];

    // Tính thời gian (sáng/trưa/tối)
    final hour = checkInTime.hour;
    final timeSlot = hour < 11
        ? 'morning'
        : hour < 17
            ? 'afternoon'
            : 'evening';
    print('    🕐 Khung giờ: $timeSlot');

    for (final type in tableTypes) {
      // Tạo số bàn trống ngẫu nhiên dựa trên ngày và giờ
      final availableTables =
          _getRandomAvailabilityForDateTime(type, checkInDate, checkInTime);
      final totalTables =
          availableTables + [1, 2, 3].elementAt(DateTime.now().millisecond % 3);
      final basePrice = _getBasePriceForType(type);

      // Tính giá dựa trên ngày, giờ và loại bàn
      final priceVariation = _getPriceVariation(checkInDate, checkInTime);
      final finalPrice = basePrice * priceVariation;

      results.add(TableAvailabilityModel(
        tableId: 'T${restaurantId.substring(1)}${type[0].toUpperCase()}',
        tableName: _getTableNameForType(type),
        tableType: type,
        capacity: _getCapacityForType(type),
        availableTables: availableTables,
        totalTables: totalTables,
        price: finalPrice,
        photo: _getPhotoForType(type),
        amenities: _getAmenitiesForType(type),
        description: _getDescriptionForType(type),
        location: _getLocationForType(type),
      ));
    }

    return results;
  }

  int _getRandomAvailabilityForDateTime(
      String tableType, DateTime checkInDate, TimeOfDay checkInTime) {
    // Giả lập logic: cuối tuần và giờ ăn tối ít bàn trống hơn
    final isWeekend = checkInDate.weekday == DateTime.saturday ||
        checkInDate.weekday == DateTime.sunday;
    final hour = checkInTime.hour;
    final isPeakTime = (hour >= 11 && hour <= 13) || (hour >= 18 && hour <= 20);

    switch (tableType) {
      case 'vip':
        return isWeekend || isPeakTime
            ? [0, 1].elementAt(DateTime.now().millisecond % 2)
            : [1, 2, 3].elementAt(DateTime.now().millisecond % 3);
      case 'standard':
        return isWeekend || isPeakTime
            ? [2, 3, 5].elementAt(DateTime.now().millisecond % 3)
            : [5, 6, 8].elementAt(DateTime.now().millisecond % 3);
      case 'outdoor':
        return isWeekend
            ? [0, 1].elementAt(DateTime.now().millisecond % 2)
            : [1, 2, 3].elementAt(DateTime.now().millisecond % 3);
      default:
        return isWeekend || isPeakTime
            ? [1, 2].elementAt(DateTime.now().millisecond % 2)
            : [3, 4, 5].elementAt(DateTime.now().millisecond % 3);
    }
  }

  String _getTableNameForType(String tableType) {
    switch (tableType) {
      case 'vip':
        return 'Bàn VIP';
      case 'standard':
        return 'Bàn Thường';
      case 'outdoor':
        return 'Bàn Ngoài Trời';
      default:
        return 'Bàn Thường';
    }
  }

  int _getCapacityForType(String tableType) {
    switch (tableType) {
      case 'vip':
        return 4;
      case 'standard':
        return 6;
      case 'outdoor':
        return 8;
      default:
        return 6;
    }
  }

  String _getPhotoForType(String tableType) {
    switch (tableType) {
      case 'vip':
        return 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400';
      case 'standard':
        return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400';
      case 'outdoor':
        return 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400';
      default:
        return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400';
    }
  }

  List<String> _getAmenitiesForType(String tableType) {
    switch (tableType) {
      case 'vip':
        return ['Phục vụ riêng', 'Menu đặc biệt', 'View đẹp'];
      case 'standard':
        return ['Không gian thoải mái', 'Phù hợp gia đình'];
      case 'outdoor':
        return ['Không gian mở', 'Gió mát', 'View đẹp'];
      default:
        return ['Không gian thoải mái'];
    }
  }

  String _getDescriptionForType(String tableType) {
    switch (tableType) {
      case 'vip':
        return 'Bàn VIP với phục vụ đặc biệt và không gian riêng tư';
      case 'standard':
        return 'Bàn thường với không gian thoải mái, phù hợp cho gia đình';
      case 'outdoor':
        return 'Bàn ngoài trời với không gian mở và gió mát';
      default:
        return 'Bàn thường với không gian thoải mái';
    }
  }

  String _getLocationForType(String tableType) {
    switch (tableType) {
      case 'vip':
        return 'VIP Area';
      case 'standard':
        return 'Main Hall';
      case 'outdoor':
        return 'Garden';
      default:
        return 'Main Hall';
    }
  }

  double _getBasePriceForType(String tableType) {
    switch (tableType) {
      case 'vip':
        return 500000.0;
      case 'standard':
        return 300000.0;
      case 'outdoor':
        return 400000.0;
      default:
        return 300000.0;
    }
  }

  double _getPriceVariation(DateTime date, TimeOfDay time) {
    // Giá cao hơn vào cuối tuần và giờ ăn tối
    final weekday = date.weekday;
    final hour = time.hour;
    final isWeekend =
        weekday == DateTime.saturday || weekday == DateTime.sunday;
    final isPeakTime = (hour >= 11 && hour <= 13) || (hour >= 18 && hour <= 20);

    if (isWeekend && isPeakTime) {
      return 1.3; // Tăng 30%
    } else if (isWeekend || isPeakTime) {
      return 1.2; // Tăng 20%
    }
    return 1.0; // Giá bình thường
  }

  /// Giả lập API call để đặt bàn
  Future<bool> bookTable({
    required String restaurantId,
    required String tableId,
    required DateTime checkInDate,
    required TimeOfDay checkInTime,
    required int numberOfPeople,
  }) async {
    try {
      print('📝 Đang đặt bàn...');
      print('🍽️ Restaurant ID: $restaurantId');
      print('🍽️ Table ID: $tableId');
      print('📅 Ngày: ${checkInDate.toString().split(' ')[0]}');
      print(
          '🕐 Giờ: ${checkInTime.hour}:${checkInTime.minute.toString().padLeft(2, '0')}');
      print('👥 Số người: $numberOfPeople');

      // Giả lập delay network
      await Future.delayed(Duration(seconds: 2));

      // Giả lập 90% thành công
      final isSuccess = DateTime.now().millisecond % 10 < 9;

      if (isSuccess) {
        print('✅ Đặt bàn thành công!');
        return true;
      } else {
        print('❌ Đặt bàn thất bại (bàn đã được đặt bởi người khác)');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi khi đặt bàn: $e');
      return false;
    }
  }
}
