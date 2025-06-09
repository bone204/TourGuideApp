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

  // Tọa độ các thành phố lớn ở Việt Nam
  final List<Map<String, dynamic>> vietnamCities = [
    {'name': 'Hà Nội', 'lat': 21.0285, 'lng': 105.8542},
    {'name': 'Hồ Chí Minh', 'lat': 10.7757, 'lng': 106.7004},
    {'name': 'Đà Nẵng', 'lat': 16.0544, 'lng': 108.2022},
    {'name': 'Hải Phòng', 'lat': 20.8449, 'lng': 106.6880},
    {'name': 'Cần Thơ', 'lat': 10.0452, 'lng': 105.7469},
    {'name': 'Huế', 'lat': 16.4619, 'lng': 107.5909},
    {'name': 'Nha Trang', 'lat': 12.2388, 'lng': 109.1967},
    {'name': 'Đà Lạt', 'lat': 11.9404, 'lng': 108.4587},
  ];

  Future<void> importPlacesToFirebase() async {
    for (var city in vietnamCities) {
      await _importPlacesForCity(
        city['name'],
        city['lat'],
        city['lng'],
      );
    }
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

      for (var place in places) {
        try {
          // Lấy thông tin chi tiết của địa điểm
          final details = await _getPlaceDetails(place['place_id']);
          if (details != null) {
            // Chuyển đổi dữ liệu sang DestinationModel
            final destination = _convertToDestinationModel(details, cityName);
            
            // Lưu vào Firebase
            await _saveToFirebase(destination);
          }
        } catch (e) {
          print('Error processing place ${place['place_id']}: $e');
          continue; // Tiếp tục với địa điểm tiếp theo nếu có lỗi
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

  DestinationModel _convertToDestinationModel(
    Map<String, dynamic> placeDetails,
    String cityName,
  ) {
    // Lấy địa chỉ và tách thành các phần
    final addressParts = (placeDetails['formatted_address'] as String?)?.split(',') ?? [];
    final province = addressParts.length > 1 ? addressParts[addressParts.length - 2].trim() : cityName;
    final district = addressParts.length > 2 ? addressParts[addressParts.length - 3].trim() : '';
    final specificAddress = addressParts.length > 3 ? addressParts[0].trim() : '';

    // Lấy danh sách ảnh
    final photos = (placeDetails['photos'] as List<dynamic>?)
        ?.map((photo) => _getPhotoUrl(photo['photo_reference'] as String))
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

    return DestinationModel(
      destinationId: '', // ID sẽ được tạo khi lưu vào Firestore
      destinationName: placeDetails['name'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      province: province,
      district: district,
      specificAddress: specificAddress,
      descriptionEng: description,
      descriptionViet: description, // Có thể thêm dịch sau
      photo: photos,
      video: [], // Places API không cung cấp video
      createdDate: DateTime.now().toString(),
      favouriteTimes: (placeDetails['user_ratings_total'] as num?)?.toInt() ?? 0,
      categories: List<String>.from(placeDetails['types'] ?? []),
    );
  }

  String _getPhotoUrl(String photoReference, {int maxWidth = 800}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }
} 