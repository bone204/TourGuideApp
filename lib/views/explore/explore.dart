import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  String tokenForSession = '37465';
  List<dynamic> listForPlace = [];

  var uuid = const Uuid();

  String url = '';
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = true;
  Timer? _debounceTimer;
  

  void makeSuggestion(String input) async {
    if (!mounted) return;
    
    String googleApiKey = dotenv.env['GOOGLE_API_KEY']!;
    String groundURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$groundURL?input=$input&key=$googleApiKey&sessiontoken=$tokenForSession';

    try {
      var responseResult = await http.get(Uri.parse(request));
      
      if (!mounted) return;

      if (responseResult.statusCode == 200) {
        setState(() {
          listForPlace = jsonDecode(responseResult.body.toString())['predictions'];
        });
      } else {
        throw Exception('Showing data failed, Try Again');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          listForPlace = [];
        });
      }
    }
  }

  Future<Map<String, double>> getPlaceDetails(String placeId) async {
    String googleApiKey = dotenv.env['GOOGLE_API_KEY']!;
    String detailsURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$detailsURL?place_id=$placeId&fields=geometry&key=$googleApiKey';

    var response = await http.get(Uri.parse(request));
    
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var location = data['result']['geometry']['location'];
      return {
        'lat': location['lat'],
        'lng': location['lng'],
      };
    } else {
      throw Exception('Failed to get place details');
    }
  }

  void onModify() {
    _debounceTimer?.cancel();
    
    // Tạo timer mới
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        makeSuggestion(_searchController.text);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchController.addListener(onModify);
  }

  @override
  void dispose() {
    _searchController.removeListener(onModify);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Kiểm tra quyền truy cập vị trí
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: const InfoWindow(
                title: 'Vị trí của bạn',
                snippet: 'Bạn đang ở đây',
              ),
            ),
          );
          _isLoading = false;
        });
      }

      // Di chuyển camera đến vị trí hiện tại
      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Lỗi khi lấy vị trí: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : const LatLng(21.0285, 105.8542), // Vị trí mặc định (Hà Nội)
                  zoom: 15,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm địa điểm',
                                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    listForPlace = [];
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      if (listForPlace.isNotEmpty) ...[
                        const Divider(height: 1),
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listForPlace.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 20),
                                onTap: () async {
                                  try {
                                    final placeId = listForPlace[index]['place_id'];
                                    final location = await getPlaceDetails(placeId);
                                    final lat = location['lat']!;
                                    final lng = location['lng']!;
                                    
                                    setState(() {
                                      _markers.removeWhere((marker) => marker.markerId.value != 'current_location');
                                      _markers.add(
                                        Marker(
                                          markerId: MarkerId('selected_location_$index'),
                                          position: LatLng(lat, lng),
                                          infoWindow: InfoWindow(
                                            title: listForPlace[index]['description'],
                                            snippet: 'Địa điểm đã chọn',
                                          ),
                                        ),
                                      );
                                    });

                                    if (_controller.isCompleted) {
                                      final GoogleMapController controller = await _controller.future;
                                      controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: LatLng(lat, lng),
                                            zoom: 15,
                                          ),
                                        ),
                                      );
                                    }

                                    setState(() {
                                      listForPlace = [];
                                      _searchController.clear();
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Không thể tìm thấy vị trí chính xác. Vui lòng thử lại.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                title: Text(
                                  listForPlace[index]['description'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ]
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

