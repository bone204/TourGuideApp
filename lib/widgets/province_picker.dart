import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/province_model.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';

class ProvincePicker extends StatefulWidget {
  final Function(Map<String, String>) onRegionSelected;
  final String? title;

  const ProvincePicker({
    Key? key,
    required this.onRegionSelected,
    this.title,
  }) : super(key: key);

  @override
  _ProvincePickerState createState() => _ProvincePickerState();
}

class _ProvinceSearchScreen extends StatefulWidget {
  final Function(Map<String, String>) onRegionSelected;

  const _ProvinceSearchScreen({
    Key? key,
    required this.onRegionSelected,
  }) : super(key: key);

  @override
  _ProvinceSearchScreenState createState() => _ProvinceSearchScreenState();
}

class _ProvinceSearchScreenState extends State<_ProvinceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationOption> _locationOptions = [];
  List<LocationOption> _filteredOptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
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
        
        // Thêm City-Province nếu có city
        if (province.city.isNotEmpty) {
          options.add(LocationOption(
            province: province.provinceName,
            city: province.city,
            district: '', // District rỗng khi có city
          ));
        }

        // Thêm District-Province cho từng district
        for (String district in province.district) {
          options.add(LocationOption(
            province: province.provinceName,
            city: '', // City rỗng khi có district
            district: district,
          ));
        }
      }
      
      setState(() {
        _locationOptions = options;
        _filteredOptions = [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading provinces: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Thêm hàm để chuẩn hóa chuỗi (bỏ dấu và chuyển về lowercase)
  String _normalizeString(String str) {
    // Chuyển đổi các ký tự có dấu thành không dấu
    final vietnamese = 'aáàảãạăắằẳẵặâấầẩẫậđeéèẻẽẹêếềểễệiíìỉĩịoóòỏõọôốồổỗộơớờởỡợuúùủũụưứừửữựyýỳỷỹỵ';
    final latin = 'aaaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiioooooooooooooooooouuuuuuuuuuuyyyyy';
    
    String result = str.toLowerCase();
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], latin[i ~/ 6]);
    }
    return result;
  }

  // Hàm xử lý tên thành phố (bỏ "TP. ", "Thành phố ")
  String _processCityName(String city) {
    return city.replaceAll(RegExp(r'^(TP\.|Thành phố\s+)'), '').trim();
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = [];
      } else {
        final normalizedQuery = _normalizeString(query);
        
        // Tìm các kết quả match với query (có dấu hoặc không dấu)
        _filteredOptions = _locationOptions.where((option) {
          // Chuẩn hóa các chuỗi để so sánh
          final normalizedDistrict = _normalizeString(option.district);
          final normalizedCity = _normalizeString(_processCityName(option.city));
          final normalizedProvince = _normalizeString(option.province);
          
          // Kiểm tra xem query có match với bất kỳ phần nào không
          return normalizedDistrict.contains(normalizedQuery) ||
                 normalizedCity.contains(normalizedQuery) ||
                 normalizedProvince.contains(normalizedQuery);
        }).toList();

        // Sắp xếp kết quả theo độ ưu tiên
        _filteredOptions.sort((a, b) {
          // Chuẩn hóa các chuỗi để so sánh
          final normalizedQuery = _normalizeString(query);
          final aDistrict = _normalizeString(a.district);
          final aCity = _normalizeString(_processCityName(a.city));
          final aProvince = _normalizeString(a.province);
          final bDistrict = _normalizeString(b.district);
          final bCity = _normalizeString(_processCityName(b.city));
          final bProvince = _normalizeString(b.province);

          // Ưu tiên theo thứ tự: starts with > contains
          // Và theo cấp độ: district > city > province
          bool aStartsWithDistrict = aDistrict.startsWith(normalizedQuery);
          bool bStartsWithDistrict = bDistrict.startsWith(normalizedQuery);
          bool aStartsWithCity = aCity.startsWith(normalizedQuery);
          bool bStartsWithCity = bCity.startsWith(normalizedQuery);
          bool aStartsWithProvince = aProvince.startsWith(normalizedQuery);
          bool bStartsWithProvince = bProvince.startsWith(normalizedQuery);

          // So sánh theo thứ tự ưu tiên
          if (aStartsWithDistrict != bStartsWithDistrict) {
            return aStartsWithDistrict ? -1 : 1;
          }
          if (aStartsWithCity != bStartsWithCity) {
            return aStartsWithCity ? -1 : 1;
          }
          if (aStartsWithProvince != bStartsWithProvince) {
            return aStartsWithProvince ? -1 : 1;
          }

          // Nếu cùng mức độ ưu tiên, sắp xếp theo độ dài để ưu tiên kết quả ngắn hơn
          return a.district.length.compareTo(b.district.length);
        });
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
                          AppLocalizations.of(context).translate('Choose Region'),
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
            CustomSearchBar(
              controller: _searchController,
              hintText: 'Search region',
              onChanged: _filterLocations,
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                            option.district.isNotEmpty ? option.district : option.city,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          subtitle: Text(
                            option.province,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          onTap: () {
                            widget.onRegionSelected({
                              'province': option.province,
                              'city': option.city,
                              'district': option.district,
                            });
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

class _ProvincePickerState extends State<ProvincePicker> {
  String selectedLocation = "";

  void _showSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProvinceSearchScreen(
          onRegionSelected: (details) {
            setState(() {
              selectedLocation = (details['district'] ?? '').isNotEmpty 
                  ? '${details['district']}, ${details['province']}'
                  : '${details['city']}, ${details['province']}';
            });
            widget.onRegionSelected(details);
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
          widget.title ?? AppLocalizations.of(context).translate('Administrative Region'),
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
                Icon(Icons.location_city, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    selectedLocation.isEmpty 
                        ? AppLocalizations.of(context).translate('Select region')
                        : selectedLocation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: selectedLocation.isEmpty ? Colors.grey : Colors.black,
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

class LocationOption {
  final String province;
  final String city;
  final String district;

  LocationOption({
    required this.province,
    required this.city,
    required this.district,
  });
} 