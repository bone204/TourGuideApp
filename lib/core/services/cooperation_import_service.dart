import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/cooperation_model.dart';

class CooperationImportService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey;
  final FirebaseFirestore _firestore;

  CooperationImportService({
    required this.apiKey,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  // 20 tỉnh lớn cho hotel/restaurant
  final List<Map<String, dynamic>> provincesForHotelRestaurant = [
    {'name': 'Hà Nội', 'lat': 21.0285, 'lng': 105.8542, 'radius': 35000.0},
    {'name': 'Hồ Chí Minh', 'lat': 10.7769, 'lng': 106.7009, 'radius': 50000.0},
    {'name': 'Đà Nẵng', 'lat': 16.0544, 'lng': 108.2022, 'radius': 35000.0},
    {'name': 'Hải Phòng', 'lat': 20.8449, 'lng': 106.6881, 'radius': 25000.0},
    {'name': 'Cần Thơ', 'lat': 10.0452, 'lng': 105.7469, 'radius': 20000.0},
    {'name': 'Huế', 'lat': 16.4637, 'lng': 107.5909, 'radius': 20000.0},
    {
      'name': 'Bà Rịa - Vũng Tàu',
      'lat': 10.4114,
      'lng': 107.1362,
      'radius': 20000.0
    },
    {'name': 'Quảng Ninh', 'lat': 21.1170, 'lng': 107.2925, 'radius': 30000.0},
    {'name': 'Thanh Hóa', 'lat': 19.8079, 'lng': 105.7764, 'radius': 20000.0},
    {'name': 'Nghệ An', 'lat': 19.2342, 'lng': 104.9200, 'radius': 20000.0},
    {'name': 'Bình Dương', 'lat': 11.3254, 'lng': 106.4770, 'radius': 20000.0},
    {'name': 'Bình Thuận', 'lat': 10.9280, 'lng': 108.1000, 'radius': 20000.0},
    {'name': 'Kiên Giang', 'lat': 10.0070, 'lng': 105.0763, 'radius': 20000.0},
    {'name': 'Lâm Đồng', 'lat': 11.9404, 'lng': 108.4587, 'radius': 20000.0},
    {'name': 'Quảng Nam', 'lat': 15.5393, 'lng': 108.0191, 'radius': 20000.0},
    {
      'name': 'Thừa Thiên Huế',
      'lat': 16.4637,
      'lng': 107.5909,
      'radius': 20000.0
    },
    {'name': 'Khánh Hòa', 'lat': 12.2388, 'lng': 109.1967, 'radius': 20000.0},
  ];

  // 10 tỉnh nổi tiếng cho eatery
  final List<Map<String, dynamic>> provincesForEatery = [
    {'name': 'Hà Nội', 'lat': 21.0285, 'lng': 105.8542, 'radius': 20000.0},
    {'name': 'Hồ Chí Minh', 'lat': 10.7769, 'lng': 106.7009, 'radius': 25000.0},
    {'name': 'Đà Nẵng', 'lat': 16.0544, 'lng': 108.2022, 'radius': 20000.0},
    {'name': 'Hải Phòng', 'lat': 20.8449, 'lng': 106.6881, 'radius': 15000.0},
    {'name': 'Bình Dương', 'lat': 11.3254, 'lng': 106.4770, 'radius': 20000.0},
    {'name': 'Cần Thơ', 'lat': 10.0452, 'lng': 105.7469, 'radius': 15000.0},
    {'name': 'Lâm Đồng', 'lat': 11.9404, 'lng': 108.4587, 'radius': 15000.0},
    {'name': 'Khánh Hòa', 'lat': 12.2388, 'lng': 109.1967, 'radius': 15000.0},
    {'name': 'Huế', 'lat': 16.4637, 'lng': 107.5909, 'radius': 15000.0},
    {
      'name': 'Bà Rịa - Vũng Tàu',
      'lat': 10.4114,
      'lng': 107.1362,
      'radius': 15000.0
    },
  ];

  final eateryKeywords = [
    'quán',
    'bún',
    'phở',
    'cơm',
    'cháo',
    'bánh khọt',
    'bánh xèo',
    'bánh canh',
    'bánh cuốn',
    'bánh ướt',
    'bánh bột lọc',
    'bánh bèo',
    'bánh hỏi',
    'bánh tráng',
    'bánh bao',
    'bánh mì',
    'bánh ngọt',
    'bánh căn',
    'cơm tấm',
    'hủ tiếu',
    'ăn vặt',
    'food',
    'street food',
    'gánh',
    'lẩu',
    'gà',
    'vịt',
    'ốc',
    'nem',
    'chè',
    'bò',
    'thịt',
    'cá',
    'tôm',
    'hải sản'
  ];

  bool isEatery(String name) {
    final lower = name.toLowerCase();
    return eateryKeywords.any((kw) => lower.contains(kw));
  }

  Future<void> importCooperationsToFirebase() async {
    print('🚀 Bắt đầu import hotel/restaurant cho 20 tỉnh lớn...');
    for (final province in provincesForHotelRestaurant) {
      for (final type in ['hotel', 'restaurant']) {
        print('\n📍 Đang xử lý: ${province['name']} - $type');
        await _importForType(
          province['name'],
          province['lat'],
          province['lng'],
          province['radius'],
          type,
          limit: 5,
        );
        await Future.delayed(Duration(seconds: 1));
      }
    }
    print('🚀 Bắt đầu import eatery cho 10 tỉnh nổi tiếng...');
    for (final province in provincesForEatery) {
      print('\n📍 Đang xử lý: ${province['name']} - eatery');
      await _importForEatery(
        province['name'],
        province['lat'],
        province['lng'],
        province['radius'],
        limit: 7,
      );
      await Future.delayed(Duration(seconds: 1));
    }
    print('\n✅ Hoàn thành import!');
  }

  Future<void> _importForType(
      String province, double lat, double lng, double radius, String type,
      {int limit = 3}) async {
    // ✅ Tối ưu: Chỉ dùng 1 từ khóa chính thay vì 2
    List<String> textQueries = [];
    if (type == 'hotel') {
      textQueries = [
        'khách sạn nổi tiếng $province', // ✅ Chỉ 1 từ khóa chính
      ];
    } else if (type == 'restaurant') {
      textQueries = [
        'nhà hàng nổi tiếng $province', // ✅ Chỉ 1 từ khóa chính
      ];
    }

    List<Map<String, dynamic>> allPlaces = [];
    final seenPlaceIds = <String>{};

    for (final query in textQueries) {
      print('  🔍 Đang tìm kiếm với từ khóa: "$query"');
      // ✅ Tối ưu: Giảm radius và chỉ lấy 1 trang đầu
      final places = await searchByTextOptimized(query, lat, lng,
          radius: radius, maxPages: 1);

      // Loại bỏ trùng lặp
      for (final place in places) {
        final placeId = place['place_id'];
        if (!seenPlaceIds.contains(placeId)) {
          allPlaces.add(place);
          seenPlaceIds.add(placeId);
        }
      }

      await Future.delayed(Duration(seconds: 2)); // ✅ Tăng delay
    }

    print('  📊 Tìm thấy ${allPlaces.length} $type');

    // Log tất cả kết quả trước khi lọc
    print('  📋 Danh sách tất cả kết quả trước khi lọc:');
    for (int i = 0; i < allPlaces.length; i++) {
      final place = allPlaces[i];
      final name = place['name'] ?? 'Unknown';
      final types = List<String>.from(place['types'] ?? []);
      final rating = place['rating']?.toDouble() ?? 0.0;
      final userRatingsTotal = place['user_ratings_total'] ?? 0;
      print(
          '    ${i + 1}. $name (types: ${types.join(', ')}) - Rating: $rating ($userRatingsTotal đánh giá)');
    }

    // Lọc theo loại
    final filteredPlaces = allPlaces.where((place) {
      final name = (place['name'] ?? '').toLowerCase();
      final types = List<String>.from(place['types'] ?? []);
      final rating = place['rating']?.toDouble() ?? 0.0;
      final userRatingsTotal = place['user_ratings_total'] ?? 0;

      // ✅ Tối ưu: Giảm yêu cầu rating
      if (rating < 3.0 || userRatingsTotal < 10) return false;

      // Kiểm tra type phù hợp
      if (type == 'hotel') {
        return types.contains('lodging') ||
            name.contains('khách sạn') ||
            name.contains('hotel') ||
            name.contains('resort');
      } else if (type == 'restaurant') {
        return types.contains('restaurant') ||
            types.contains('food') ||
            name.contains('nhà hàng') ||
            name.contains('restaurant');
      }

      return true;
    }).toList();

    print('  🎯 Sau khi lọc: ${filteredPlaces.length} $type');

    int count = 0;
    for (final place in filteredPlaces) {
      if (count >= limit) break;
      final placeId = place['place_id'];
      final existing = await _firestore
          .collection('COOPERATION')
          .where('place_id', isEqualTo: placeId)
          .get();
      if (existing.docs.isNotEmpty) {
        print('    ⚠️  Đã tồn tại: ${place['name']}');
        continue;
      }

      // ✅ Tối ưu: Chỉ gọi Place Details cho địa điểm thực sự cần
      final cooperation =
          await _convertToCooperationModelOptimized(place, province, type);
      await _saveToFirebase(cooperation, placeId);
      print('    ✅ Imported: ${cooperation.name}');
      count++;
    }
  }

  Future<void> _importForEatery(
      String province, double lat, double lng, double radius,
      {int limit = 7}) async {
    // ✅ Tối ưu: Chỉ dùng 2 từ khóa chính thay vì 4
    final textQueries = [
      'quán ăn nổi tiếng $province', // ✅ Từ khóa chính
      'đặc sản $province', // ✅ Từ khóa phụ
    ];

    List<Map<String, dynamic>> allPlaces = [];
    final seenPlaceIds = <String>{};

    for (final query in textQueries) {
      print('  🔍 Đang tìm kiếm với từ khóa: "$query"');
      // ✅ Tối ưu: Giảm radius và chỉ lấy 1 trang đầu
      final places = await searchByTextOptimized(query, lat, lng,
          radius: radius, maxPages: 1);

      for (final place in places) {
        final placeId = place['place_id'];
        if (!seenPlaceIds.contains(placeId)) {
          allPlaces.add(place);
          seenPlaceIds.add(placeId);
        }
      }

      await Future.delayed(Duration(seconds: 2)); // ✅ Tăng delay
    }

    print('  📊 Tìm thấy ${allPlaces.length} địa điểm từ Text Search');

    // Log tất cả kết quả trước khi lọc
    print('  📋 Danh sách tất cả kết quả trước khi lọc:');
    for (int i = 0; i < allPlaces.length; i++) {
      final place = allPlaces[i];
      final name = place['name'] ?? 'Unknown';
      final types = List<String>.from(place['types'] ?? []);
      final rating = place['rating']?.toDouble() ?? 0.0;
      final userRatingsTotal = place['user_ratings_total'] ?? 0;
      print(
          '    ${i + 1}. $name (types: ${types.join(', ')}) - Rating: $rating ($userRatingsTotal đánh giá)');
    }

    // Lọc ra quán ăn đặc sản
    final eateryPlaces = allPlaces.where((place) {
      final name = (place['name'] ?? '').toLowerCase();
      final types = List<String>.from(place['types'] ?? []);
      final rating = place['rating']?.toDouble() ?? 0.0;
      final userRatingsTotal = place['user_ratings_total'] ?? 0;

      // Loại bỏ khách sạn, resort
      if (types.contains('lodging') ||
          types.contains('hotel') ||
          types.contains('resort')) {
        return false;
      }

      // Loại bỏ từ khóa khách sạn
      final hotelKeywords = [
        'hotel',
        'khách sạn',
        'resort',
        'nhà nghỉ',
        'homestay',
        'villa',
        'hostel',
        'apartment'
      ];
      if (hotelKeywords.any((kw) => name.contains(kw))) {
        return false;
      }

      // ✅ Tối ưu: Giảm yêu cầu rating
      return isEatery(name) && rating >= 3.0 && userRatingsTotal >= 5;
    }).toList();

    print('  🎯 Sau khi lọc: ${eateryPlaces.length} eatery');

    if (eateryPlaces.isEmpty) {
      print('  ⚠️  Không tìm thấy eatery nào sau khi lọc!');
      return;
    }

    int count = 0;
    for (final place in eateryPlaces) {
      if (count >= limit) break;
      final placeId = place['place_id'];
      final existing = await _firestore
          .collection('COOPERATION')
          .where('place_id', isEqualTo: placeId)
          .get();
      if (existing.docs.isNotEmpty) {
        print('    ⚠️  Đã tồn tại: ${place['name']}');
        continue;
      }

      // ✅ Tối ưu: Chỉ gọi Place Details cho địa điểm thực sự cần
      final cooperation =
          await _convertToCooperationModelOptimized(place, province, 'eatery');
      await _saveToFirebase(cooperation, placeId);
      print('    ✅ Imported: ${cooperation.name}');
      count++;
    }
  }

  // ✅ Tối ưu: Hàm mới chỉ lấy 1 trang và giảm delay
  Future<List<Map<String, dynamic>>> searchByTextOptimized(
      String query, double lat, double lng,
      {double radius = 50000, int maxPages = 1}) async {
    List<Map<String, dynamic>> allResults = [];
    String? nextPageToken;
    int pageCount = 0;

    do {
      String url = Uri.parse(
              '$_baseUrl/textsearch/json?query=$query&location=$lat,$lng&radius=$radius&language=vi&key=$apiKey')
          .toString();

      if (nextPageToken != null) {
        url += '&pagetoken=$nextPageToken';
      }

      try {
        print(
            '    🌐 Gọi Text Search API với query: "$query" (trang ${pageCount + 1})...');
        final startTime = DateTime.now();

        final response = await http.get(Uri.parse(url));

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        print(
            '    ⏱️  Text Search response trong ${duration.inMilliseconds}ms');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            final results = List<Map<String, dynamic>>.from(data['results']);
            allResults.addAll(results);
            nextPageToken = data['next_page_token'];
            pageCount++;

            print(
                '    ✅ Text Search thành công: ${results.length} kết quả (tổng: ${allResults.length})');

            // ✅ Tối ưu: Chỉ lấy tối đa maxPages trang
            if (nextPageToken != null && pageCount < maxPages) {
              print(
                  '    ⏳ Đợi 1 giây trước khi lấy trang tiếp theo...'); // ✅ Giảm delay
              await Future.delayed(Duration(seconds: 1));
            } else {
              break; // ✅ Dừng nếu đã đủ trang
            }
          } else {
            print(
                '    ❌ Text Search failed: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
            break;
          }
        } else {
          print('    ❌ Text Search HTTP error: ${response.statusCode}');
          break;
        }
      } catch (e) {
        print('    ❌ Text Search error: $e');
        break;
      }
    } while (nextPageToken != null);

    return allResults;
  }

  // ✅ Tối ưu: Hàm mới không gọi Place Details để tiết kiệm request
  Future<CooperationModel> _convertToCooperationModelOptimized(
      Map<String, dynamic> place, String province, String type) async {
    final name = place['name'] ?? '';
    final lat = place['geometry']['location']['lat'] ?? 0.0;
    final lng = place['geometry']['location']['lng'] ?? 0.0;
    final address = place['vicinity'] ?? '';
    final placeId = place['place_id'] ?? '';
    final rating = place['rating']?.toDouble() ?? 0.0;
    final userRatingsTotal = place['user_ratings_total'] ?? 0;

    print(
        '        📍 Xử lý: $name (ID: $placeId) - Rating: $rating ($userRatingsTotal đánh giá)');

    // ✅ Tối ưu: Không gọi Place Details, chỉ dùng dữ liệu từ Text Search
    String description = '';
    String photo = '';

    // Lấy ảnh từ Text Search nếu có
    if (place['photos'] != null && place['photos'].isNotEmpty) {
      final photoRef = place['photos'][0]['photo_reference'];
      photo = _getPhotoUrl(photoRef, maxWidth: 800); // ✅ Giảm chất lượng ảnh
      print('        📸 Có ảnh từ Text Search: Có');
    }

    return CooperationModel(
      cooperationId: '', // sẽ generate khi lưu
      name: name,
      type: type,
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: lat,
      longitude: lng,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: address,
      district: '',
      city: '',
      province: province,
      photo: photo,
      extension: description,
      introduction: description,
      contractDate: '',
      contractTerm: '',
      bankAccountNumber: '',
      bankAccountName: '',
      bankName: '',
      bookingTimes: 0,
      revenue: 0.0,
      averageRating: rating,
      priceLevel: '', // Chưa có thông tin giá
    );
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&fields=name,formatted_address,geometry,photos,editorial_summary,reviews,rating,user_ratings_total,types,opening_hours,formatted_phone_number,website,price_level&language=vi&key=$apiKey',
    );

    try {
      print('      🌐 Gọi Place Details API...');
      final startTime = DateTime.now();

      final response = await http.get(url);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print(
          '      ⏱️  Place Details response trong ${duration.inMilliseconds}ms');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          print('      ✅ Place Details thành công');
          return data['result'];
        } else {
          print(
              '      ❌ Place Details failed: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        print('      ❌ Place Details HTTP error: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('      ❌ Place Details error: $e');
      return null;
    }
  }

  String _getPhotoUrl(String photoReference, {int maxWidth = 1200}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }

  Future<void> _saveToFirebase(
      CooperationModel cooperation, String placeId) async {
    try {
      final newId = await _generateCooperationId();
      final newCoop = cooperation.copyWith(cooperationId: newId);
      await _firestore.collection('COOPERATION').doc(newId).set({
        ...newCoop.toMap(),
        'place_id': placeId,
      });
    } catch (e) {
      print('❌ Error saving cooperation: $e');
    }
  }

  Future<String> _generateCooperationId() async {
    try {
      final snapshot = await _firestore
          .collection('COOPERATION')
          .orderBy('cooperationId', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return 'C00001';
      final lastId = snapshot.docs.first['cooperationId'] as String;
      final number = int.parse(lastId.substring(1)) + 1;
      return 'C${number.toString().padLeft(5, '0')}';
    } catch (e) {
      return 'C${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  Future<void> convertEateryToHotel() async {
    final query = await _firestore
        .collection('COOPERATION')
        .where('type', isEqualTo: 'eatery')
        .get();

    int updated = 0;
    for (final doc in query.docs) {
      await doc.reference.update({'type': 'hotel'});
      updated++;
    }
    print('Đã chuyển $updated eatery thành hotel!');
  }
}
