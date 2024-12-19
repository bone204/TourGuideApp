import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';

class LocationPicker extends StatefulWidget {
  final Function(String) onProvinceSelected;

  const LocationPicker({
    Key? key,
    required this.onProvinceSelected,
  }) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationSearchScreen extends StatefulWidget {
  final Function(String) onLocationSelected;
  final GeoCoding geocoding;

  const _LocationSearchScreen({
    Key? key,
    required this.onLocationSelected,
    required this.geocoding,
  }) : super(key: key);

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<_LocationSearchScreen> {
  List<MapBoxPlace> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
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
                    clipBehavior: Clip.none,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
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
                      if (value.length > 2) {
                        final response = await widget.geocoding.getPlaces(value);
                        if (mounted) {
                          setState(() {
                            _searchResults = response.success ?? [];
                          });
                        }
                      } else {
                        if (mounted) {
                          setState(() {
                            _searchResults = [];
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final place = _searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: AppColors.primaryColor),
                        title: Text(place.placeName ?? ''),
                        subtitle: Text(place.text ?? ''),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          widget.onLocationSelected(place.placeName ?? '');
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
    );
  }
}

class _LocationPickerState extends State<LocationPicker> {
  String selectedLocation = "75 Westerdam, Nha Trang";
  final geocoding = GeoCoding(
    apiKey: 'pk.eyJ1IjoidGhvbmd0dWxlbjEzNCIsImEiOiJjbTNwOTd4dWEwY2l1MnJxMWt0dnRla2pqIn0.9o3fO8SYcsRxRYH0-Qtfhg',
    country: "vn",
    limit: 5,
    types: [PlaceType.address, PlaceType.place],
  );

  void _showSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LocationSearchScreen(
          onLocationSelected: (location) {
            setState(() {
              selectedLocation = location;
            });
            widget.onProvinceSelected(location);
          },
          geocoding: geocoding,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('Location'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
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
                    selectedLocation,
                    style: TextStyle(fontSize: 14.sp),
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
