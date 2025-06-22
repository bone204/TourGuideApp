import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class PhotoDownloadService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _apiKey;

  PhotoDownloadService({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required String apiKey,
  })  : _firestore = firestore,
        _storage = storage,
        _apiKey = apiKey;

  /// Download ảnh từ Google Places API và upload lên Firebase Storage
  Future<String> downloadAndUploadPhoto(String photoReference, {
    int maxWidth = 1200,
    String? customFileName,
  }) async {
    try {
      // Tạo URL để download ảnh từ Google Places API
      final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
      
      // Download ảnh
      final response = await http.get(Uri.parse(photoUrl));
      if (response.statusCode != 200) {
        throw Exception('Không thể download ảnh: ${response.statusCode}');
      }

      // Tạo tên file
      final fileName = customFileName ?? 'photo_${DateTime.now().millisecondsSinceEpoch}_${photoReference.substring(0, 10)}.jpg';
      final storageRef = _storage.ref().child('places_photos/$fileName');

      // Upload lên Firebase Storage
      final uploadTask = storageRef.putData(
        response.bodyBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Lỗi khi download và upload ảnh: $e');
    }
  }

  /// Download nhiều ảnh từ danh sách photo_reference
  Future<List<String>> downloadMultiplePhotos(List<String> photoReferences, {
    int maxWidth = 1200,
    String? prefix,
  }) async {
    List<String> uploadedUrls = [];
    
    for (int i = 0; i < photoReferences.length; i++) {
      try {
        final photoRef = photoReferences[i];
        final fileName = prefix != null ? '${prefix}_$i.jpg' : null;
        
        final url = await downloadAndUploadPhoto(
          photoRef,
          maxWidth: maxWidth,
          customFileName: fileName,
        );
        
        uploadedUrls.add(url);
      } catch (e) {
        print('Lỗi download ảnh thứ $i: $e');
        // Bỏ qua ảnh lỗi và tiếp tục
      }
    }
    
    return uploadedUrls;
  }

  /// Tạo URL Google Places API (để sử dụng khi không muốn download)
  String createGooglePlacesUrl(String photoReference, {int maxWidth = 1200}) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  /// Cập nhật tất cả ảnh trong collection DESTINATION
  Future<Map<String, int>> updateDestinationPhotos({
    required Function(String) onProgress,
    int maxWidth = 1200,
  }) async {
    int totalUpdated = 0;
    int totalDocuments = 0;
    int errorCount = 0;

    try {
      onProgress('Đang lấy danh sách địa điểm...');
      
      final querySnapshot = await _firestore.collection('DESTINATION').get();
      totalDocuments = querySnapshot.docs.length;
      
      onProgress('Tìm thấy $totalDocuments địa điểm. Bắt đầu download và upload ảnh...');

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final data = doc.data();
        
        if (data['photo'] != null && data['photo'] is List) {
          final List<String> photos = List<String>.from(data['photo']);
          List<String> newPhotos = [];
          bool hasChanges = false;
          
          for (int j = 0; j < photos.length; j++) {
            final photoUrl = photos[j];
            
            // Kiểm tra xem có phải URL Google Places API không
            if (photoUrl.contains('maps.googleapis.com') && photoUrl.contains('photo_reference=')) {
              try {
                // Extract photo_reference từ URL
                final photoRef = _extractPhotoReference(photoUrl);
                if (photoRef != null) {
                  onProgress('Đang xử lý ảnh ${j + 1}/${photos.length} của ${data['destinationName'] ?? 'Unknown'}...');
                  
                  final newPhotoUrl = await downloadAndUploadPhoto(
                    photoRef,
                    maxWidth: maxWidth,
                    customFileName: '${data['destinationId'] ?? 'dest'}_${i}_$j.jpg',
                  );
                  
                  newPhotos.add(newPhotoUrl);
                  hasChanges = true;
                } else {
                  newPhotos.add(photoUrl); // Giữ nguyên nếu không extract được
                }
              } catch (e) {
                errorCount++;
                onProgress('Lỗi xử lý ảnh ${data['destinationName'] ?? 'Unknown'}: $e');
                newPhotos.add(photoUrl); // Giữ nguyên URL cũ nếu có lỗi
              }
            } else {
              newPhotos.add(photoUrl); // Giữ nguyên nếu không phải Google Places URL
            }
          }
          
          if (hasChanges) {
            try {
              await doc.reference.update({'photo': newPhotos});
              totalUpdated++;
              onProgress('Đã cập nhật ${i + 1}/$totalDocuments: ${data['destinationName'] ?? 'Unknown'}');
            } catch (e) {
              errorCount++;
              onProgress('Lỗi cập nhật ${data['destinationName'] ?? 'Unknown'}: $e');
            }
          }
        }
      }
      
      onProgress('Hoàn tất cập nhật DESTINATION: $totalUpdated/$totalDocuments đã cập nhật, $errorCount lỗi');
      
    } catch (e) {
      onProgress('Lỗi khi cập nhật DESTINATION: $e');
    }

    return {
      'totalDocuments': totalDocuments,
      'totalUpdated': totalUpdated,
      'errorCount': errorCount,
    };
  }

  /// Cập nhật tất cả ảnh trong collection COOPERATION
  Future<Map<String, int>> updateCooperationPhotos({
    required Function(String) onProgress,
    int maxWidth = 1200,
  }) async {
    int totalUpdated = 0;
    int totalDocuments = 0;
    int errorCount = 0;

    try {
      onProgress('Đang lấy danh sách khách sạn/nhà hàng...');
      
      final querySnapshot = await _firestore.collection('COOPERATION').get();
      totalDocuments = querySnapshot.docs.length;
      
      onProgress('Tìm thấy $totalDocuments khách sạn/nhà hàng. Bắt đầu download và upload ảnh...');

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final data = doc.data();
        
        if (data['photo'] != null && data['photo'] is String) {
          final photoUrl = data['photo'];
          
          // Kiểm tra xem có phải URL Google Places API không
          if (photoUrl.contains('maps.googleapis.com') && photoUrl.contains('photo_reference=')) {
            try {
              // Extract photo_reference từ URL
              final photoRef = _extractPhotoReference(photoUrl);
              if (photoRef != null) {
                onProgress('Đang xử lý ảnh của ${data['name'] ?? 'Unknown'}...');
                
                final newPhotoUrl = await downloadAndUploadPhoto(
                  photoRef,
                  maxWidth: maxWidth,
                  customFileName: '${data['cooperationId'] ?? 'coop'}_${i}.jpg',
                );
                
                try {
                  await doc.reference.update({'photo': newPhotoUrl});
                  totalUpdated++;
                  onProgress('Đã cập nhật ${i + 1}/$totalDocuments: ${data['name'] ?? 'Unknown'}');
                } catch (e) {
                  errorCount++;
                  onProgress('Lỗi cập nhật ${data['name'] ?? 'Unknown'}: $e');
                }
              }
            } catch (e) {
              errorCount++;
              onProgress('Lỗi xử lý ảnh ${data['name'] ?? 'Unknown'}: $e');
            }
          }
        }
      }
      
      onProgress('Hoàn tất cập nhật COOPERATION: $totalUpdated/$totalDocuments đã cập nhật, $errorCount lỗi');
      
    } catch (e) {
      onProgress('Lỗi khi cập nhật COOPERATION: $e');
    }

    return {
      'totalDocuments': totalDocuments,
      'totalUpdated': totalUpdated,
      'errorCount': errorCount,
    };
  }

  /// Cập nhật tất cả ảnh trong tất cả collections
  Future<Map<String, dynamic>> updateAllPhotos({
    required Function(String) onProgress,
    int maxWidth = 1200,
  }) async {
    onProgress('Bắt đầu download và upload tất cả ảnh...');
    
    final destinationResult = await updateDestinationPhotos(
      onProgress: onProgress,
      maxWidth: maxWidth,
    );
    final cooperationResult = await updateCooperationPhotos(
      onProgress: onProgress,
      maxWidth: maxWidth,
    );
    
    final totalDocuments = destinationResult['totalDocuments']! + cooperationResult['totalDocuments']!;
    final totalUpdated = destinationResult['totalUpdated']! + cooperationResult['totalUpdated']!;
    final totalErrors = destinationResult['errorCount']! + cooperationResult['errorCount']!;
    
    onProgress('Hoàn tất cập nhật tất cả: $totalUpdated/$totalDocuments đã cập nhật, $totalErrors lỗi');
    
    return {
      'destination': destinationResult,
      'cooperation': cooperationResult,
      'total': {
        'totalDocuments': totalDocuments,
        'totalUpdated': totalUpdated,
        'errorCount': totalErrors,
      }
    };
  }

  /// Extract photo_reference từ Google Places API URL
  String? _extractPhotoReference(String url) {
    try {
      final uri = Uri.parse(url);
      final photoRef = uri.queryParameters['photo_reference'];
      return photoRef;
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra số lượng ảnh cần download
  Future<Map<String, int>> checkDownloadCount() async {
    int destinationCount = 0;
    int cooperationCount = 0;

    try {
      // Kiểm tra DESTINATION
      final destSnapshot = await _firestore.collection('DESTINATION').get();
      for (final doc in destSnapshot.docs) {
        final data = doc.data();
        if (data['photo'] != null && data['photo'] is List) {
          final List<String> photos = List<String>.from(data['photo']);
          for (final photo in photos) {
            if (photo.contains('maps.googleapis.com') && photo.contains('photo_reference=')) {
              destinationCount++;
            }
          }
        }
      }

      // Kiểm tra COOPERATION
      final coopSnapshot = await _firestore.collection('COOPERATION').get();
      for (final doc in coopSnapshot.docs) {
        final data = doc.data();
        if (data['photo'] != null && data['photo'] is String) {
          final String photo = data['photo'];
          if (photo.contains('maps.googleapis.com') && photo.contains('photo_reference=')) {
            cooperationCount++;
          }
        }
      }
    } catch (e) {
      print('Lỗi khi kiểm tra: $e');
    }

    return {
      'destination': destinationCount,
      'cooperation': cooperationCount,
      'total': destinationCount + cooperationCount,
    };
  }
} 