import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/province_model.dart';

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

class _LocationSearchScreen extends StatefulWidget {
  final Function(String, Map<String, String>) onLocationSelected;

  const _LocationSearchScreen({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<_LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationOption> _locationOptions = [];
  List<LocationOption> _filteredOptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('PROVINCE')
          .get();
      
      List<LocationOption> options = [];
      
      for (var doc in snapshot.docs) {
        final province = Province.fromMap({
          ...doc.data(),
          'provinceId': doc.id,
        });
        
        // Thêm Province-City nếu có city
        if (province.city.isNotEmpty) {
          options.add(LocationOption(
            province: province.provinceName,
            city: province.city,
            district: '',
          ));
        }

        // Thêm Province-District cho từng district (không thêm city)
        if (province.district.isNotEmpty) {
          for (String district in province.district) {
            options.add(LocationOption(
              province: province.provinceName,
              city: '',
              district: district,
            ));
          }
        }

        // Nếu không có cả city và district, chỉ thêm province
        if (province.city.isEmpty && province.district.isEmpty) {
          options.add(LocationOption(
            province: province.provinceName,
            city: '',
            district: '',
          ));
        }
      }
      
      setState(() {
        _locationOptions = options;
        _filteredOptions = [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading locations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = [];
      } else {
        final searchStr = query.toLowerCase().trim();
        
        // Tạo danh sách kết quả tìm kiếm với độ ưu tiên mới
        List<LocationOption> districtMatches = [];
        List<LocationOption> cityMatches = [];
        List<LocationOption> provinceMatches = [];

        for (var option in _locationOptions) {
          // Kiểm tra nếu text bắt đầu bằng query
          if (option.district.toLowerCase().startsWith(searchStr)) {
            districtMatches.add(option);
          } else if (option.city.toLowerCase().startsWith(searchStr)) {
            cityMatches.add(option);
          } else if (option.province.toLowerCase().startsWith(searchStr)) {
            provinceMatches.add(option);
          }
        }

        // Kết hợp các kết quả theo thứ tự ưu tiên mới
        _filteredOptions = [
          ...districtMatches,
          ...cityMatches,
          ...provinceMatches,
        ];

        // N���u không có kết quả nào bắt đầu bằng query, tìm kiếm các từ chứa query
        if (_filteredOptions.isEmpty && searchStr.length >= 2) {
          for (var option in _locationOptions) {
            if (option.district.toLowerCase().contains(searchStr)) {
              districtMatches.add(option);
            } else if (option.city.toLowerCase().contains(searchStr)) {
              cityMatches.add(option);
            } else if (option.province.toLowerCase().contains(searchStr)) {
              provinceMatches.add(option);
            }
          }

          _filteredOptions = [
            ...districtMatches,
            ...cityMatches,
            ...provinceMatches,
          ];
        }
      }
    });
  }

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
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
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
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('Search location'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onChanged: _filterLocations,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredOptions.length,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: AppColors.primaryColor),
                          title: Text(
                            option.district.isNotEmpty 
                                ? option.district 
                                : option.city.isNotEmpty 
                                    ? option.city 
                                    : option.province,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          subtitle: option.district.isNotEmpty || option.city.isNotEmpty 
                              ? Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text(
                                    option.province,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                )
                              : null,
                          onTap: () {
                            final details = {
                              'province': option.province,
                              'city': option.city,
                              'district': option.district,
                            };
                            String displayLocation;
                            if (option.city.isNotEmpty) {
                              displayLocation = "${option.province}, ${option.city}";
                            } else if (option.district.isNotEmpty) {
                              displayLocation = "${option.province}, ${option.district}";
                            } else {
                              displayLocation = option.province;
                            }
                            widget.onLocationSelected(displayLocation, details);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _LocationPickerState extends State<LocationPicker> {
  String selectedLocation = "";
  Map<String, String> locationDetails = {
    'province': '',
    'city': '',
    'district': '',
  };

  void _showSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LocationSearchScreen(
          onLocationSelected: (location, details) {
            setState(() {
              selectedLocation = location;
              locationDetails = details;
            });
            widget.onLocationSelected(location, details);
          },
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
                      fontWeight: selectedLocation.isEmpty ? FontWeight.w600 : FontWeight.normal,
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
