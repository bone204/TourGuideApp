import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/destination_model.dart';

class PlacesImportService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey;
  final FirebaseFirestore _firestore;

  PlacesImportService({
    required this.apiKey,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final Map<String, List<String>> categoryKeywords = {
    'Biển': ['biển', 'bãi biển', 'vịnh', 'cù lao', 'hòn'],
    'Núi': ['núi', 'tam đảo', 'đèo', 'đỉnh', 'cao nguyên', 'cao tốc'],
    'Lịch sử': [
      'di tích',
      'thành',
      'chùa',
      'đền',
      'cổ',
      'lăng',
      'quốc tử giám'
    ],
    'Văn hóa': ['văn hóa', 'nhà hát', 'bảo tàng', 'làng nghề', 'truyền thống'],
    'Thiên nhiên': ['hang', 'rừng', 'thác', 'suối', 'hồ', 'công viên quốc gia'],
    'Giải trí': [
      'vinwonders',
      'sun world',
      'công viên',
      'trò chơi',
      'khu du lịch'
    ],
    'Công trình': [
      'bitexco',
      'landmark',
      'tòa nhà',
      'kiến trúc',
      'cầu',
      'tháp'
    ],
  };

  // Danh sách các tỉnh/thành phố chính thức của Việt Nam
  final List<Map<String, dynamic>> vietnamProvinces = [
    {
      'name': 'Hà Nội',
      'lat': 21.0285,
      'lng': 105.8542,
      'limit': 100,
      'radius': 25000.0
    },
    {
      'name': 'Hồ Chí Minh',
      'lat': 10.7769,
      'lng': 106.7009,
      'limit': 100,
      'radius': 25000.0
    },
    {
      'name': 'Hải Phòng',
      'lat': 20.8449,
      'lng': 106.6881,
      'limit': 60,
      'radius': 25000.0
    },
    {
      'name': 'Đà Nẵng',
      'lat': 16.0544,
      'lng': 108.2022,
      'limit': 80,
      'radius': 20000.0
    },
    {
      'name': 'Cần Thơ',
      'lat': 10.0452,
      'lng': 105.7469,
      'limit': 60,
      'radius': 15000.0
    },
    {
      'name': 'An Giang',
      'lat': 10.5216,
      'lng': 105.1259,
      'limit': 20,
      'radius': 10000.0
    },
    {
      'name': 'Bà Rịa - Vũng Tàu',
      'lat': 10.5417,
      'lng': 107.2428,
      'limit': 100,
      'radius': 20000.0
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
      'limit': 10,
      'radius': 10000.0
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
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Bình Dương',
      'lat': 11.3254,
      'lng': 106.4770,
      'limit': 10,
      'radius': 10000.0
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
      'limit': 20,
      'radius': 10000.0
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
      'limit': 10,
      'radius': 10000.0
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
      'limit': 20,
      'radius': 10000.0
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
      'limit': 10,
      'radius': 10000.0
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
      'limit': 10,
      'radius': 10000.0
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
      'radius': 20000.0
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
      'radius': 10000.0
    },
    {
      'name': 'Lạng Sơn',
      'lat': 21.8455,
      'lng': 106.7615,
      'limit': 10,
      'radius': 10000.0
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
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Nam Định',
      'lat': 20.4389,
      'lng': 106.1621,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Nghệ An',
      'lat': 19.2342,
      'lng': 104.9200,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Ninh Bình',
      'lat': 20.2500,
      'lng': 105.9740,
      'limit': 20,
      'radius': 10000.0
    },
    {
      'name': 'Ninh Thuận',
      'lat': 11.5647,
      'lng': 108.9886,
      'limit': 20,
      'radius': 10000.0
    },
    {
      'name': 'Phú Thọ',
      'lat': 21.2840,
      'lng': 105.1951,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Phú Yên',
      'lat': 13.0882,
      'lng': 109.0929,
      'limit': 20,
      'radius': 10000.0
    },
    {
      'name': 'Quảng Bình',
      'lat': 17.6103,
      'lng': 106.3487,
      'limit': 20,
      'radius': 10000.0
    },
    {
      'name': 'Quảng Nam',
      'lat': 15.5393,
      'lng': 108.0191,
      'limit': 30,
      'radius': 20000.0
    },
    {
      'name': 'Quảng Ngãi',
      'lat': 15.1200,
      'lng': 108.8000,
      'limit': 20,
      'radius': 10000.0
    },
    {
      'name': 'Quảng Ninh',
      'lat': 21.1170,
      'lng': 107.2925,
      'limit': 50,
      'radius': 10000.0
    },
    {
      'name': 'Quảng Trị',
      'lat': 16.7500,
      'lng': 107.2000,
      'limit': 10,
      'radius': 10000.0
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
      'radius': 10000.0
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
      'radius': 10000.0
    },
    {
      'name': 'Thanh Hóa',
      'lat': 19.8079,
      'lng': 105.7764,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Thừa Thiên Huế',
      'lat': 16.4637,
      'lng': 107.5909,
      'limit': 50,
      'radius': 10000.0
    },
    {
      'name': 'Tiền Giang',
      'lat': 10.4494,
      'lng': 106.3420,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Trà Vinh',
      'lat': 9.8127,
      'lng': 106.2993,
      'limit': 10,
      'radius': 10000.0
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
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Vĩnh Phúc',
      'lat': 21.3082,
      'lng': 105.6049,
      'limit': 10,
      'radius': 10000.0
    },
    {
      'name': 'Yên Bái',
      'lat': 21.7000,
      'lng': 104.8667,
      'limit': 10,
      'radius': 10000.0
    },
  ];

  // int getPlaceLimitForProvince(String provinceName) {
  //   const majorCities = ['Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Hải Phòng', 'Cần Thơ'];

  //   if (majorCities.contains(provinceName)) {
  //     return 100;
  //   }

  //   // Các tỉnh du lịch nổi bật
  //   const popularProvinces = [
  //     'Khánh Hòa', 'Quảng Ninh', 'Lâm Đồng', 'Quảng Nam', 'Thừa Thiên Huế',
  //     'Bình Định', 'Phú Yên', 'Ninh Bình', 'Thanh Hóa', 'Kiên Giang'
  //   ];

  //   if (popularProvinces.contains(provinceName)) {
  //     return 30 + (provinceName.length % 20); // Random hóa nhẹ
  //   }

  //   return 10; // Tỉnh ít nổi bật hơn
  // }

  List<String> classifyCategories(String name, String description) {
    final text = (name + ' ' + description).toLowerCase();
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

  Future<void> importPlacesToFirebase() async {
    for (final province in vietnamProvinces) {
      await _importPlacesForCity(
        province['name'],
        province['lat'],
        province['lng'],
        province['limit'], // truyền giới hạn
        (province['radius'] as num).toDouble(), // bán kính
      );
      await Future.delayed(
          Duration(seconds: 1)); // nghỉ giữa các tỉnh để tránh quota
    }
  }

  Future<void> _importPlacesForCity(
    String cityName,
    double latitude,
    double longitude,
    int limit,
    double radius,
  ) async {
    try {
      // Tìm kiếm các địa điểm du lịch trong bán kính 10km
      final places = await searchNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: 'tourist_attraction',
      );

      // Giới hạn chỉ lấy limit địa điểm đầu tiên
      final limitedPlaces = places.take(limit).toList();

      for (var place in limitedPlaces) {
        try {
          // Kiểm tra xem địa điểm đã tồn tại chưa
          final existingPlace = await _firestore
              .collection('DESTINATION')
              .where('destinationName', isEqualTo: place['name'])
              .where('province', isEqualTo: cityName)
              .get();

          // Nếu địa điểm chưa tồn tại, tiến hành import
          if (existingPlace.docs.isEmpty) {
            // Lấy thông tin chi tiết của địa điểm
            final details = await _getPlaceDetails(place['place_id']);
            if (details != null) {
              // Chuyển đổi dữ liệu sang DestinationModel
              final destination =
                  await _convertToDestinationModel(details, cityName);

              // Lưu vào Firebase
              await _saveToFirebase(destination);
              print('Đã import địa điểm: ${destination.destinationName}');
            }
          } else {
            print('Địa điểm đã tồn tại: ${place['name']}');
          }
        } catch (e) {
          print('Error processing place ${place['place_id']}: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error importing places for $cityName: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radius,
    required String type,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&language=vi&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        }
      }
      return [];
    } catch (e) {
      print('Error searching nearby places: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&fields=name,geometry,formatted_address,photos,rating,user_ratings_total,types,vicinity,opening_hours,reviews&language=vi&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  Future<String> _generateDestinationId() async {
    try {
      final snapshot = await _firestore
          .collection('DESTINATION')
          .orderBy('destinationId', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 'D00001';
      }

      final lastId = snapshot.docs.first['destinationId'] as String;
      final lastNumber = int.parse(lastId.substring(1));
      final newNumber = lastNumber + 1;
      return 'D${newNumber.toString().padLeft(5, '0')}';
    } catch (e) {
      print('Error generating destination ID: $e');
      // Nếu có lỗi, tạo ID dựa trên timestamp
      return 'D${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  /// Tìm tên trang Wikipedia khớp nhất theo ngôn ngữ
  Future<String?> searchWikipediaTitle(String query, String lang) async {
    final url =
        'https://$lang.wikipedia.org/w/rest.php/v1/search/page?q=${Uri.encodeComponent(query)}&limit=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['pages'] != null && data['pages'].isNotEmpty) {
        return data['pages'][0]['title']; // Tên chính xác của trang
      }
    }

    return null;
  }

  /// Hàm chính để lấy mô tả từ Wikipedia bằng cả tiếng Việt và tiếng Anh
  Future<Map<String, String>> fetchWikipediaDescription(String query) async {
    String? viTitle = await searchWikipediaTitle(query, 'vi');
    String? enTitle = await searchWikipediaTitle(query, 'en');

    String? viDesc;
    String? enDesc;

    if (viTitle != null) {
      final responseVi = await http.get(Uri.parse(
        'https://vi.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(viTitle)}',
      ));
      if (responseVi.statusCode == 200) {
        final data = jsonDecode(responseVi.body);
        viDesc = data['extract'];
      }
    }

    if (enTitle != null) {
      final responseEn = await http.get(Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(enTitle)}',
      ));
      if (responseEn.statusCode == 200) {
        final data = jsonDecode(responseEn.body);
        enDesc = data['extract'];
      }
    }

    return {
      'vi': viDesc ?? '',
      'en': enDesc ?? '',
    };
  }

  Future<void> _saveToFirebase(DestinationModel destination) async {
    try {
      // Tạo ID mới
      final newId = await _generateDestinationId();

      // Tạo destination mới với ID mới
      final newDestination = DestinationModel(
        destinationId: newId,
        destinationName: destination.destinationName,
        latitude: destination.latitude,
        longitude: destination.longitude,
        province: destination.province,
        specificAddress: destination.specificAddress,
        descriptionEng: destination.descriptionEng,
        descriptionViet: destination.descriptionViet,
        photo: destination.photo,
        video: destination.video,
        createdDate: destination.createdDate,
        favouriteTimes: destination.favouriteTimes,
        categories: destination.categories,
      );

      await _firestore
          .collection('DESTINATION')
          .doc(newDestination.destinationId)
          .set(newDestination.toMap());
    } catch (e) {
      print('Error saving to Firebase: $e');
    }
  }

  String _getPhotoUrl(String photoReference, {int maxWidth = 800}) {
    // Đảm bảo photoReference không rỗng
    if (photoReference.isEmpty) {
      return '';
    }

    // Tạo URL đầy đủ cho ảnh
    final photoUrl =
        '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
    return photoUrl;
  }

  String _cleanAddress(String address) {
    // Chỉ xóa các ký tự đặc biệt không cần thiết
    return address
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s,.-]', unicode: true), '')
        .trim();
  }

  Future<DestinationModel> _convertToDestinationModel(
    Map<String, dynamic> placeDetails,
    String provinceName,
  ) async {
    final addressParts =
        (placeDetails['formatted_address'] as String?)?.split(',') ?? [];

    // Giữ nguyên địa chỉ gốc, chỉ làm sạch các ký tự đặc biệt
    String specificAddress = addressParts
        .take(addressParts.length - 1)
        .map(_cleanAddress)
        .join(', ')
        .trim();

    // Lấy danh sách ảnh
    final photos =
        await _processPhotos(placeDetails['photos'] as List<dynamic>?);

    // Lấy mô tả từ Wikipedia
    final name = placeDetails['name'] as String? ?? '';
    final descriptions = await fetchWikipediaDescription(name);
    final descriptionVi = descriptions['vi'] ?? '';
    final descriptionEn = descriptions['en'] ?? '';

    // Phân loại
    final categories =
        classifyCategories(name, descriptionVi + ' ' + descriptionEn);

    // Tọa độ
    final geometry = placeDetails['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = location?['lat'] as double? ?? 0.0;
    final lng = location?['lng'] as double? ?? 0.0;

    // Làm sạch tên tỉnh
    String normalizedProvince =
        provinceName.replaceAll(RegExp(r'\d+'), '').trim();

    return DestinationModel(
      destinationId: '',
      destinationName: name,
      latitude: lat,
      longitude: lng,
      province: normalizedProvince,
      specificAddress: specificAddress,
      descriptionEng: descriptionEn,
      descriptionViet: descriptionVi,
      photo: photos,
      video: [],
      createdDate: DateTime.now().toString(),
      favouriteTimes: 0,
      categories: categories,
    );
  }

  Future<List<String>> _processPhotos(List<dynamic>? photos) async {
    if (photos == null || photos.isEmpty) return [];

    final processedPhotos = <String>[];
    for (var photo in photos) {
      try {
        final photoRef = photo['photo_reference'] as String?;
        if (photoRef != null) {
          // Tạo URL với kích thước phù hợp
          final photoUrl = _getPhotoUrl(photoRef, maxWidth: 1200);

          // Kiểm tra URL hợp lệ
          final response = await http.head(Uri.parse(photoUrl));
          if (response.statusCode == 200) {
            processedPhotos.add(photoUrl);
          }
        }
      } catch (e) {
        print('Error processing photo: $e');
      }
    }

    // Giới hạn số lượng ảnh để tránh quá tải
    return processedPhotos.take(5).toList();
  }
}
