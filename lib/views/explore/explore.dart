import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:typed_data' show Uint8List;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;


class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class SearchResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  SearchResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class CustomPointAnnotationClickListener extends OnPointAnnotationClickListener {
  final Function(PointAnnotation) onClick;

  CustomPointAnnotationClickListener(this.onClick);

  @override
  bool onPointAnnotationClick(PointAnnotation annotation) {
    onClick(annotation);
    return true;
  }
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  MapboxMap? _mapController;
  PointAnnotationManager? _annotationManager;
  List<SearchResult> _searchResults = [];
  
  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      // Kiểm tra quyền truy cập vị trí
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      // Lấy vị trí hiện tại
      final position = await geo.Geolocator.getCurrentPosition();
      await _focusLocation(
        position.latitude,
        position.longitude,
        'Vị trí của bạn',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current position: $e');
      }
    }
  }

  // Tạo hằng số cho zoom level
  static const double MAP_ZOOM_LEVEL = 15.0;  // Tăng từ 12.0 lên 15.0

  Future<void> _focusLocation(double lat, double lng, String title, {DestinationModel? destination}) async {
    if (_mapController != null) {
      try {
        await _annotationManager?.deleteAll();

        await _mapController!.easeTo(
          CameraOptions(
            center: Point(coordinates: Position(lng, lat)),
            zoom: MAP_ZOOM_LEVEL,
          ),
          MapAnimationOptions(duration: 1000),
        );

        final ByteData bytes =
        await rootBundle.load('assets/img/custom-icon.png');
    final Uint8List imageData = bytes.buffer.asUint8List();


        await _annotationManager?.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(lng, lat)),
            image: imageData,
            iconSize: 0.3,
            textField: title,
            textOffset: [0, 2.0],
            textColor: Colors.black.value,
            textHaloColor: Colors.white.value,
            textHaloWidth: 1.0,
          ),
        );

        if (destination != null) {
          _annotationManager?.addOnPointAnnotationClickListener(
            CustomPointAnnotationClickListener((annotation) {
              _showDestinationInfo(destination);
            }),
          );
        }

      } catch (e) {
        if (kDebugMode) {
          print('Error focusing location: $e');
        }
      }
    }
  }

  // Thêm phương thức để chuyển đổi widget thành bytes
  Future<Uint8List> _captureWidget(Widget widget) async {
    final repaintBoundary = RepaintBoundary(
      child: SizedBox(
        width: 80,  // Kích thước của marker
        height: 80,
        child: widget,
      ),
    );

    final renderObject = repaintBoundary.createRenderObject(context);
    final image = await renderObject.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm địa điểm...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults.clear();
                      });
                    },
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _onSearchChanged,
          ),
          if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.primaryColor),
                    title: Text(result.name),
                    subtitle: Text(result.address),
                    onTap: () {
                      if (kDebugMode) {
                        print('Selected location: ${result.name}');
                      }

                      // Tìm destination tương ứng
                      final destination = Provider.of<DestinationsViewModel>(context, listen: false)
                          .destinations
                          .firstWhere(
                            (dest) => dest.destinationName == result.name,
                            orElse: () => DestinationModel(
                              destinationId: '',
                              destinationName: result.name,
                              province: '',
                              specificAddress: result.address,
                              descriptionViet: '',
                              descriptionEng: '',
                              photo: [],
                              latitude: result.latitude,
                              longitude: result.longitude,
                              district: '',
                              video: [],
                              createdDate: '',
                            ),
                          );

                      setState(() {
                        _searchController.text = result.name;
                        _searchResults.clear();
                      });
                      
                      _focusLocation(
                        result.latitude,
                        result.longitude,
                        result.name,
                        destination: destination, // Truyền destination vào
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DestinationsViewModel>(
      builder: (context, destinationsVM, child) {
        if (destinationsVM.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (destinationsVM.error.isNotEmpty) {
          return Scaffold(
            body: Center(child: Text(destinationsVM.error)),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              MapWidget(
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(107.5, 16.5)),
                  zoom: 5.0,
                ),
                onMapCreated: _onMapCreated,
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: _buildSearchBar(),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'location',
                onPressed: _determinePosition,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'layers',
                onPressed: _showMapStyles,
                child: const Icon(Icons.layers),
              ),
            ],
          ),
        );
      },
    );
  }

  String _removeDiacritics(String text) {
    var vietnameseMap = {
      'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ẳ|ặ|ẵ|��|Â|À|Á|Ạ|Ả|Ã|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ằ|Ắ|Ặ|Ẳ|Ẵ': 'a',
      'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ|È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ': 'e',
      'ì|í|ị|ỉ|ĩ|Ì|Í|Ị|Ỉ|Ĩ': 'i',
      'ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ợ|ở|ỡ|Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ': 'o',
      'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ|Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ': 'u',
      'ỳ|ý|ỵ|ỷ|ỹ|Ỳ|Ý|Ỵ|Ỷ|Ỹ': 'y',
      'đ|Đ': 'd'
    };

    String result = text.toLowerCase();
    vietnameseMap.forEach((key, value) {
      result = result.replaceAll(RegExp(key), value);
    });
    return result;
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    // Lấy destinations từ Provider một lần
    final destinations = Provider.of<DestinationsViewModel>(context, listen: false).destinations;
    final normalizedQuery = _removeDiacritics(query.toLowerCase());

    // Tìm kiếm
    final results = destinations.where((dest) {
      if (kDebugMode) {
        print('Raw coordinates from Firebase:');
        print('${dest.destinationName}: lat=${dest.latitude}, lng=${dest.longitude}');
      }
      
      final normalizedName = _removeDiacritics(dest.destinationName.toLowerCase());
      final normalizedProvince = _removeDiacritics(dest.province.toLowerCase());
      return normalizedName.contains(normalizedQuery) || 
             normalizedProvince.contains(normalizedQuery);
    }).take(5).map((dest) => SearchResult(
      name: dest.destinationName,
      address: '${dest.specificAddress}, ${dest.province}',
      latitude: dest.longitude,   // Giữ nguyên như trong Firebase
      longitude: dest.latitude, // Giữ nguyên như trong Firebase
    )).toList();

    if (kDebugMode) {
      print('Found ${results.length} results:');
      for (var result in results) {
        print('${result.name}: (${result.latitude}, ${result.longitude})');  // Log kết quả tìm kiếm
      }
    }

    setState(() {
      _searchResults = results;
    });
  }

  void _showMapStyles() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 200,
        child: ListView(
          children: [
            ListTile(
              title: const Text('Streets'),
              onTap: () => _changeMapStyle('mapbox://styles/mapbox/streets-v11'),
            ),
            ListTile(
              title: const Text('Satellite'),
              onTap: () => _changeMapStyle('mapbox://styles/mapbox/satellite-v9'),
            ),
            ListTile(
              title: const Text('Dark'),
              onTap: () => _changeMapStyle('mapbox://styles/mapbox/dark-v10'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeMapStyle(String styleUri) {
    if (_mapController != null) {
      _mapController!.loadStyleURI(styleUri);
    }
    Navigator.pop(context);
  }

  void _showDestinationInfo(DestinationModel destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Stack(
            children: [
              // Header Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(destination.photo.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Content
              Container(
                margin: const EdgeInsets.only(top: 180),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: DefaultTabController(
                  length: 4,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                          child: Text(
                            destination.destinationName,
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${destination.specificAddress}, ${destination.province}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // TabBar
                        const TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.red,
                          tabs: [
                            Tab(text: 'About'),
                            Tab(text: 'Review'),
                            Tab(text: 'Photo'),
                            Tab(text: 'Video'),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // TabBarView
                        SizedBox(
                          height: 300,
                          child: TabBarView(
                            children: [
                              // About
                              SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  destination.descriptionViet,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // Review
                              Center(child: Text('Reviews coming soon')),
                              // Photos
                              GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: destination.photo.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      destination.photo[index],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                              // Videos
                              GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: destination.video.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      size: 30,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Thêm phương thức này đ��� load marker image từ URL


// Future<void> _loadMarkerImage() async {
//   if (_mapController != null) {
//     try {
//       // Tải hình ảnh từ URL
//       final response = await http.get(Uri.parse(
//           'https://cdn-icons-png.flaticon.com/512/684/684908.png'));
      
//       if (response.statusCode == 200) {
//         final bytes = response.bodyBytes;

//         // Thêm hình ảnh vào style của Map
//         await _mapController!.style.addImage(
//           "custom-marker",
//           bytes,
//           options: {
//             'sdf': false // Chỉ định đây không phải hình ảnh SDF
//           },
//         );
//       } else {
//         if (kDebugMode) {
//           print('Error: Unable to load image. HTTP status: ${response.statusCode}');
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error loading marker image: $e');
//       }
//     }
//   } else {
//     if (kDebugMode) {
//       print('Error: MapController is null.');
//     }
//   }
// }


  // Thêm phương thức này để tạo MapboxMap
  void _onMapCreated(MapboxMap controller) async {
    _mapController = controller;
    _annotationManager = await controller.annotations.createPointAnnotationManager();
    // await _loadMarkerImage(); // Load marker image sau khi map được tạo
    
  }
}
