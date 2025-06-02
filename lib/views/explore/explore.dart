import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';

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

  var uuid = Uuid();

  String url = '';
  Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = true;
  

  void makeSuggestion(String input) async {
    String googleApiKey = dotenv.env['GOOGLE_API_KEY']!;
    String groundURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$groundURL?input=$input&key=$googleApiKey&sessiontoken=$tokenForSession';

    var responseResult = await http.get(Uri.parse(request));
    
    var Resultdata = responseResult.body.toString();

    print('Result Data');
    print(Resultdata);

    if(responseResult.statusCode == 200) {
      setState(() {
        listForPlace = jsonDecode(responseResult.body.toString()) ['predictions'];
      });
    }
    else {
      throw Exception(
        'Showing data failed, Try Again'
      );
    }
  }

  void onModify() {
    if(tokenForSession == null)
    {
      setState(() {
        tokenForSession = uuid.v4();
      });
    }

    makeSuggestion(_searchController.text);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchController.addListener(() {
      onModify();
    });
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
        desiredAccuracy: LocationAccuracy.high
      );

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
      debugPrint('Lỗi khi lấy vị trí: $e');
      setState(() {
        _isLoading = false;
      });
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
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  height: 300, // hoặc MediaQuery.of(context).size.height * 0.4
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm địa điểm',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: listForPlace.length,
                          itemBuilder: (context, index)
                          {
                            return ListTile(
                              onTap: () 
                              async {
                                List<Location> locations = await locationFromAddress(listForPlace[index] ['description']);
                                print(locations.last.latitude);
                                print(locations.last.longitude);
      
                              },
                              title: Text(listForPlace[index]['description']),
                            );
                          },
                        )
                      )
                    ]
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

