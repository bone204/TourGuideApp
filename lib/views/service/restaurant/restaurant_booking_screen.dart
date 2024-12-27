import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/restaurant/restaurant_list_screen.dart';
import 'package:tourguideapp/widgets/budget_slider.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/color/colors.dart';

class RestaurantBookingScreen extends StatefulWidget {
  @override
  State<RestaurantBookingScreen> createState() => _RestaurantBookingScreenState();
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

  void onLoctaionSelected(String location, Map<String, String> details) {
    setState(() {
      selectedProvince = [
        details['province'],
        details['city'],
        details['district']
      ].where((s) => s != null && s.isNotEmpty).join(", ");
      locationDetails = details;
    });
  }

  Widget _buildSpecialtyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate("Specialty"),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
                      AppLocalizations.of(context).translate("Select Specialty"),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).translate("Restaurant Booking"),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate("Budget"),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
            LocationPicker(
              title: AppLocalizations.of(context).translate("Location"),
              onLocationSelected: onLoctaionSelected,
            ),
            SizedBox(height: 50.h),
            CustomElevatedButton(
              text: "Confirm",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantListScreen(),
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
