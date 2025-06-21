import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/destination_model.dart';

class PlacesImportService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey;
  final FirebaseFirestore _firestore;
  final Map<String, Map<String, String>> _wikiCache = {}; // ✅ Cache Wikipedia

  PlacesImportService({
    required this.apiKey,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final List<Map<String, dynamic>> vietnamProvinces = [
    {
      'name': 'Đà Nẵng',
      'lat': 16.0544,
      'lng': 108.2022,
      'limit': 50,
      'radius': 35000.0
    },
    {
      'name': 'Hà Nội',
      'lat': 21.0285,
      'lng': 105.8542,
      'limit': 50,
      'radius': 35000.0
    },
    {
      'name': 'Hồ Chí Minh',
      'lat': 10.7769,
      'lng': 106.7009,
      'limit': 50,
      'radius': 50000.0
    },
    {
      'name': 'Hải Phòng',
      'lat': 20.8449,
      'lng': 106.6881,
      'limit': 30,
      'radius': 25000.0
    },
    {
      'name': 'Cần Thơ',
      'lat': 10.0452,
      'lng': 105.7469,
      'limit': 30,
      'radius': 20000.0
    },
    {
      'name': 'An Giang',
      'lat': 10.5216,
      'lng': 105.1259,
      'limit': 20,
      'radius': 20000.0
    },
    {
      'name': 'Bà Rịa - Vũng Tàu',
      'lat': 10.5417,
      'lng': 107.2428,
      'limit': 50,
      'radius': 25000.0
    },
    {
      'name': 'Bắc Giang',
      'lat': 21.2810,
      'lng': 106.1978,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Bắc Kạn',
      'lat': 22.1470,
      'lng': 105.8348,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Bạc Liêu',
      'lat': 9.2940,
      'lng': 105.7245,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Bắc Ninh',
      'lat': 21.1860,
      'lng': 106.0764,
      'limit': 30,
      'radius': 40000.0
    },
    {
      'name': 'Bến Tre',
      'lat': 10.2415,
      'lng': 106.3759,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Bình Định',
      'lat': 13.7820,
      'lng': 109.2197,
      'limit': 30,
      'radius': 40000.0
    },
    {
      'name': 'Bình Dương',
      'lat': 11.3254,
      'lng': 106.4770,
      'limit': 30,
      'radius': 30000.0
    },
    {
      'name': 'Bình Phước',
      'lat': 11.7512,
      'lng': 106.7235,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Bình Thuận',
      'lat': 10.9280,
      'lng': 108.1000,
      'limit': 30,
      'radius': 40000.0
    },
    {
      'name': 'Cà Mau',
      'lat': 9.1750,
      'lng': 105.1500,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Cao Bằng',
      'lat': 22.6657,
      'lng': 106.2570,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Đắk Lắk',
      'lat': 12.7100,
      'lng': 108.2378,
      'limit': 20,
      'radius': 50000.0
    },
    {
      'name': 'Đắk Nông',
      'lat': 12.2737,
      'lng': 107.6098,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Điện Biên',
      'lat': 21.3860,
      'lng': 103.0230,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Đồng Nai',
      'lat': 11.0584,
      'lng': 107.0763,
      'limit': 30,
      'radius': 60000.0
    },
    {
      'name': 'Đồng Tháp',
      'lat': 10.5354,
      'lng': 105.6280,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Gia Lai',
      'lat': 13.8079,
      'lng': 108.1094,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Hà Giang',
      'lat': 22.8233,
      'lng': 104.9836,
      'limit': 20,
      'radius': 30000.0
    },
    {
      'name': 'Hà Nam',
      'lat': 20.5411,
      'lng': 105.9229,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Hà Tĩnh',
      'lat': 18.3559,
      'lng': 105.8877,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Hải Dương',
      'lat': 20.9373,
      'lng': 106.3147,
      'limit': 20,
      'radius': 20000.0
    },
    {
      'name': 'Hậu Giang',
      'lat': 9.7579,
      'lng': 105.6410,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Hòa Bình',
      'lat': 20.8517,
      'lng': 105.3376,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Hưng Yên',
      'lat': 20.8526,
      'lng': 106.0162,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Khánh Hòa',
      'lat': 12.2388,
      'lng': 109.1967,
      'limit': 30,
      'radius': 50000.0
    },
    {
      'name': 'Kiên Giang',
      'lat': 10.0070,
      'lng': 105.0763,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Kon Tum',
      'lat': 14.3545,
      'lng': 108.0076,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Lai Châu',
      'lat': 22.3931,
      'lng': 103.4582,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Lâm Đồng',
      'lat': 11.9404,
      'lng': 108.4587,
      'limit': 30,
      'radius': 100000.0
    },
    {
      'name': 'Lạng Sơn',
      'lat': 21.8455,
      'lng': 106.7615,
      'limit': 10,
      'radius': 20000.0
    },
    {
      'name': 'Lào Cai',
      'lat': 22.4800,
      'lng': 103.9750,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Long An',
      'lat': 10.5432,
      'lng': 106.4105,
      'limit': 15,
      'radius': 30000.0
    },
    {
      'name': 'Nam Định',
      'lat': 20.4389,
      'lng': 106.1621,
      'limit': 15,
      'radius': 30000.0
    },
    {
      'name': 'Nghệ An',
      'lat': 19.2342,
      'lng': 104.9200,
      'limit': 15,
      'radius': 30000.0
    },
    {
      'name': 'Ninh Bình',
      'lat': 20.2500,
      'lng': 105.9740,
      'limit': 15,
      'radius': 20000.0
    },
    {
      'name': 'Ninh Thuận',
      'lat': 11.5647,
      'lng': 108.9886,
      'limit': 20,
      'radius': 20000.0
    },
    {
      'name': 'Phú Thọ',
      'lat': 21.2840,
      'lng': 105.1951,
      'limit': 10,
      'radius': 20000.0
    },
    {
      'name': 'Phú Yên',
      'lat': 13.0882,
      'lng': 109.0929,
      'limit': 30,
      'radius': 40000.0
    },
    {
      'name': 'Quảng Bình',
      'lat': 17.6103,
      'lng': 106.3487,
      'limit': 30,
      'radius': 30000.0
    },
    {
      'name': 'Quảng Nam',
      'lat': 15.5393,
      'lng': 108.0191,
      'limit': 30,
      'radius': 40000.0
    },
    {
      'name': 'Quảng Ngãi',
      'lat': 15.1200,
      'lng': 108.8000,
      'limit': 60,
      'radius': 40000.0
    },
    {
      'name': 'Quảng Ninh',
      'lat': 21.1170,
      'lng': 107.2925,
      'limit': 50,
      'radius': 50000.0
    },
    {
      'name': 'Quảng Trị',
      'lat': 16.7500,
      'lng': 107.2000,
      'limit': 15,
      'radius': 20000.0
    },
    {
      'name': 'Sóc Trăng',
      'lat': 9.6024,
      'lng': 105.9739,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Sơn La',
      'lat': 21.3270,
      'lng': 103.9144,
      'limit': 10,
      'radius': 30000.0
    },
    {
      'name': 'Tây Ninh',
      'lat': 11.3185,
      'lng': 106.0983,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Thái Bình',
      'lat': 20.4464,
      'lng': 106.3364,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Thái Nguyên',
      'lat': 21.5672,
      'lng': 105.8252,
      'limit': 10,
      'radius': 30000.0
    },
    {
      'name': 'Thanh Hóa',
      'lat': 19.8079,
      'lng': 105.7764,
      'limit': 15,
      'radius': 30000.0
    },
    {
      'name': 'Thừa Thiên Huế',
      'lat': 16.4637,
      'lng': 107.5909,
      'limit': 50,
      'radius': 30000.0
    },
    {
      'name': 'Tiền Giang',
      'lat': 10.4494,
      'lng': 106.3420,
      'limit': 15,
      'radius': 20000.0
    },
    {
      'name': 'Trà Vinh',
      'lat': 9.8127,
      'lng': 106.2993,
      'limit': 10,
      'radius': 20000.0
    },
    {
      'name': 'Tuyên Quang',
      'lat': 21.8232,
      'lng': 105.2180,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Vĩnh Long',
      'lat': 10.2538,
      'lng': 105.9722,
      'limit': 20,
      'radius': 30000.0
    },
    {
      'name': 'Vĩnh Phúc',
      'lat': 21.3082,
      'lng': 105.6049,
      'limit': 10,
      'radius': 20000.0
    },
    {
      'name': 'Yên Bái',
      'lat': 21.7000,
      'lng': 104.8667,
      'limit': 10,
      'radius': 10000.0
    },
  ];

  // ✅ Danh sách từ khóa để lọc địa điểm du lịch
  final List<String> touristKeywords = [
    'beach',
    'island'
        'mountain',
    'park',
    'walking street',
    'bridge',
    'temple',
    'pagoda',
    'museum',
    'tower',
    'cave',
    'waterfall',
    'lake',
    'river',
    'island',
    'resort',
    //'hotel',
    //'restaurant',
    'viewpoint',
    'landmark',
    'monument',
    'palace',
    'fortress',
    'castle',
    'garden',
    'zoo',
    'biển',
    'đảo',
    'đèo',
    'đồi',
    'thung lũng',
    'núi',
    'công viên',
    'phố đi bộ',
    'cầu',
    'chùa',
    'đền',
    'bảo tàng',
    'tháp',
    'hang',
    'thác',
    'hồ',
    'sông',
    'đảo',
    'khu nghỉ',
    //'khách sạn',
    //'nhà hàng',
    'điểm ngắm',
    'công trình',
    'tượng đài',
    'cung điện',
    'pháo đài',
    'lâu đài',
    'vườn'
        'sở thú'
  ];

  // ✅ Danh sách từ khóa loại trừ (không phải du lịch)
  final List<String> excludeKeywords = [
    'club',
    'bar',
    'pub',
    'karaoke',
    'massage',
    'spa',
    'salon',
    'clinic',
    'hospital',
    'school',
    'university',
    'office',
    'company',
    'factory',
    'warehouse',
    'market',
    'supermarket',
    'mall',
    'shop',
    'store',
    'bank',
    'atm',
    'gas station',
    'parking',
    'câu lạc bộ',
    'quán bar',
    'karaoke',
    'massage',
    'spa',
    'tiệm làm tóc',
    'phòng khám',
    'bệnh viện',
    'trường học',
    'đại học',
    'văn phòng',
    'công ty',
    'nhà máy',
    'kho',
    'chợ',
    'siêu thị',
    'trung tâm mua sắm',
    'cửa hàng',
    'ngân hàng',
    'cây xăng',
    'bãi đỗ xe'
  ];

  Future<void> importPlacesToFirebase() async {
    print('🚀 Bắt đầu import places cho ${vietnamProvinces.length} tỉnh...');
    int totalRequests = 0;

    for (final province in vietnamProvinces) {
      print('\n📍 Đang xử lý tỉnh: ${province['name']}');
      final startTime = DateTime.now();

      await _importPlacesForCity(
        province['name'],
        province['lat'],
        province['lng'],
        province['limit'],
        (province['radius'] as num).toDouble(),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('⏱️  Hoàn thành ${province['name']} trong ${duration.inSeconds}s');

      await Future.delayed(Duration(seconds: 1));
    }

    print('\n✅ Hoàn thành import tất cả tỉnh!');
  }

  Future<void> _importPlacesForCity(String cityName, double latitude,
      double longitude, int limit, double radius) async {
    try {
      print('  🔍 Đang tìm kiếm địa điểm gần ${cityName}...');
      final startTime = DateTime.now();

      // 1. Nearby Search - tìm địa điểm gần đó
      // final nearbyPlaces = await searchNearbyPlaces(
      //   latitude: latitude,
      //   longitude: longitude,
      //   radius: radius,
      //   type: 'tourist_attraction',
      // );

      // 2. Text Search - tìm địa điểm nổi tiếng bằng từ khóa
      final textQueries = [
        'địa điểm du lịch nổi tiếng $cityName',
        'du lịch $cityName',
        'điểm đến $cityName',
        'thắng cảnh $cityName',
        'di tích $cityName'
      ];

      List<Map<String, dynamic>> textPlaces = [];
      for (final query in textQueries) {
        print('  🔍 Đang tìm kiếm với từ khóa: "$query"');
        final places =
            await searchByText(query, latitude, longitude, radius: radius);
        textPlaces.addAll(places);
        await Future.delayed(Duration(seconds: 1)); // Tiết kiệm request
      }

      // 3. Gộp và loại bỏ trùng lặp
      final allPlaces = <Map<String, dynamic>>[];
      final seenPlaceIds = <String>{};

      // // Thêm từ Nearby Search
      // for (final place in nearbyPlaces) {
      //   final placeId = place['place_id'];
      //   if (!seenPlaceIds.contains(placeId)) {
      //     allPlaces.add(place);
      //     seenPlaceIds.add(placeId);
      //   }
      // }

      // Thêm từ Text Search (chỉ những cái chưa có)
      for (final place in textPlaces) {
        final placeId = place['place_id'];
        if (!seenPlaceIds.contains(placeId)) {
          allPlaces.add(place);
          seenPlaceIds.add(placeId);
        }
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      //print('  📊 Tìm thấy ${nearbyPlaces.length} địa điểm từ Nearby Search');
      print('  📊 Tìm thấy ${textPlaces.length} địa điểm từ Text Search');
      print(
          '  📊 Tổng cộng ${allPlaces.length} địa điểm sau khi loại bỏ trùng lặp');
      print('  📊 Thời gian tìm kiếm: ${duration.inMilliseconds}ms');

      // ✅ Lọc địa điểm du lịch chất lượng
      final filteredPlaces = _filterTouristPlaces(allPlaces);
      print('  🎯 Sau khi lọc: ${filteredPlaces.length} địa điểm du lịch');

      // Log tất cả kết quả trước khi lọc
      print('  📋 Danh sách tất cả kết quả trước khi lọc:');
      for (int i = 0; i < allPlaces.length; i++) {
        final place = allPlaces[i];
        final name = place['name'] ?? 'Unknown';
        final types = List<String>.from(place['types'] ?? []);
        final rating = place['rating']?.toDouble() ?? 0.0;
        final userRatingsTotal = place['user_ratings_total'] ?? 0;
        //final source = nearbyPlaces.contains(place) ? 'Nearby' : 'Text';
        print(
            '    ${i + 1}. $name (types: ${types.join(', ')}) - Rating: $rating ($userRatingsTotal đánh giá) - Source: Text Search');
      }

      final limitedPlaces = filteredPlaces.take(limit).toList();
      print('  🎯 Giới hạn lấy ${limitedPlaces.length} địa điểm đầu tiên');

      int processedCount = 0;
      int skippedCount = 0;
      int importedCount = 0;

      for (var i = 0; i < limitedPlaces.length; i++) {
        final place = limitedPlaces[i];
        final placeName = place['name'] ?? 'Unknown';
        print('  📍 [${i + 1}/${limitedPlaces.length}] Đang xử lý: $placeName');

        final placeId = place['place_id'];
        final existingPlace = await _firestore
            .collection('DESTINATION')
            .where('place_id', isEqualTo: placeId)
            .get();

        if (existingPlace.docs.isEmpty) {
          print('    🔄 Đang lấy chi tiết cho: $placeName');
          final destinationStartTime = DateTime.now();

          final destination =
              await _convertToDestinationModelWithDetails(place, cityName);

          final destinationEndTime = DateTime.now();
          final destinationDuration =
              destinationEndTime.difference(destinationStartTime);
          print(
              '    ⏱️  Lấy chi tiết xong trong ${destinationDuration.inMilliseconds}ms');

          await _saveToFirebase(destination, placeId);
          importedCount++;
          print('    ✅ Imported: ${destination.destinationName}');
        } else {
          skippedCount++;
          print('    ⚠️  Existed: $placeName');
        }

        processedCount++;
        print(
            '    📈 Tiến độ: $processedCount/$limitedPlaces.length (Imported: $importedCount, Skipped: $skippedCount)');
      }

      print(
          '  🎉 Hoàn thành ${cityName}: Imported $importedCount, Skipped $skippedCount');
    } catch (e) {
      print('❌ Error importing $cityName: $e');
    }
  }

  // ✅ Hàm lọc địa điểm du lịch
  List<Map<String, dynamic>> _filterTouristPlaces(
      List<Map<String, dynamic>> places) {
    return places.where((place) {
      final name = (place['name'] ?? '').toLowerCase();
      final types = List<String>.from(place['types'] ?? []);
      final rating = place['rating']?.toDouble() ?? 0.0;
      final userRatingsTotal = place['user_ratings_total'] ?? 0;

      // ✅ Loại trừ địa điểm không phải du lịch
      for (final excludeKeyword in excludeKeywords) {
        if (name.contains(excludeKeyword.toLowerCase())) {
          return false;
        }
      }

      // ✅ Kiểm tra có từ khóa du lịch không
      bool hasTouristKeyword = false;
      for (final touristKeyword in touristKeywords) {
        if (name.contains(touristKeyword.toLowerCase())) {
          hasTouristKeyword = true;
          break;
        }
      }

      // ✅ Kiểm tra types có liên quan đến du lịch
      final touristTypes = [
        'tourist_attraction',
        'point_of_interest',
        'establishment',
        'natural_feature',
        'beach',
        'mountain',
        'lake',
        'river',
        'park',
        'bridge',
        'museum',
        'church',
        'temple',
        'building',
        'amusement_park',
        'aquarium',
        'art_gallery',
        'movie_theater',
        'stadium',
        'zoo',
        'botanical_garden',
        'historical_site',
        'market',
        'cultural_center',
        'viewpoint',
      ];

      bool hasTouristType = types.any((type) => touristTypes.contains(type));

      // ✅ Ưu tiên địa điểm có rating cao và nhiều đánh giá
      bool hasGoodRating = rating >= 3.5 && userRatingsTotal >= 50;

      return (hasTouristKeyword || hasTouristType) && hasGoodRating;
    }).toList();
  }

  // Future<List<Map<String, dynamic>>> searchNearbyPlaces({
  //   required double latitude,
  //   required double longitude,
  //   required double radius,
  //   required String type,
  // }) async {
  //   List<Map<String, dynamic>> allResults = [];
  //   String? nextPageToken;

  //   do {
  //     String url = Uri.parse(
  //       '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&language=vi&key=$apiKey',
  //     ).toString();

  //     if (nextPageToken != null) {
  //       url += '&pagetoken=$nextPageToken';
  //     }

  //     try {
  //       print('    🌐 Gọi Nearby Search API...');
  //       final startTime = DateTime.now();

  //       final response = await http.get(Uri.parse(url));

  //       final endTime = DateTime.now();
  //       final duration = endTime.difference(startTime);
  //       print(
  //           '    ⏱️  Nearby Search response trong ${duration.inMilliseconds}ms');

  //       if (response.statusCode == 200) {
  //         final data = json.decode(response.body);
  //         if (data['status'] == 'OK') {
  //           final results = List<Map<String, dynamic>>.from(data['results']);
  //           allResults.addAll(results);
  //           nextPageToken = data['next_page_token'];

  //           print(
  //               '    ✅ Nearby Search thành công: ${results.length} kết quả (tổng: ${allResults.length})');

  //           // Google yêu cầu delay 2 giây trước khi gọi page tiếp theo
  //           if (nextPageToken != null) {
  //             print('    ⏳ Đợi 2 giây trước khi lấy trang tiếp theo...');
  //             await Future.delayed(Duration(seconds: 2));
  //           }
  //         } else {
  //           print(
  //               '    ❌ Nearby Search failed: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
  //           break;
  //         }
  //       } else {
  //         print('    ❌ Nearby Search HTTP error: ${response.statusCode}');
  //         break;
  //       }
  //     } catch (e) {
  //       print('    ❌ Nearby search error: $e');
  //       break;
  //     }
  //   } while (nextPageToken != null);

  //   return allResults;
  // }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&fields=name,formatted_address,geometry,photos,editorial_summary,reviews,rating,user_ratings_total,types,opening_hours&language=vi&key=$apiKey',
    );

    try {
      print('      🌐 Gọi Place Details VI...');
      final startTime = DateTime.now();

      final response = await http.get(url);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print(
          '      ⏱️  Place Details VI response trong ${duration.inMilliseconds}ms');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          print('      ✅ Place Details VI thành công');
          return data['result'];
        } else {
          print(
              '      ❌ Place Details VI failed: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        print('      ❌ Place Details VI HTTP error: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('      ❌ Place details error: $e');
      return null;
    }
  }

  Future<DestinationModel> _convertToDestinationModelWithDetails(
      Map<String, dynamic> place, String provinceName) async {
    final name = place['name'] ?? '';
    final lat = place['geometry']['location']['lat'] ?? 0.0;
    final lng = place['geometry']['location']['lng'] ?? 0.0;
    final address = place['vicinity'] ?? '';
    final placeId = place['place_id'] ?? '';

    // ✅ Lấy rating từ Nearby Search
    final rating = place['rating']?.toDouble() ?? 0.0;
    final userRatingsTotal = place['user_ratings_total'] ?? 0;

    print(
        '        📍 Xử lý: $name (ID: $placeId) - Rating: $rating ($userRatingsTotal đánh giá)');

    // ✅ Gọi Place Details để lấy thông tin chi tiết
    final placeDetails = await getPlaceDetails(placeId);

    // ✅ Lấy mô tả từ Place Details (editorial_summary)
    String descriptionVi = '';
    String descriptionEn = '';

    if (placeDetails != null) {
      descriptionVi = placeDetails['editorial_summary']?['overview'] ?? '';
      print(
          '        📝 Có mô tả VI: ${descriptionVi.isNotEmpty ? 'Có' : 'Không'}');

      // ✅ Gọi Place Details bằng tiếng Anh để lấy mô tả tiếng Anh
      final placeDetailsEn = await getPlaceDetailsInEnglish(placeId);
      if (placeDetailsEn != null) {
        descriptionEn = placeDetailsEn['editorial_summary']?['overview'] ?? '';
        print(
            '        📝 Có mô tả EN: ${descriptionEn.isNotEmpty ? 'Có' : 'Không'}');
      }
    }

    // ✅ Nếu không có mô tả từ Place Details, fallback về Wikipedia
    if (descriptionVi.isEmpty && descriptionEn.isEmpty) {
      print('        🔄 Fallback về Wikipedia...');
      final descriptions =
          await fetchWikipediaDescription('$name, $provinceName');
      descriptionVi = descriptions['vi'] ?? '';
      descriptionEn = descriptions['en'] ?? '';
      print(
          '        📝 Wikipedia VI: ${descriptionVi.isNotEmpty ? 'Có' : 'Không'}, EN: ${descriptionEn.isNotEmpty ? 'Có' : 'Không'}');
    }

    // ✅ Phân loại categories trước khi quyết định số ảnh
    final categories =
        classifyCategories(name, '$descriptionVi $descriptionEn');
    print('        🏷️  Categories: ${categories.join(', ')}');

    // ✅ Tối ưu số ảnh theo loại địa điểm
    final int photoLimit = _getPhotoLimitByCategories(categories);
    final List<String> photos = place['photos'] != null
        ? (place['photos'] as List)
            .take(photoLimit)
            .map<String>((p) => _getPhotoUrl(p['photo_reference'],
                maxWidth: 1200)) // ✅ Tăng chất lượng ảnh
            .toList()
        : [];

    print('        📸 Số ảnh: ${photos.length} (limit: $photoLimit)');

    return DestinationModel(
      destinationId: '', // ✅ Để trống, sẽ được generate trong _saveToFirebase
      destinationName: name,
      latitude: lat,
      longitude: lng,
      province: provinceName,
      specificAddress: address,
      descriptionEng: descriptionEn,
      descriptionViet: descriptionVi,
      photo: photos,
      video: [],
      createdDate: DateTime.now().toString(),
      favouriteTimes: 0,
      categories: categories,
      rating: rating, // ✅ Thêm rating
      userRatingsTotal: userRatingsTotal, // ✅ Thêm số lượng đánh giá
    );
  }

  Future<Map<String, dynamic>?> getPlaceDetailsInEnglish(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&fields=editorial_summary&language=en&key=$apiKey',
    );

    try {
      print('      🌐 Gọi Place Details EN...');
      final startTime = DateTime.now();

      final response = await http.get(url);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print(
          '      ⏱️  Place Details EN response trong ${duration.inMilliseconds}ms');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          print('      ✅ Place Details EN thành công');
          return data['result'];
        } else {
          print(
              '      ❌ Place Details EN failed: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      } else {
        print('      ❌ Place Details EN HTTP error: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('      ❌ Place details EN error: $e');
      return null;
    }
  }

  int _getPhotoLimitByCategories(List<String> categories) {
    // ✅ 3-5 ảnh cho các loại cần nhiều ảnh
    final highPhotoCategories = [
      'Biển',
      'Núi',
      'Thiên nhiên',
      'Giải trí',
      'Công trình'
    ];

    // ✅ 1 ảnh cho các loại ít cần ảnh
    final lowPhotoCategories = ['Lịch sử', 'Văn hóa'];

    for (final category in categories) {
      if (highPhotoCategories.contains(category)) {
        return 3; // Lấy 5 ảnh
      }
      if (lowPhotoCategories.contains(category)) {
        return 1; // Chỉ lấy 1 ảnh
      }
    }

    return 3; // Mặc định 3 ảnh cho các loại khác
  }

  String _getPhotoUrl(String photoReference, {int maxWidth = 1200}) {
    // ✅ Tăng chất lượng ảnh
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }

  Future<Map<String, String>> fetchWikipediaDescription(String query) async {
    if (_wikiCache.containsKey(query)) return _wikiCache[query]!;

    Future<String?> getDesc(String lang) async {
      final titleRes = await http.get(Uri.parse(
          'https://$lang.wikipedia.org/w/rest.php/v1/search/page?q=${Uri.encodeComponent(query)}&limit=1'));
      if (titleRes.statusCode != 200) return null;

      final titleData = jsonDecode(titleRes.body);
      if (titleData['pages'] == null || titleData['pages'].isEmpty) return null;

      final title = titleData['pages'][0]['title'];
      final summaryRes = await http.get(Uri.parse(
          'https://$lang.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}'));
      if (summaryRes.statusCode != 200) return null;

      final summaryData = jsonDecode(summaryRes.body);
      return summaryData['extract'];
    }

    final vi = await getDesc('vi');
    final en = vi == null ? await getDesc('en') : null;

    final result = {'vi': vi ?? '', 'en': en ?? ''};
    _wikiCache[query] = result;
    return result;
  }

  List<String> classifyCategories(String name, String description) {
    final text = (name + ' ' + description).toLowerCase();
    final Map<String, List<String>> categoryKeywords = {
      'Biển': [
        'biển',
        'vịnh',
        'cù lao',
        'bãi biển',
        'vịnh hạ long',
        'phú quốc',
        'nha trang',
        'mỹ khê',
        'non nước',
        'bãi tắm'
      ],
      'Núi': [
        'núi',
        'đèo',
        'đỉnh',
        'thung lũng',
        'ruộng bậc thang',
        'sapa',
        'fansipan',
        'bà nà',
        'langbiang',
        'hải vân',
        'ngũ hành sơn'
      ],
      'Lịch sử': [
        'di tích',
        'chùa',
        'đền',
        'cổ',
        'lăng',
        'thành cổ',
        'cố đô',
        'kinh thành',
        'dinh độc lập',
        'cầu vàng',
        'cầu rồng'
      ],
      'Văn hóa': ['văn hóa', 'bảo tàng', 'chợ', 'làng nghề', 'phố cổ'],
      'Thiên nhiên': [
        'hang',
        'rừng',
        'thác',
        'suối',
        'hồ',
        'vườn quốc gia',
        'khu bảo tồn',
        'sở thú'
      ],
      'Giải trí': [
        'vinwonders',
        'đầm sen',
        'suối tiên',
        'công viên nước',
        'sun world',
        'khu du lịch',
        'phố đi bộ',
        'công viên',
        'vui chơi',
        'bà nà hills'
      ],
      'Công trình': [
        'bitexco',
        'landmark',
        'tòa nhà',
        'cầu',
        'kinh thành',
        'tháp',
        'tượng đài',
        'cầu vàng',
        'cầu rồng',
        'cầu sông hàn'
      ]
    };

    final matchedCategories = <String>[];
    categoryKeywords.forEach((category, keywords) {
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          matchedCategories.add(category);
          break;
        }
      }
    });
    return matchedCategories.toSet().toList();
  }

  Future<void> _saveToFirebase(
      DestinationModel destination, String placeId) async {
    try {
      // ✅ Generate ID theo format D00001
      final newId = await _generateDestinationId();
      final newDestination = destination.copyWith(destinationId: newId);
      await _firestore.collection('DESTINATION').doc(newId).set({
        ...newDestination.toMap(),
        'place_id': placeId, // ✅ Lưu place_id để check trùng sau
      });
    } catch (e) {
      print('❌ Error saving destination: $e');
    }
  }

  Future<String> _generateDestinationId() async {
    try {
      final snapshot = await _firestore
          .collection('DESTINATION')
          .orderBy('destinationId', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 'D00001';
      final lastId = snapshot.docs.first['destinationId'] as String;
      final number = int.parse(lastId.substring(1)) + 1;
      return 'D${number.toString().padLeft(5, '0')}';
    } catch (e) {
      return 'D${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  Future<List<Map<String, dynamic>>> searchByText(
      String query, double lat, double lng,
      {double radius = 50000}) async {
    List<Map<String, dynamic>> allResults = [];
    String? nextPageToken;

    do {
      String url = Uri.parse(
              '$_baseUrl/textsearch/json?query=$query&location=$lat,$lng&radius=$radius&language=vi&key=$apiKey')
          .toString();

      if (nextPageToken != null) {
        url += '&pagetoken=$nextPageToken';
      }

      try {
        print('    🌐 Gọi Text Search API với query: "$query"...');
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

            print(
                '    ✅ Text Search thành công: ${results.length} kết quả (tổng: ${allResults.length})');

            // Google yêu cầu delay 2 giây trước khi gọi page tiếp theo
            if (nextPageToken != null) {
              print('    ⏳ Đợi 2 giây trước khi lấy trang tiếp theo...');
              await Future.delayed(Duration(seconds: 2));
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
}
