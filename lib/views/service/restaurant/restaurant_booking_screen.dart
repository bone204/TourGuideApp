import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/restaurant/restaurant_list_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/budget_slider.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/province_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class RestaurantBookingScreen extends StatefulWidget {
  @override
  State<RestaurantBookingScreen> createState() =>
      _RestaurantBookingScreenState();
}

class _RestaurantBookingScreenState extends State<RestaurantBookingScreen> {
  DateTime checkTime = DateTime.now();
  double minBudget = 0;
  double maxBudget = 1000000;
  String selectedProvince = '';
  String? selectedSpecialty;
  Map<String, String> locationDetails = {};
  final List<String> specialtyOptions = [
    'Vietnamese Cuisine',
    'Japanese Cuisine',
    'Korean Cuisine',
    'Chinese Cuisine',
    'Western Cuisine',
    'Seafood'
  ];

  @override
  void initState() {
    super.initState();
  }

  void onBudgetChanged(double min, double max) {
    setState(() {
      minBudget = min;
      maxBudget = max;
    });
  }

  void onProvinceSelected(String provinceName, Map<String, String> details) {
    setState(() {
      selectedProvince = provinceName;
      locationDetails = details;
    });
  }

  Widget _buildSpecialtyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate("Specialty"),
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/img/ic_specialty.png',
                width: 24.w,
                height: 24.h,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSpecialty,
                    hint: Text(
                      AppLocalizations.of(context)
                          .translate("Select Specialty"),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    items: specialtyOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          AppLocalizations.of(context).translate(value),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedSpecialty = newValue;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Restaurant Booking"),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate("Budget"),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 28.h),
            BudgetSlider(
              onBudgetChanged: onBudgetChanged,
              initialMin: minBudget,
              initialMax: maxBudget,
              type: 'restaurant',
            ),
            SizedBox(height: 24.h),
            DateTimePicker(
              selectedDate: checkTime,
              onDateSelected: (date) {
                setState(() {
                  checkTime = date;
                });
              },
              title: "Check-in Time",
            ),
            SizedBox(height: 24.h),
            _buildSpecialtyPicker(),
            SizedBox(height: 24.h),
            ProvincePicker(
              title: AppLocalizations.of(context).translate("Location"),
              onProvinceSelected: onProvinceSelected,
            ),
            SizedBox(height: 50.h),
            CustomElevatedButton(
              text: "Confirm",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantListScreen(
                      selectedProvince: selectedProvince,
                      selectedSpecialty: selectedSpecialty,
                      minBudget: minBudget,
                      maxBudget: maxBudget,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
