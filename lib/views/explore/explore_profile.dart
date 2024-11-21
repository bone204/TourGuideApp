import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  MapboxMap? _mapController;
  PointAnnotationManager? _annotationManager;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    // Kiểm tra nếu dịch vụ định vị được bật
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Dịch vụ định vị không bật
      if (kDebugMode) {
        print('Dịch vụ định vị không khả dụng.');
      }
      return;
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        // Quyền bị từ chối
        if (kDebugMode) {
          print('Quyền truy cập vị trí bị từ chối.');
        }
        return;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      // Quyền bị từ chối vĩnh viễn
      if (kDebugMode) {
        print('Quyền truy cập vị trí bị từ chối vĩnh viễn.');
      }
      return;
    }

    try {
      // Lấy vị trí hiện tại
      geo.Position position = await geo.Geolocator.getCurrentPosition();
      _moveToUserLocation(position);
    } catch (e) {
      // Xử lý lỗi và thông báo cho người dùng
      if (kDebugMode) {
        print('Lỗi khi lấy vị trí: $e');
      }
    }
  }

  void _moveToUserLocation(geo.Position position) {
    if (_mapController != null) {
      _mapController!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(position.longitude, position.latitude)),
          zoom: 16.0, // Tăng giá trị zoom để phóng to sát hơn
        ),
        MapAnimationOptions(
          duration: 2000, // Thời gian di chuyển camera (ms)
        ),
      );
      _addUserLocationMarker(position);
    }
  }

  Future<void> _addUserLocationMarker(geo.Position position) async {
    if (_mapController != null) {
      _annotationManager ??= await _mapController!.annotations.createPointAnnotationManager();

      // Thêm một điểm đánh dấu với biểu tượng có sẵn khác
      await _annotationManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          iconImage: 'marker-stroked-15', // Sử dụng biểu tượng có sẵn khác từ Mapbox
          iconSize: 10.0, // Điều chỉnh kích thước biểu tượng nếu cần
        ),
      );

      if (kDebugMode) {
        print('Marker added at: ${position.latitude}, ${position.longitude}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String ACCESS_TOKEN = 'pk.eyJ1IjoidGhvbmd0dWxlbjEzNCIsImEiOiJjbTNwOTd4dWEwY2l1MnJxMWt0dnRla2pqIn0.9o3fO8SYcsRxRYH0-Qtfhg';
    MapboxOptions.setAccessToken(ACCESS_TOKEN);

    CameraOptions camera = CameraOptions(
      center: Point(coordinates: Position(14.0583, 108.2772)),
      zoom: 5.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          _determinePosition();
        },
        child: FloatingActionButton(
          onPressed: () {
            _determinePosition();
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tìm kiếm địa điểm'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: 'Nhập địa chỉ'),
          ),
          actions: [
            TextButton(
              child: const Text('Tìm kiếm'),
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
    // Sử dụng API Geocoding để tìm kiếm địa điểm
  }
}
