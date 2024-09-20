
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Thư viện bản đồ FlutterMap
import 'package:latlong2/latlong.dart'; // Quản lý tọa độ LatLng

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(51.5, -0.09), // Tọa độ trung tâm bản đồ
            initialZoom: 13.0, // Mức độ zoom ban đầu
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
              // Thêm thông tin bản quyền nếu cần
              // attribution: '© OpenStreetMap contributors',
            ),
            const MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(51.5, -0.09), // Tọa độ của marker
                  width: 80.0,
                  height: 80.0,
                  // Sử dụng `child` để tạo nội dung của marker
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    const LatLng(51.5, -0.09),
                    const LatLng(51.51, -0.1),
                    const LatLng(51.52, -0.12),
                  ],
                  strokeWidth: 4.0, // Độ rộng của đường
                  color: Colors.blue, // Màu sắc của lộ trình
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
