import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/province_model.dart';
import 'package:tourguideapp/widgets/app_bar.dart';

class ProvincePicker extends StatefulWidget {
  final Function(String, Map<String, String>) onProvinceSelected;
  final String? title;
  final String? selectedProvinceId;

  const ProvincePicker({
    Key? key,
    required this.onProvinceSelected,
    this.title,
    this.selectedProvinceId,
  }) : super(key: key);

  @override
  _ProvincePickerState createState() => _ProvincePickerState();
}

class _ProvincePickerState extends State<ProvincePicker> {
  String selectedProvinceName = "";
  String selectedProvinceId = "";
  List<Province> provinces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    if (widget.selectedProvinceId != null) {
      selectedProvinceId = widget.selectedProvinceId!;
    }
  }

  Future<void> _loadProvinces() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('PROVINCE')
          .orderBy('provinceName')
          .get();

      final loadedProvinces = snapshot.docs
          .map((doc) => Province.fromMap({
                ...doc.data(),
                'provinceId': doc.id,
              }))
          .toList();

      setState(() {
        provinces = loadedProvinces;
        isLoading = false;
      });

      // Nếu có tỉnh được chọn trước đó, cập nhật tên
      if (selectedProvinceId.isNotEmpty) {
        final selectedProvince = provinces.firstWhere(
          (province) => province.provinceId == selectedProvinceId,
          orElse: () => Province(
            provinceId: '',
            provinceName: '',
            city: '',
            district: [],
            imageUrl: '',
            rating: 0,
          ),
        );
        if (selectedProvince.provinceId.isNotEmpty) {
          selectedProvinceName = selectedProvince.provinceName;
        }
      }
    } catch (e) {
      print('Error loading provinces: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showProvinceSelectionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: CustomAppBar(
              title: AppLocalizations.of(context).translate('Choose Province'),
              onBackPressed: () => Navigator.pop(context),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: provinces.length,
                  itemBuilder: (context, index) {
                    final province = provinces[index];
                    final isSelected =
                        province.provinceId == selectedProvinceId;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            province.imageUrl,
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50.w,
                                height: 50.h,
                                color: Colors.grey[300],
                                child: Icon(Icons.location_city,
                                    color: Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          province.provinceName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          province.city,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                                size: 24.sp,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            selectedProvinceId = province.provinceId;
                            selectedProvinceName = province.provinceName;
                          });

                          widget.onProvinceSelected(
                            province.provinceName,
                            {
                              'provinceId': province.provinceId,
                              'provinceName': province.provinceName,
                              'city': province.city,
                              'district': province.district.join(', '),
                            },
                          );

                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
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
          widget.title ?? AppLocalizations.of(context).translate('Province'),
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _showProvinceSelectionScreen,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/img/ic_location.png',
                  width: 24.w,
                  height: 24.h,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    selectedProvinceName.isEmpty
                        ? AppLocalizations.of(context)
                            .translate('Select province')
                        : selectedProvinceName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: selectedProvinceName.isEmpty
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
