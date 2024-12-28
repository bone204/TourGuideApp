import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';

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
  
  final searchAPI = SearchBoxAPI(
    apiKey: 'pk.eyJ1IjoidGhvbmd0dWxlbjEzNCIsImEiOiJjbTNwOTd4dWEwY2l1MnJxMWt0dnRla2pqIn0.9o3fO8SYcsRxRYH0-Qtfhg',
    limit: 10,
    country: 'VN',
    language: 'vi',
    types: [
      PlaceType.poi,
      PlaceType.address, 
      PlaceType.place,
      PlaceType.district,
      PlaceType.locality,
      PlaceType.postcode,
    ],
  );

  Future<void> _searchPlaces(String value, StateSetter setModalState) async {
    if (value.length > 1) {
      try {
        final response = await searchAPI.getSuggestions(value);
        response.fold(
          (success) {
            setModalState(() {
              _searchResults = success.suggestions;
            });
          },
          (failure) {
            print('Search error: ${failure.message}');
            setModalState(() {
              _searchResults.clear();
            });
          },
        );
      } catch (e) {
        print('Search error: $e');
        setModalState(() {
          _searchResults.clear();
        });
      }
    } else {
      setModalState(() {
        _searchResults.clear();
      });
    }
  }

  Future<Map<String, String>> _getPlaceDetails(String mapboxId) async {
    try {
      final response = await searchAPI.getPlace(mapboxId);
      
      return response.fold(
        (success) {
          final feature = success.features.first;
          
          return {
            'address': feature.properties.address ?? '',
            'latitude': feature.geometry.coordinates.lat.toString(),
            'longitude': feature.geometry.coordinates.long.toString(),
          };
        },
        (failure) => {},
      );
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
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40.h,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CustomIconButton(
                              icon: Icons.chevron_left,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Center(
                            child: Text(
                              AppLocalizations.of(context).translate('Choose Location'),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).translate('Search'),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) async {
                        _searchPlaces(value, setModalState);
                      },
                    ),
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
                              color: AppColors.primaryColor
                            ),
                            title: Text(
                              suggestion.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
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
                              final details = await _getPlaceDetails(suggestion.mapboxId);
                              setState(() {
                                selectedLocation = _formatAddress(suggestion.fullAddress ?? '');
                                selectedName = suggestion.name;
                              });
                              widget.onLocationSelected(
                                _formatAddress(suggestion.fullAddress ?? ''),
                                details,
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
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
                        ? AppLocalizations.of(context).translate('Select location')
                        : selectedLocation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: selectedLocation.isEmpty ? AppColors.grey : AppColors.black,
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
