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

  // Danh sách các tỉnh/thành phố chính thức của Việt Nam
  final List<Map<String, dynamic>> vietnamProvinces = [
    {'name': 'Hà Nội', 'lat': 21.0285, 'lng': 105.8542},
    {'name': 'Hồ Chí Minh', 'lat': 10.7757, 'lng': 106.7004},
    {'name': 'Đà Nẵng', 'lat': 16.0544, 'lng': 108.2022},
    {'name': 'Hải Phòng', 'lat': 20.8449, 'lng': 106.6880},
    {'name': 'Cần Thơ', 'lat': 10.0452, 'lng': 105.7469},
    {'name': 'Thừa Thiên Huế', 'lat': 16.4619, 'lng': 107.5909},
    {'name': 'Khánh Hòa', 'lat': 12.2388, 'lng': 109.1967},
    {'name': 'Lâm Đồng', 'lat': 11.9404, 'lng': 108.4587},
    {'name': 'Quảng Ninh', 'lat': 21.0064, 'lng': 107.2925},
    {'name': 'Bình Định', 'lat': 13.7754, 'lng': 109.2237},
    {'name': 'Quảng Nam', 'lat': 15.8801, 'lng': 108.3380},
    {'name': 'Bình Thuận', 'lat': 10.9289, 'lng': 108.1021},
    {'name': 'Ninh Thuận', 'lat': 11.5647, 'lng': 108.9886},
    {'name': 'Phú Yên', 'lat': 13.1056, 'lng': 109.2924},
    {'name': 'Bình Dương', 'lat': 11.3254, 'lng': 106.4770},
    {'name': 'Đồng Nai', 'lat': 10.9574, 'lng': 106.8426},
    {'name': 'Bà Rịa - Vũng Tàu', 'lat': 10.4114, 'lng': 107.1362},
    {'name': 'Long An', 'lat': 10.5333, 'lng': 106.4131},
    {'name': 'Tiền Giang', 'lat': 10.3600, 'lng': 106.3600},
    {'name': 'Bến Tre', 'lat': 10.2333, 'lng': 106.3833},
    {'name': 'Vĩnh Long', 'lat': 10.2500, 'lng': 105.9667},
    {'name': 'Đồng Tháp', 'lat': 10.3333, 'lng': 105.6333},
    {'name': 'An Giang', 'lat': 10.3833, 'lng': 105.4333},
    {'name': 'Kiên Giang', 'lat': 10.0167, 'lng': 105.0833},
    {'name': 'Cà Mau', 'lat': 9.1833, 'lng': 105.1500},
    {'name': 'Bạc Liêu', 'lat': 9.2833, 'lng': 105.7167},
    {'name': 'Sóc Trăng', 'lat': 9.6000, 'lng': 105.9667},
    {'name': 'Trà Vinh', 'lat': 9.9333, 'lng': 106.3333},
    {'name': 'Hậu Giang', 'lat': 9.7833, 'lng': 105.4667},
    {'name': 'Bình Phước', 'lat': 11.7500, 'lng': 106.6000},
    {'name': 'Tây Ninh', 'lat': 11.3667, 'lng': 106.1167},
    {'name': 'Bình Phước', 'lat': 11.7500, 'lng': 106.6000},
    {'name': 'Bình Thuận', 'lat': 10.9289, 'lng': 108.1021},
    {'name': 'Ninh Thuận', 'lat': 11.5647, 'lng': 108.9886},
    {'name': 'Kon Tum', 'lat': 14.3500, 'lng': 108.0000},
    {'name': 'Gia Lai', 'lat': 13.9833, 'lng': 108.0000},
    {'name': 'Đắk Lắk', 'lat': 12.6667, 'lng': 108.0500},
    {'name': 'Đắk Nông', 'lat': 12.0000, 'lng': 107.6833},
    {'name': 'Lâm Đồng', 'lat': 11.9404, 'lng': 108.4587},
  ];

  Future<void> importPlacesToFirebase() async {
    // Chỉ lấy tỉnh/thành phố đầu tiên để test
    final testProvince = vietnamProvinces.first;
    await _importPlacesForCity(
      testProvince['name'],
      testProvince['lat'],
      testProvince['lng'],
    );
  }

  Future<void> _importPlacesForCity(
    String cityName,
    double latitude,
    double longitude,
  ) async {
    try {
      // Tìm kiếm các địa điểm du lịch trong bán kính 10km
      final places = await searchNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radius: 10000,
        type: 'tourist_attraction',
      );

      // // Giới hạn chỉ lấy 5 địa điểm đầu tiên
      // final limitedPlaces = places.take(5).toList();

      for (var place in places) {
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
              final destination = _convertToDestinationModel(details, cityName);
              
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
      '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$apiKey',
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
      '$_baseUrl/details/json?place_id=$placeId&fields=name,geometry,formatted_address,photos,rating,user_ratings_total,types,vicinity,opening_hours,reviews&key=$apiKey',
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
        district: destination.district,
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
    final photoUrl = '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
    return photoUrl;
  }

  DestinationModel _convertToDestinationModel(
    Map<String, dynamic> placeDetails,
    String provinceName,
  ) {
    // Lấy địa chỉ và tách thành các phần
    final addressParts = (placeDetails['formatted_address'] as String?)?.split(',') ?? [];
    
    // Xác định quận/huyện
    String district = '';
    for (var part in addressParts) {
      part = part.trim();
      // Loại bỏ các số và ký tự đặc biệt không cần thiết
      part = part.replaceAll(RegExp(r'\d+'), '').trim();
      if (part.contains('District') || part.contains('Quận') || part.contains('Huyện')) {
        district = part;
        break;
      }
    }

    // Xác định địa chỉ cụ thể
    String specificAddress = '';
    if (addressParts.isNotEmpty) {
      specificAddress = addressParts[0].trim();
      // Loại bỏ các số và ký tự đặc biệt không cần thiết từ địa chỉ cụ thể
      specificAddress = specificAddress.replaceAll(RegExp(r'\d+'), '').trim();
    }

    // Lấy danh sách ảnh và xử lý URL
    final photos = (placeDetails['photos'] as List<dynamic>?)
        ?.map((photo) {
          final photoRef = photo['photo_reference'] as String?;
          return photoRef != null ? _getPhotoUrl(photoRef) : '';
        })
        .where((url) => url.isNotEmpty) // Chỉ lấy các URL hợp lệ
        .toList() ?? [];

    // Tạo mô tả từ reviews
    String description = '';
    if (placeDetails['reviews'] != null) {
      final reviews = placeDetails['reviews'] as List<dynamic>;
      if (reviews.isNotEmpty) {
        description = reviews[0]['text'] as String? ?? '';
      }
    }

    // Lấy tọa độ
    final geometry = placeDetails['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final lat = location?['lat'] as double? ?? 0.0;
    final lng = location?['lng'] as double? ?? 0.0;

    // Chuẩn hóa tên tỉnh/thành phố
    String normalizedProvince = provinceName;
    // Loại bỏ các số và ký tự đặc biệt không cần thiết
    normalizedProvince = normalizedProvince.replaceAll(RegExp(r'\d+'), '').trim();

    return DestinationModel(
      destinationId: '',
      destinationName: placeDetails['name'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      province: normalizedProvince,
      district: district,
      specificAddress: specificAddress,
      descriptionEng: description,
      descriptionViet: description,
      photo: photos,
      video: [],
      createdDate: DateTime.now().toString(),
      favouriteTimes: 0,
      categories: []
    );
  }
} 