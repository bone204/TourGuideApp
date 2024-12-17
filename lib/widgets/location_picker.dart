import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';

class LocationPicker extends StatefulWidget {
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String selectedLocation = "75 Westerdam, Nha Trang";
  final geocoding = GeoCoding(
    apiKey: 'pk.eyJ1IjoidGhvbmd0dWxlbjEzNCIsImEiOiJjbTNwOTd4dWEwY2l1MnJxMWt0dnRla2pqIn0.9o3fO8SYcsRxRYH0-Qtfhg',
    country: "vn",
    limit: 5,
    types: [PlaceType.address, PlaceType.place],
  );
  List<MapBoxPlace> _searchResults = [];

  String _removeDiacritics(String text) {
    var vietnameseMap = {
      'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ẳ|ặ|ẵ|Ă|Â|À|Á|Ạ|Ả|Ã|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ằ|Ắ|Ặ|Ẳ|Ẵ': 'a',
      'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ|È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ': 'e',
      'ì|í|ị|ỉ|ĩ|Ì|Í|Ị|Ỉ|Ĩ': 'i',
      'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ|Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ': 'o',
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

  void _showSearchScreen() {
    _searchResults.clear();
    
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
                          final response = await geocoding.getPlaces(value);
                          setModalState(() {
                            _searchResults = response.success ?? [];
                          });
                        } else {
                          setModalState(() {
                            _searchResults.clear();
                          });
                        }
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
                          final place = _searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: AppColors.primaryColor),
                            title: Text(place.placeName ?? ''),
                            subtitle: Text(place.text ?? ''),
                            onTap: () {
                              setState(() {
                                selectedLocation = place.placeName ?? '';
                              });
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
