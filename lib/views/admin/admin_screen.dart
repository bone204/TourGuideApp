import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tourguideapp/core/services/places_import_service.dart';
import 'package:tourguideapp/core/services/cooperation_import_service.dart';
import 'package:tourguideapp/core/services/sample_data_service.dart';

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

  Future<void> _startImport() async {
    setState(() {
      _isImporting = true;
      _status = 'Bắt đầu import...';
      _totalPlaces = 0;
      _importedPlaces = 0;
    });

    try {
      final service = PlacesImportService(
        apiKey: googleApiKey, // Thay thế bằng API key của bạn
        firestore: FirebaseFirestore.instance,
      );

      // Đếm tổng số địa điểm sẽ import
      // for (var city in service.vietnamProvinces) {
      //   final places = await service.searchNearbyPlaces(
      //     latitude: city['lat'] as double,
      //     longitude: city['lng'] as double,
      //     radius: 10000,
      //     type: 'tourist_attraction',
      //   );
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
          ],
        ),
      ),
    );
  }
}
