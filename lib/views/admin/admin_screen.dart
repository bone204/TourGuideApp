import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tourguideapp/core/services/places_import_service.dart';

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
      for (var city in service.vietnamProvinces) {
        final places = await service.searchNearbyPlaces(
          latitude: city['lat'] as double,
          longitude: city['lng'] as double,
          radius: 10000,
          type: 'tourist_attraction',
        );
        _totalPlaces += places.length;
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Padding(
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
                        value: _totalPlaces > 0 ? _importedPlaces / _totalPlaces : null,
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
          ],
        ),
      ),
    );
  }
} 