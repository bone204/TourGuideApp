import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tourguideapp/core/services/places_import_service.dart';
import 'package:tourguideapp/core/services/cooperation_import_service.dart';
import 'package:tourguideapp/core/services/sample_data_service.dart';
import 'package:tourguideapp/core/services/photo_key_update_service.dart';
import 'package:tourguideapp/core/services/photo_download_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isImporting = false;
  String _status = '';
  int _totalPlaces = 0;
  int _importedPlaces = 0;
  String googleApiKey = dotenv.env['GOOGLE_API_KEY']!;

  // Thêm biến cho import cooperation
  bool _isImportingCoop = false;
  String _statusCoop = '';

  bool _isConvertingEatery = false;
  String _convertEateryStatus = '';

  // Thêm biến cho sample data
  bool _isCreatingSampleData = false;
  String _sampleDataStatus = '';

  // Thêm biến cho cập nhật key ảnh
  bool _isUpdatingPhotoKeys = false;
  String _photoKeyUpdateStatus = '';
  late TextEditingController _oldKeyController;
  late TextEditingController _newKeyController;

  // Thêm biến cho download ảnh
  bool _isDownloadingPhotos = false;
  String _photoDownloadStatus = '';
  late TextEditingController _maxWidthController;

  @override
  void initState() {
    super.initState();
    _oldKeyController = TextEditingController(text: 'AIzaSyB4wRN-Lh1EveSPxRSOL6cgo3QvELheuoQ');
    _newKeyController = TextEditingController(text: 'AIzaSyAc8DrI4ZfCS8KeaVVvSLDPbvyWTWs4qbw');
    _maxWidthController = TextEditingController(text: '1000');
  }

  @override
  void dispose() {
    _oldKeyController.dispose();
    _newKeyController.dispose();
    _maxWidthController.dispose();
    super.dispose();
  }

  Future<void> _startImport() async {
    setState(() {
      _isImporting = true;
      _status = 'Bắt đầu import...';
      _totalPlaces = 0;
      _importedPlaces = 0;
    });

    try {
      final service = PlacesImportService(
        apiKey: googleApiKey,
        firestore: FirebaseFirestore.instance,
      );

      // Đếm tổng số địa điểm sẽ import
      // for (var city in service.vietnamProvinces) {
      //   final places = await service.searchNearbyPlaces(
      //         latitude: city['lat'] as double,
      //         longitude: city['lng'] as double,
      //         radius: 10000,
      //         type: 'tourist_attraction',
      //       );
      //   _totalPlaces += places.length;
      // }

      setState(() {
        _status = 'Tìm thấy $_totalPlaces địa điểm để import';
      });

      // Bắt đầu import
      await service.importPlacesToFirebase();

      setState(() {
        _status = 'Import hoàn tất!';
        _isImporting = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Lỗi: $e';
        _isImporting = false;
      });
    }
  }

  Future<void> _startImportCooperation() async {
    setState(() {
      _isImportingCoop = true;
      _statusCoop = 'Bắt đầu import...';
    });
    try {
      final service = CooperationImportService(
        apiKey: googleApiKey,
        firestore: FirebaseFirestore.instance,
      );
      await service.importCooperationsToFirebase();
      setState(() {
        _statusCoop = 'Import hotel/restaurant/eatery hoàn tất!';
        _isImportingCoop = false;
      });
    } catch (e) {
      setState(() {
        _statusCoop = 'Lỗi: $e';
        _isImportingCoop = false;
      });
    }
  }

  Future<void> _convertEateryToHotel() async {
    setState(() {
      _isConvertingEatery = true;
      _convertEateryStatus = 'Đang chuyển eatery thành hotel...';
    });
    try {
      final service = CooperationImportService(
        apiKey: googleApiKey,
        firestore: FirebaseFirestore.instance,
      );
      await service.convertEateryToHotel();
      setState(() {
        _convertEateryStatus = 'Chuyển thành công!';
        _isConvertingEatery = false;
      });
    } catch (e) {
      setState(() {
        _convertEateryStatus = 'Lỗi: $e';
        _isConvertingEatery = false;
      });
    }
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isCreatingSampleData = true;
      _sampleDataStatus = 'Bắt đầu tạo dữ liệu mẫu...';
    });
    try {
      final service = SampleDataService(
        firestore: FirebaseFirestore.instance,
      );
      await service.createAllSampleData();
      setState(() {
        _sampleDataStatus = 'Tạo dữ liệu mẫu hoàn tất!';
        _isCreatingSampleData = false;
      });
    } catch (e) {
      setState(() {
        _sampleDataStatus = 'Lỗi: $e';
        _isCreatingSampleData = false;
      });
    }
  }

  Future<void> _createSampleRooms() async {
    setState(() {
      _isCreatingSampleData = true;
      _sampleDataStatus = 'Đang tạo phòng mẫu...';
    });
    try {
      final service = SampleDataService(
        firestore: FirebaseFirestore.instance,
      );
      await service.createSampleRooms();
      setState(() {
        _sampleDataStatus = 'Tạo phòng mẫu hoàn tất!';
        _isCreatingSampleData = false;
      });
    } catch (e) {
      setState(() {
        _sampleDataStatus = 'Lỗi: $e';
        _isCreatingSampleData = false;
      });
    }
  }

  Future<void> _createSampleTables() async {
    setState(() {
      _isCreatingSampleData = true;
      _sampleDataStatus = 'Đang tạo bàn mẫu...';
    });
    try {
      final service = SampleDataService(
        firestore: FirebaseFirestore.instance,
      );
      await service.createSampleTables();
      setState(() {
        _sampleDataStatus = 'Tạo bàn mẫu hoàn tất!';
        _isCreatingSampleData = false;
      });
    } catch (e) {
      setState(() {
        _sampleDataStatus = 'Lỗi: $e';
        _isCreatingSampleData = false;
      });
    }
  }

  Future<void> _deleteSampleData() async {
    setState(() {
      _isCreatingSampleData = true;
      _sampleDataStatus = 'Đang xóa dữ liệu mẫu...';
    });
    try {
      final service = SampleDataService(
        firestore: FirebaseFirestore.instance,
      );
      await service.deleteAllSampleData();
      setState(() {
        _sampleDataStatus = 'Xóa dữ liệu mẫu hoàn tất!';
        _isCreatingSampleData = false;
      });
    } catch (e) {
      setState(() {
        _sampleDataStatus = 'Lỗi: $e';
        _isCreatingSampleData = false;
      });
    }
  }

  Future<void> _checkPhotoKeyUpdateCount() async {
    setState(() {
      _photoKeyUpdateStatus = 'Đang kiểm tra số lượng URL cần cập nhật...';
    });
    try {
      final service = PhotoKeyUpdateService(
        firestore: FirebaseFirestore.instance,
        oldKey: _oldKeyController.text,
        newKey: _newKeyController.text,
      );
      final result = await service.checkUpdateCount();
      setState(() {
        _photoKeyUpdateStatus = 'Tìm thấy ${result['total']} URL cần cập nhật (DESTINATION: ${result['destination']}, COOPERATION: ${result['cooperation']})';
      });
    } catch (e) {
      setState(() {
        _photoKeyUpdateStatus = 'Lỗi kiểm tra: $e';
      });
    }
  }

  Future<void> _updateAllPhotoKeys() async {
    setState(() {
      _isUpdatingPhotoKeys = true;
      _photoKeyUpdateStatus = 'Bắt đầu cập nhật key ảnh...';
    });
    try {
      final service = PhotoKeyUpdateService(
        firestore: FirebaseFirestore.instance,
        oldKey: _oldKeyController.text,
        newKey: _newKeyController.text,
      );
      await service.updateAllPhotos(
        onProgress: (status) {
          setState(() {
            _photoKeyUpdateStatus = status;
          });
        },
      );
      setState(() {
        _photoKeyUpdateStatus = 'Cập nhật key ảnh hoàn tất!';
        _isUpdatingPhotoKeys = false;
      });
    } catch (e) {
      setState(() {
        _photoKeyUpdateStatus = 'Lỗi: $e';
        _isUpdatingPhotoKeys = false;
      });
    }
  }

  Future<void> _updateDestinationPhotoKeys() async {
    setState(() {
      _isUpdatingPhotoKeys = true;
      _photoKeyUpdateStatus = 'Bắt đầu cập nhật key ảnh địa điểm...';
    });
    try {
      final service = PhotoKeyUpdateService(
        firestore: FirebaseFirestore.instance,
        oldKey: _oldKeyController.text,
        newKey: _newKeyController.text,
      );
      final result = await service.updateDestinationPhotos(
        onProgress: (status) {
          setState(() {
            _photoKeyUpdateStatus = status;
          });
        },
      );
      setState(() {
        _photoKeyUpdateStatus = 'Cập nhật địa điểm hoàn tất: ${result['totalUpdated']}/${result['totalDocuments']} đã cập nhật, ${result['errorCount']} lỗi';
        _isUpdatingPhotoKeys = false;
      });
    } catch (e) {
      setState(() {
        _photoKeyUpdateStatus = 'Lỗi: $e';
        _isUpdatingPhotoKeys = false;
      });
    }
  }

  Future<void> _updateCooperationPhotoKeys() async {
    setState(() {
      _isUpdatingPhotoKeys = true;
      _photoKeyUpdateStatus = 'Bắt đầu cập nhật key ảnh khách sạn/nhà hàng...';
    });
    try {
      final service = PhotoKeyUpdateService(
        firestore: FirebaseFirestore.instance,
        oldKey: _oldKeyController.text,
        newKey: _newKeyController.text,
      );
      final result = await service.updateCooperationPhotos(
        onProgress: (status) {
          setState(() {
            _photoKeyUpdateStatus = status;
          });
        },
      );
      setState(() {
        _photoKeyUpdateStatus = 'Cập nhật khách sạn/nhà hàng hoàn tất: ${result['totalUpdated']}/${result['totalDocuments']} đã cập nhật, ${result['errorCount']} lỗi';
        _isUpdatingPhotoKeys = false;
      });
    } catch (e) {
      setState(() {
        _photoKeyUpdateStatus = 'Lỗi: $e';
        _isUpdatingPhotoKeys = false;
      });
    }
  }

  Future<void> _checkPhotoDownloadCount() async {
    setState(() {
      _photoDownloadStatus = 'Đang kiểm tra số lượng ảnh cần download...';
    });
    try {
      final service = PhotoDownloadService(
        firestore: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
        apiKey: googleApiKey,
      );
      final result = await service.checkDownloadCount();
      setState(() {
        _photoDownloadStatus = 'Tìm thấy ${result['total']} ảnh cần download (DESTINATION: ${result['destination']}, COOPERATION: ${result['cooperation']})';
      });
    } catch (e) {
      setState(() {
        _photoDownloadStatus = 'Lỗi kiểm tra: $e';
      });
    }
  }

  Future<void> _downloadAllPhotos() async {
    setState(() {
      _isDownloadingPhotos = true;
      _photoDownloadStatus = 'Bắt đầu download và upload ảnh...';
    });
    try {
      final maxWidth = int.tryParse(_maxWidthController.text) ?? 1000;
      final service = PhotoDownloadService(
        firestore: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
        apiKey: googleApiKey,
      );
      await service.updateAllPhotos(
        onProgress: (status) {
          setState(() {
            _photoDownloadStatus = status;
          });
        },
        maxWidth: maxWidth,
      );
      setState(() {
        _photoDownloadStatus = 'Download và upload ảnh hoàn tất!';
        _isDownloadingPhotos = false;
      });
    } catch (e) {
      setState(() {
        _photoDownloadStatus = 'Lỗi: $e';
        _isDownloadingPhotos = false;
      });
    }
  }

  Future<void> _downloadDestinationPhotos() async {
    setState(() {
      _isDownloadingPhotos = true;
      _photoDownloadStatus = 'Bắt đầu download ảnh địa điểm...';
    });
    try {
      final maxWidth = int.tryParse(_maxWidthController.text) ?? 1000;
      final service = PhotoDownloadService(
        firestore: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
        apiKey: googleApiKey,
      );
      final result = await service.updateDestinationPhotos(
        onProgress: (status) {
          setState(() {
            _photoDownloadStatus = status;
          });
        },
        maxWidth: maxWidth,
      );
      setState(() {
        _photoDownloadStatus = 'Download địa điểm hoàn tất: ${result['totalUpdated']}/${result['totalDocuments']} đã cập nhật, ${result['errorCount']} lỗi';
        _isDownloadingPhotos = false;
      });
    } catch (e) {
      setState(() {
        _photoDownloadStatus = 'Lỗi: $e';
        _isDownloadingPhotos = false;
      });
    }
  }

  Future<void> _downloadCooperationPhotos() async {
    setState(() {
      _isDownloadingPhotos = true;
      _photoDownloadStatus = 'Bắt đầu download ảnh khách sạn/nhà hàng...';
    });
    try {
      final maxWidth = int.tryParse(_maxWidthController.text) ?? 1000;
      final service = PhotoDownloadService(
        firestore: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
        apiKey: googleApiKey,
      );
      final result = await service.updateCooperationPhotos(
        onProgress: (status) {
          setState(() {
            _photoDownloadStatus = status;
          });
        },
        maxWidth: maxWidth,
      );
      setState(() {
        _photoDownloadStatus = 'Download khách sạn/nhà hàng hoàn tất: ${result['totalUpdated']}/${result['totalDocuments']} đã cập nhật, ${result['errorCount']} lỗi';
        _isDownloadingPhotos = false;
      });
    } catch (e) {
      setState(() {
        _photoDownloadStatus = 'Lỗi: $e';
        _isDownloadingPhotos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import Địa Điểm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Import dữ liệu từ Google Places API vào Firebase',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trạng thái: $_status',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_isImporting) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _totalPlaces > 0
                            ? _importedPlaces / _totalPlaces
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đã import $_importedPlaces/$_totalPlaces địa điểm',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isImporting ? null : _startImport,
              child: Text(_isImporting ? 'Đang Import...' : 'Bắt Đầu Import'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import Khách sạn/Nhà hàng/Quán ăn nổi tiếng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Import hotel, restaurant, eatery từ Google Places API vào Firestore',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trạng thái: $_statusCoop',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_isImportingCoop) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isImportingCoop ? null : _startImportCooperation,
              child: Text(_isImportingCoop
                  ? 'Đang Import...'
                  : 'Bắt Đầu Import Khách sạn/Nhà hàng/Quán ăn'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chuyển Eatery thành Hotel',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text('$_convertEateryStatus',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed:
                          _isConvertingEatery ? null : _convertEateryToHotel,
                      child: Text(_isConvertingEatery
                          ? 'Đang chuyển...'
                          : 'Chuyển Eatery thành Hotel'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tạo Dữ Liệu Mẫu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo dữ liệu mẫu cho phòng khách sạn và bàn nhà hàng',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trạng thái: $_sampleDataStatus',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_isCreatingSampleData) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCreatingSampleData
                                ? null
                                : _createSampleRooms,
                            child: const Text('Tạo Phòng Mẫu'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCreatingSampleData
                                ? null
                                : _createSampleTables,
                            child: const Text('Tạo Bàn Mẫu'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCreatingSampleData
                                ? null
                                : _createSampleData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Tạo Tất Cả'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCreatingSampleData
                                ? null
                                : _deleteSampleData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Xóa Dữ Liệu Mẫu'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cập Nhật Key Ảnh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cập nhật tất cả URL ảnh với key mới trong Firebase',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Key Cũ',
                              border: OutlineInputBorder(),
                            ),
                            controller: _oldKeyController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Key Mới',
                              border: OutlineInputBorder(),
                            ),
                            controller: _newKeyController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trạng thái: $_photoKeyUpdateStatus',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_isUpdatingPhotoKeys) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isUpdatingPhotoKeys ? null : _checkPhotoKeyUpdateCount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Kiểm Tra Số Lượng'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isUpdatingPhotoKeys ? null : _updateDestinationPhotoKeys,
                            child: const Text('Cập Nhật Địa Điểm'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isUpdatingPhotoKeys ? null : _updateCooperationPhotoKeys,
                            child: const Text('Cập Nhật Khách Sạn/Nhà Hàng'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isUpdatingPhotoKeys ? null : _updateAllPhotoKeys,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cập Nhật Tất Cả'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Download Ảnh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Download và upload ảnh từ Google Places API vào Firebase Storage',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Max Width (px)',
                        border: OutlineInputBorder(),
                        helperText: 'Kích thước tối đa của ảnh (mặc định: 1000)',
                      ),
                      controller: _maxWidthController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trạng thái: $_photoDownloadStatus',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_isDownloadingPhotos) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isDownloadingPhotos ? null : _checkPhotoDownloadCount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Kiểm Tra Số Lượng'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isDownloadingPhotos ? null : _downloadDestinationPhotos,
                            child: const Text('Download Địa Điểm'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isDownloadingPhotos ? null : _downloadCooperationPhotos,
                            child: const Text('Download Khách Sạn/Nhà Hàng'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isDownloadingPhotos ? null : _downloadAllPhotos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Download Tất Cả'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
