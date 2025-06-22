import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationPicker extends StatefulWidget {
  final Function(String, Map<String, String>, String, String) onLocationSelected;
  final String? title;
  final bool isDeliveryLocation; // Để phân biệt địa điểm gửi và nhận

  const LocationPicker({
    Key? key,
    required this.onLocationSelected,
    required this.title,
    this.isDeliveryLocation = false, // Mặc định là địa điểm gửi
  }) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String selectedLocation = "";
  String selectedName = "";
  List<Map<String, dynamic>> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _searchPlaces(String input) async {
    if (input.length < 3) return [];
    
    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = dotenv.env['GOOGLE_API_KEY']!;
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=vi&components=country:VN&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'OK') {
        return List<Map<String, dynamic>>.from(data['predictions']);
      }
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getPlaceDetails(String placeId) async {
    try {
      final apiKey = dotenv.env['GOOGLE_API_KEY']!;
      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&language=vi&fields=formatted_address,address_components,geometry,name,formatted_phone_number&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'OK') {
        return data['result'];
      }
      return {};
    } catch (e) {
      print('Error getting place details: $e');
      return {};
    }
  }

  void _showSearchScreen() {
    _searchResults.clear();
    _searchController.text = selectedName;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.h),
              child: CustomAppBar(
                title: widget.isDeliveryLocation 
                    ? AppLocalizations.of(context).translate('Choose Delivery Location')
                    : AppLocalizations.of(context).translate('Choose Pickup Location'),
                onBackPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Column(
                children: [
                  CustomSearchBar(
                    controller: _searchController,
                    hintText: AppLocalizations.of(context).translate('Search location'),
                    onChanged: (value) async {
                      if (value.length >= 3) {
                        final results = await _searchPlaces(value);
                        setModalState(() {
                          _searchResults = results;
                        });
                      } else {
                        setModalState(() {
                          _searchResults.clear();
                        });
                      }
                    },
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  SizedBox(height: 10.h),
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _searchResults.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context).translate('Enter location to search'),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final prediction = _searchResults[index];
                                  return ListTile(
                                    leading: Icon(
                                      _getIconForType(prediction['types'] ?? []),
                                      color: AppColors.primaryColor,
                                    ),
                                    title: Text(
                                      prediction['structured_formatting']?['main_text'] ?? prediction['description'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      prediction['structured_formatting']?['secondary_text'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () async {
                                      final details = await _getPlaceDetails(prediction['place_id']);
                                      final locationDetails = extractLocationDetails(details);
                                      
                                      // Lấy thông tin từ Google Places API
                                      String recipientName = '';
                                      String recipientPhone = '';
                                      
                                      // Chỉ lấy thông tin nếu là địa điểm gửi hàng (không phải giao hàng)
                                      if (!widget.isDeliveryLocation) {
                                        recipientName = locationDetails['name'] ?? '';
                                        recipientPhone = locationDetails['phone'] ?? '';
                                      }
                                      
                                      setState(() {
                                        selectedLocation = prediction['description'] ?? '';
                                        selectedName = recipientName.isNotEmpty ? recipientName : prediction['structured_formatting']?['main_text'] ?? '';
                                      });
                                      
                                      widget.onLocationSelected(
                                        prediction['description'] ?? '',
                                        locationDetails,
                                        recipientName,
                                        recipientPhone,
                                      );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(List<dynamic> types) {
    if (types.contains('establishment')) return Icons.business;
    if (types.contains('sublocality') || types.contains('locality')) return Icons.location_city;
    if (types.contains('route')) return Icons.route;
    if (types.contains('street_address')) return Icons.home;
    return Icons.location_on;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title ?? AppLocalizations.of(context).translate('Location'),
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _showSearchScreen,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    selectedLocation.isEmpty
                        ? AppLocalizations.of(context)
                            .translate('Select location')
                        : selectedLocation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: selectedLocation.isEmpty
                          ? AppColors.grey
                          : AppColors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

// Thêm class để quản lý dữ liệu địa điểm
class LocationOption {
  final String province;
  final String city;
  final String district;

  LocationOption({
    required this.province,
    this.city = '',
    this.district = '',
  });
}

Map<String, String> extractLocationDetails(Map<String, dynamic> placeDetails) {
  String province = '';
  String city = '';
  String district = '';
  if (placeDetails['address_components'] != null) {
    for (var comp in placeDetails['address_components']) {
      if (comp['types'].contains('administrative_area_level_1')) {
        province = comp['long_name'];
      }
      if (comp['types'].contains('administrative_area_level_2')) {
        city = comp['long_name'];
      }
      if (comp['types'].contains('administrative_area_level_3')) {
        district = comp['long_name'];
      }
    }
  }
  return {
    'province': province,
    'city': city,
    'district': district,
    'address': placeDetails['formatted_address'] ?? '',
    'lat': placeDetails['geometry']?['location']?['lat']?.toString() ?? '',
    'lng': placeDetails['geometry']?['location']?['lng']?.toString() ?? '',
    'name': placeDetails['name'] ?? '',
    'phone': placeDetails['formatted_phone_number'] ?? '',
  };
}
