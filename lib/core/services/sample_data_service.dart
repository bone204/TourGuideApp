import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/room_model.dart';
import 'package:tourguideapp/models/table_model.dart';

class SampleDataService {
  final FirebaseFirestore _firestore;

  SampleDataService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Tạo dữ liệu mẫu cho ROOM
  Future<void> createSampleRooms() async {
    print('🚀 Bắt đầu tạo dữ liệu mẫu cho ROOM...');

    // Lấy danh sách hotel từ COOPERATION
    final hotelsQuery = await _firestore
        .collection('COOPERATION')
        .where('type', isEqualTo: 'hotel')
        .limit(50) // Giới hạn 50 khách sạn
        .get();

    if (hotelsQuery.docs.isEmpty) {
      print('⚠️  Không tìm thấy hotel nào trong COOPERATION!');
      return;
    }

    print('📊 Tìm thấy ${hotelsQuery.docs.length} hotel để tạo phòng mẫu');

    int totalRoomsCreated = 0;

    for (final hotelDoc in hotelsQuery.docs) {
      final hotelId = hotelDoc.id;
      final hotelName = hotelDoc.data()['name'] ?? 'Unknown Hotel';

      print('  🏨 Đang tạo phòng cho: $hotelName');

      // Tạo các loại phòng mẫu cho mỗi khách sạn
      final sampleRooms = _generateSampleRooms(hotelId, hotelName);

      for (final room in sampleRooms) {
        try {
          await _firestore
              .collection('ROOM')
              .doc(room.roomId)
              .set(room.toMap());
          totalRoomsCreated++;
          print('    ✅ Tạo phòng: ${room.roomName}');
        } catch (e) {
          print('    ❌ Lỗi tạo phòng ${room.roomName}: $e');
        }
      }

      // Cập nhật numberOfObjects cho hotel
      await hotelDoc.reference.update({
        'numberOfObjects': sampleRooms.length,
        'numberOfObjectTypes':
            sampleRooms.map((r) => r.roomType).toSet().length,
      });
    }

    print('🎉 Hoàn thành! Đã tạo $totalRoomsCreated phòng mẫu');
  }

  // Tạo dữ liệu mẫu cho TABLE
  Future<void> createSampleTables() async {
    print('🚀 Bắt đầu tạo dữ liệu mẫu cho TABLE...');

    // Lấy danh sách restaurant và eatery từ COOPERATION
    final restaurantsQuery = await _firestore
        .collection('COOPERATION')
        .where('type', whereIn: ['restaurant', 'eatery'])
        .limit(100) // Giới hạn 100 nhà hàng/quán ăn
        .get();

    if (restaurantsQuery.docs.isEmpty) {
      print('⚠️  Không tìm thấy restaurant/eatery nào trong COOPERATION!');
      return;
    }

    print(
        '📊 Tìm thấy ${restaurantsQuery.docs.length} restaurant/eatery để tạo bàn mẫu');

    int totalTablesCreated = 0;

    for (final restaurantDoc in restaurantsQuery.docs) {
      final restaurantId = restaurantDoc.id;
      final restaurantName =
          restaurantDoc.data()['name'] ?? 'Unknown Restaurant';
      final restaurantType = restaurantDoc.data()['type'] ?? 'restaurant';

      print('  🍽️  Đang tạo bàn cho: $restaurantName ($restaurantType)');

      // Tạo các loại bàn mẫu cho mỗi nhà hàng/quán ăn
      final sampleTables =
          _generateSampleTables(restaurantId, restaurantName, restaurantType);

      for (final table in sampleTables) {
        try {
          await _firestore
              .collection('TABLE')
              .doc(table.tableId)
              .set(table.toMap());
          totalTablesCreated++;
          print('    ✅ Tạo bàn: ${table.tableName}');
        } catch (e) {
          print('    ❌ Lỗi tạo bàn ${table.tableName}: $e');
        }
      }

      // Cập nhật numberOfObjects cho restaurant/eatery
      await restaurantDoc.reference.update({
        'numberOfObjects': sampleTables.length,
        'numberOfObjectTypes':
            sampleTables.map((t) => t.dishType).toSet().length,
      });
    }

    print('🎉 Hoàn thành! Đã tạo $totalTablesCreated bàn mẫu');
  }

  // Tạo tất cả dữ liệu mẫu
  Future<void> createAllSampleData() async {
    print('🚀 Bắt đầu tạo tất cả dữ liệu mẫu...');

    await createSampleRooms();
    await createSampleTables();

    print('🎉 Hoàn thành tạo tất cả dữ liệu mẫu!');
  }

  // Tạo danh sách phòng mẫu cho một khách sạn
  List<RoomModel> _generateSampleRooms(String hotelId, String hotelName) {
    final List<RoomModel> rooms = [];
    int roomCounter = 1;

    // Phòng Standard
    for (int i = 0; i < 3; i++) {
      rooms.add(RoomModel(
        roomId:
            'R${hotelId.substring(1)}${roomCounter.toString().padLeft(3, '0')}',
        hotelId: hotelId,
        roomName: 'Phòng Standard ${roomCounter}',
        numberOfBeds: 1,
        maxPeople: 2,
        area: 25.0 + (i * 5.0),
        price: 500000.0 + (i * 100000.0),
        numberOfRooms: 1,
        photo:
            'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800',
        description:
            'Phòng tiêu chuẩn với đầy đủ tiện nghi cơ bản, phù hợp cho 1-2 người.',
        roomType: 'Standard',
        isAvailable: true,
        amenities: [
          'WiFi',
          'TV',
          'Điều hòa',
          'Tủ lạnh mini',
          'Phòng tắm riêng'
        ],
        priceType: 'per night',
      ));
      roomCounter++;
    }

    // Phòng Deluxe
    for (int i = 0; i < 2; i++) {
      rooms.add(RoomModel(
        roomId:
            'R${hotelId.substring(1)}${roomCounter.toString().padLeft(3, '0')}',
        hotelId: hotelId,
        roomName: 'Phòng Deluxe ${roomCounter}',
        numberOfBeds: 1,
        maxPeople: 2,
        area: 35.0 + (i * 5.0),
        price: 800000.0 + (i * 150000.0),
        numberOfRooms: 1,
        photo:
            'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        description:
            'Phòng cao cấp với view đẹp, tiện nghi hiện đại và không gian rộng rãi.',
        roomType: 'Deluxe',
        isAvailable: true,
        amenities: [
          'WiFi',
          'TV 4K',
          'Điều hòa',
          'Tủ lạnh mini',
          'Phòng tắm riêng',
          'Bồn tắm',
          'Ban công'
        ],
        priceType: 'per night',
      ));
      roomCounter++;
    }

    // Phòng Family
    rooms.add(RoomModel(
      roomId:
          'R${hotelId.substring(1)}${roomCounter.toString().padLeft(3, '0')}',
      hotelId: hotelId,
      roomName: 'Phòng Family',
      numberOfBeds: 2,
      maxPeople: 4,
      area: 45.0,
      price: 1200000.0,
      numberOfRooms: 1,
      photo:
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
      description:
          'Phòng gia đình rộng rãi với 2 giường, phù hợp cho gia đình 3-4 người.',
      roomType: 'Family',
      isAvailable: true,
      amenities: [
        'WiFi',
        'TV 4K',
        'Điều hòa',
        'Tủ lạnh mini',
        'Phòng tắm riêng',
        'Bồn tắm',
        'Ban công',
        'Sofa'
      ],
      priceType: 'per night',
    ));
    roomCounter++;

    // Phòng Suite
    rooms.add(RoomModel(
      roomId:
          'R${hotelId.substring(1)}${roomCounter.toString().padLeft(3, '0')}',
      hotelId: hotelId,
      roomName: 'Phòng Suite',
      numberOfBeds: 1,
      maxPeople: 2,
      area: 60.0,
      price: 2000000.0,
      numberOfRooms: 1,
      photo:
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
      description:
          'Phòng suite sang trọng với phòng khách riêng, view toàn cảnh và dịch vụ cao cấp.',
      roomType: 'Suite',
      isAvailable: true,
      amenities: [
        'WiFi',
        'TV 4K',
        'Điều hòa',
        'Tủ lạnh mini',
        'Phòng tắm riêng',
        'Bồn tắm',
        'Ban công',
        'Phòng khách',
        'Mini bar',
        'Dịch vụ phòng'
      ],
      priceType: 'per night',
    ));

    return rooms;
  }

  // Tạo danh sách bàn mẫu cho một nhà hàng/quán ăn
  List<TableModel> _generateSampleTables(
      String restaurantId, String restaurantName, String restaurantType) {
    final List<TableModel> tables = [];
    int tableCounter = 1;

    // Bàn 2 người
    for (int i = 0; i < 3; i++) {
      tables.add(TableModel(
        tableId:
            'T${restaurantId.substring(1)}${tableCounter.toString().padLeft(3, '0')}',
        restaurantId: restaurantId,
        tableName: 'Bàn 2 người ${tableCounter}',
        numberOfTables: 1,
        dishType: _getDishTypeForRestaurant(restaurantType),
        priceRange: '100,000 - 300,000 VNĐ',
        maxPeople: 2,
        note: 'Bàn lãng mạn, phù hợp cho cặp đôi',
        price: 150000.0 + (i * 50000.0),
        photo:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
        description: 'Bàn nhỏ ấm cúng, phù hợp cho 2 người.',
        isAvailable: true,
      ));
      tableCounter++;
    }

    // Bàn 4 người
    for (int i = 0; i < 2; i++) {
      tables.add(TableModel(
        tableId:
            'T${restaurantId.substring(1)}${tableCounter.toString().padLeft(3, '0')}',
        restaurantId: restaurantId,
        tableName: 'Bàn 4 người ${tableCounter}',
        numberOfTables: 1,
        dishType: _getDishTypeForRestaurant(restaurantType),
        priceRange: '200,000 - 500,000 VNĐ',
        maxPeople: 4,
        note: 'Bàn tròn, phù hợp cho gia đình nhỏ',
        price: 250000.0 + (i * 75000.0),
        photo:
            'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800',
        description: 'Bàn tròn rộng rãi, phù hợp cho gia đình 4 người.',
        isAvailable: true,
      ));
      tableCounter++;
    }

    // Bàn 6-8 người
    tables.add(TableModel(
      tableId:
          'T${restaurantId.substring(1)}${tableCounter.toString().padLeft(3, '0')}',
      restaurantId: restaurantId,
      tableName: 'Bàn lớn',
      numberOfTables: 1,
      dishType: _getDishTypeForRestaurant(restaurantType),
      priceRange: '400,000 - 800,000 VNĐ',
      maxPeople: 8,
      note: 'Bàn dài, phù hợp cho nhóm bạn',
      price: 500000.0,
      photo:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      description: 'Bàn dài rộng rãi, phù hợp cho nhóm bạn hoặc gia đình lớn.',
      isAvailable: true,
    ));

    return tables;
  }

  // Lấy loại món ăn phù hợp với loại nhà hàng
  String _getDishTypeForRestaurant(String restaurantType) {
    switch (restaurantType) {
      case 'restaurant':
        return 'Món chính';
      case 'eatery':
        return 'Đặc sản';
      default:
        return 'Món ăn';
    }
  }

  // Xóa tất cả dữ liệu mẫu
  Future<void> deleteAllSampleData() async {
    print('🗑️  Bắt đầu xóa tất cả dữ liệu mẫu...');

    // Xóa ROOM
    final roomsQuery = await _firestore.collection('ROOM').get();
    for (final doc in roomsQuery.docs) {
      await doc.reference.delete();
    }
    print('✅ Đã xóa ${roomsQuery.docs.length} phòng');

    // Xóa TABLE
    final tablesQuery = await _firestore.collection('TABLE').get();
    for (final doc in tablesQuery.docs) {
      await doc.reference.delete();
    }
    print('✅ Đã xóa ${tablesQuery.docs.length} bàn');

    print('🎉 Hoàn thành xóa dữ liệu mẫu!');
  }
}
