import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoKeyUpdateService {
  final FirebaseFirestore _firestore;
  final String _oldKey;
  final String _newKey;

  PhotoKeyUpdateService({
    required FirebaseFirestore firestore,
    required String oldKey,
    required String newKey,
  })  : _firestore = firestore,
        _oldKey = oldKey,
        _newKey = newKey;

  /// Cập nhật tất cả URL ảnh trong collection DESTINATION
  Future<Map<String, int>> updateDestinationPhotos({
    required Function(String) onProgress,
  }) async {
    int totalUpdated = 0;
    int totalDocuments = 0;
    int errorCount = 0;

    try {
      onProgress('Đang lấy danh sách địa điểm...');
      
      final querySnapshot = await _firestore.collection('DESTINATION').get();
      totalDocuments = querySnapshot.docs.length;
      
      onProgress('Tìm thấy $totalDocuments địa điểm. Bắt đầu cập nhật...');

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final data = doc.data();
        
        if (data['photo'] != null && data['photo'] is List) {
          final List<String> photos = List<String>.from(data['photo']);
          bool hasChanges = false;
          
          for (int j = 0; j < photos.length; j++) {
            if (photos[j].contains(_oldKey)) {
              photos[j] = photos[j].replaceAll(_oldKey, _newKey);
              hasChanges = true;
            }
          }
          
          if (hasChanges) {
            try {
              await doc.reference.update({'photo': photos});
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

  /// Cập nhật tất cả URL ảnh trong collection COOPERATION
  Future<Map<String, int>> updateCooperationPhotos({
    required Function(String) onProgress,
  }) async {
    int totalUpdated = 0;
    int totalDocuments = 0;
    int errorCount = 0;

    try {
      onProgress('Đang lấy danh sách khách sạn/nhà hàng...');
      
      final querySnapshot = await _firestore.collection('COOPERATION').get();
      totalDocuments = querySnapshot.docs.length;
      
      onProgress('Tìm thấy $totalDocuments khách sạn/nhà hàng. Bắt đầu cập nhật...');

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final data = doc.data();
        
        if (data['photo'] != null && data['photo'] is String) {
          String photo = data['photo'];
          
          if (photo.contains(_oldKey)) {
            photo = photo.replaceAll(_oldKey, _newKey);
            
            try {
              await doc.reference.update({'photo': photo});
              totalUpdated++;
              onProgress('Đã cập nhật ${i + 1}/$totalDocuments: ${data['name'] ?? 'Unknown'}');
            } catch (e) {
              errorCount++;
              onProgress('Lỗi cập nhật ${data['name'] ?? 'Unknown'}: $e');
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

  /// Cập nhật tất cả URL ảnh trong tất cả collections
  Future<Map<String, dynamic>> updateAllPhotos({
    required Function(String) onProgress,
  }) async {
    onProgress('Bắt đầu cập nhật tất cả URL ảnh...');
    
    final destinationResult = await updateDestinationPhotos(onProgress: onProgress);
    final cooperationResult = await updateCooperationPhotos(onProgress: onProgress);
    
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

  /// Kiểm tra số lượng URL cần cập nhật
  Future<Map<String, int>> checkUpdateCount() async {
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
            if (photo.contains(_oldKey)) {
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
          if (photo.contains(_oldKey)) {
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