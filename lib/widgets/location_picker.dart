import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationPicker extends StatefulWidget {
  final Function(String, Map<String, String>) onLocationSelected;
  final String? title;

  const LocationPicker({
    Key? key,
    required this.onLocationSelected,
    required this.title,
  }) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String selectedLocation = "";
  String selectedName = "";
  List<Suggestion> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  Future<List<Map<String, dynamic>>> _searchPlaces(String input) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY']!;
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=vi&components=country:VN&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if (data['status'] == 'OK') {
      return List<Map<String, dynamic>>.from(data['predictions']);
    }
    return [];
  }

  Future<Map<String, dynamic>> _getPlaceDetails(String placeId) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY']!;
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&language=vi&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if (data['status'] == 'OK') {
      return data['result'];
    }
    return {};
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
                title:
                    AppLocalizations.of(context).translate('Choose Location'),
                onBackPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Column(
                children: [
                  CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Search',
                    onChanged: (value) async {
                      _searchPlaces(value);
                    },
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final suggestion = _searchResults[index];
                          return ListTile(
                            leading: Icon(
                                suggestion.featureType == 'poi'
                                    ? Icons.place
                                    : suggestion.featureType == 'address'
                                        ? Icons.home
                                        : Icons.location_city,
                                color: AppColors.primaryColor),
                            title: Text(
                              suggestion.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              _formatAddress(suggestion.address ?? ''),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              final details =
                                  await _getPlaceDetails(suggestion.mapboxId);
                              setState(() {
                                selectedLocation = _formatAddress(
                                    suggestion.fullAddress ?? '');
                                selectedName = suggestion.name;
                              });
                              widget.onLocationSelected(
                                _formatAddress(suggestion.fullAddress ?? ''),
                                extractLocationDetails(details),
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

  String _formatAddress(String? address) {
    if (address == null) return '';
    return address.replaceAll('Vietnam', 'Việt Nam');
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
    'lat': placeDetails['geometry']['location']['lat'].toString(),
    'lng': placeDetails['geometry']['location']['lng'].toString(),
  };
}
