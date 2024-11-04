import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  MapboxMap? _mapController;

  @override
  Widget build(BuildContext context) {
    // Đặt access token cho Mapbox
    const String ACCESS_TOKEN = 'sk.eyJ1IjoiYm9uZTA1MDEyMDA0IiwiYSI6ImNtMzFuOWo1ZzB1Z2kybXNqajI1bnoxYm8ifQ.5wLAbHwyDCoPYsLlDvb2EA';
    MapboxOptions.setAccessToken(ACCESS_TOKEN);

    // Định nghĩa các tùy chọn cho camera để tập trung vào Việt Nam
    CameraOptions camera = CameraOptions(
      center: Point(coordinates: Position(14.0583, 108.2772)), // Vị trí trung tâm của Việt Nam
      zoom: 5.0, // Mức độ thu phóng để hiển thị toàn bộ Việt Nam
      bearing: 0,
      pitch: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: MapWidget(
        cameraOptions: camera,
        onMapCreated: (MapboxMap controller) {
          _mapController = controller;
          // Thực hiện các thao tác khi bản đồ được tạo
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tìm kiếm địa điểm'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Nhập địa chỉ'),
          ),
          actions: [
            TextButton(
              child: Text('Tìm kiếm'),
              onPressed: () {
                _searchLocation(_searchController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _searchLocation(String query) {
    // Sử dụng Mapbox Geocoding API để tìm kiếm địa điểm
    // Sau đó cập nhật vị trí của bản đồ dựa trên kết quả tìm kiếm
    // Ví dụ: _mapController?.moveCamera(CameraUpdate.newLatLng(newLatLng));
  }
}
