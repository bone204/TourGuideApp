import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/room_model.dart';
import 'package:tourguideapp/models/table_model.dart';

class SampleDataService {
  final FirebaseFirestore _firestore;

  SampleDataService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Tạo dữ liệu mẫu cho ROOM
  Future<void> createSampleRooms() async {
    print('🏨 Bắt đầu tạo dữ liệu phòng mẫu...');

    final rooms = [
      RoomModel(
        roomId: 'R00001',
        hotelId: 'H00001',
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
        hotelId: 'H00001',
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
        hotelId: 'H00001',
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
      RoomModel(
        roomId: 'R00004',
        hotelId: 'H00002',
        roomName: 'Phòng Đơn Economy',
        numberOfBeds: 1,
        capacity: 2,
        area: 20.0,
        basePrice: 600000.0,
        photo:
            'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        description:
            'Phòng đơn tiết kiệm với đầy đủ tiện nghi cơ bản, phù hợp cho khách du lịch.',
        roomType: 'single',
        amenities: ['WiFi', 'Điều hòa', 'TV', 'Phòng tắm riêng'],
      ),
      RoomModel(
        roomId: 'R00005',
        hotelId: 'H00002',
        roomName: 'Phòng Đôi Standard',
        numberOfBeds: 2,
        capacity: 3,
        area: 30.0,
        basePrice: 1000000.0,
        photo:
            'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400',
        description:
            'Phòng đôi tiêu chuẩn với 2 giường đơn, không gian thoải mái.',
        roomType: 'double',
        amenities: [
          'WiFi',
          'Điều hòa',
          'TV',
          'Tủ lạnh mini',
          'Phòng tắm riêng'
        ],
      ),
      RoomModel(
        roomId: 'R00006',
        hotelId: 'H00003',
        roomName: 'Phòng Đơn Business',
        numberOfBeds: 1,
        capacity: 2,
        area: 28.0,
        basePrice: 900000.0,
        photo:
            'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        description:
            'Phòng đơn dành cho khách doanh nhân với bàn làm việc và không gian yên tĩnh.',
        roomType: 'single',
        amenities: [
          'WiFi',
          'Điều hòa',
          'TV',
          'Tủ lạnh mini',
          'Phòng tắm riêng',
          'Bàn làm việc'
        ],
      ),
      RoomModel(
        roomId: 'R00007',
        hotelId: 'H00003',
        roomName: 'Phòng Đôi Executive',
        numberOfBeds: 1,
        capacity: 3,
        area: 40.0,
        basePrice: 1500000.0,
        photo:
            'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400',
        description:
            'Phòng đôi cao cấp với giường king size, view đẹp và tiện nghi sang trọng.',
        roomType: 'double',
        amenities: [
          'WiFi',
          'Điều hòa',
          'TV',
          'Tủ lạnh mini',
          'Phòng tắm riêng',
          'Ban công',
          'Bồn tắm'
        ],
      ),
    ];

    for (final room in rooms) {
      await _firestore.collection('ROOM').doc(room.roomId).set(room.toMap());
      print('✅ Đã tạo phòng: ${room.roomName}');
    }

    print('🎉 Hoàn thành tạo ${rooms.length} phòng mẫu!');
  }

  // Tạo dữ liệu mẫu cho TABLE
  Future<void> createSampleTables() async {
    print('🍽️ Bắt đầu tạo dữ liệu bàn mẫu...');

    final tables = [
      TableModel(
        tableId: 'T00001',
        restaurantId: 'C00001',
        tableName: 'Bàn 2 người - Góc cửa sổ',
        numberOfTables: 5,
        dishType: 'Món Việt Nam',
        priceRange: '100,000 - 300,000 VNĐ',
        maxPeople: 2,
        note: 'View đẹp, phù hợp cho cặp đôi',
        price: 150000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        description:
            'Bàn 2 người với view cửa sổ đẹp, phù hợp cho bữa tối lãng mạn.',
        isAvailable: true,
      ),
      TableModel(
        tableId: 'T00002',
        restaurantId: 'C00001',
        tableName: 'Bàn 4 người - Giữa nhà hàng',
        numberOfTables: 8,
        dishType: 'Món Việt Nam',
        priceRange: '200,000 - 500,000 VNĐ',
        maxPeople: 4,
        note: 'Không gian thoải mái cho gia đình',
        price: 250000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        description:
            'Bàn 4 người ở vị trí trung tâm, không gian thoải mái cho gia đình.',
        isAvailable: true,
      ),
      TableModel(
        tableId: 'T00003',
        restaurantId: 'C00001',
        tableName: 'Bàn 6 người - Phòng riêng',
        numberOfTables: 3,
        dishType: 'Món Việt Nam',
        priceRange: '300,000 - 800,000 VNĐ',
        maxPeople: 6,
        note: 'Phòng riêng yên tĩnh',
        price: 400000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        description:
            'Bàn 6 người trong phòng riêng, phù hợp cho nhóm bạn hoặc gia đình lớn.',
        isAvailable: true,
      ),
      TableModel(
        tableId: 'T00004',
        restaurantId: 'C00002',
        tableName: 'Bàn 2 người - Ngoài trời',
        numberOfTables: 6,
        dishType: 'Hải sản',
        priceRange: '150,000 - 400,000 VNĐ',
        maxPeople: 2,
        note: 'Không gian ngoài trời mát mẻ',
        price: 200000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        description: 'Bàn 2 người ngoài trời với không gian mát mẻ, view đẹp.',
        isAvailable: true,
      ),
      TableModel(
        tableId: 'T00005',
        restaurantId: 'C00002',
        tableName: 'Bàn 4 người - Trong nhà',
        numberOfTables: 10,
        dishType: 'Hải sản',
        priceRange: '250,000 - 600,000 VNĐ',
        maxPeople: 4,
        note: 'Không gian điều hòa thoải mái',
        price: 300000.0,
        photo:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        description:
            'Bàn 4 người trong nhà với điều hòa, không gian thoải mái.',
        isAvailable: true,
      ),
    ];

    for (final table in tables) {
      await _firestore
          .collection('TABLE')
          .doc(table.tableId)
          .set(table.toMap());
      print('✅ Đã tạo bàn: ${table.tableName}');
    }

    print('🎉 Hoàn thành tạo ${tables.length} bàn mẫu!');
  }

  // Tạo tất cả dữ liệu mẫu
  Future<void> createAllSampleData() async {
    print('🚀 Bắt đầu tạo tất cả dữ liệu mẫu...');

    await createSampleRooms();
    await createSampleTables();

    print('🎉 Hoàn thành tạo tất cả dữ liệu mẫu!');
  }

  // Xóa tất cả dữ liệu mẫu
  Future<void> deleteAllSampleData() async {
    print('🗑️ Bắt đầu xóa dữ liệu mẫu...');

    // Xóa tất cả phòng
    final roomDocs = await _firestore.collection('ROOM').get();
    for (final doc in roomDocs.docs) {
      await doc.reference.delete();
    }
    print('✅ Đã xóa ${roomDocs.docs.length} phòng');

    // Xóa tất cả bàn
    final tableDocs = await _firestore.collection('TABLE').get();
    for (final doc in tableDocs.docs) {
      await doc.reference.delete();
    }
    print('✅ Đã xóa ${tableDocs.docs.length} bàn');

    print('🎉 Hoàn thành xóa dữ liệu mẫu!');
  }
}
