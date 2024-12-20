import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/hotel/hotel_list_screen.dart';
import 'package:tourguideapp/widgets/budget_slider.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/disable_textfield.dart';
import 'package:tourguideapp/widgets/location_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';
import 'package:tourguideapp/widgets/custom_combo_box.dart';

class HotelBookingScreen extends StatefulWidget {
  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  String selectedRentOption = 'Daily';
  double minBudget = 0;
  double maxBudget = 1000000;
  String selectedProvince = '';
  String? selectedGuests;
  final List<String> guestOptions = ['1', '2', '3', '4', '5', '6'];

  String get duration {
    final difference = endDate.difference(startDate).inDays;
    return '$difference ${difference > 1 ? 'days' : 'day'}';
  }

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

  void onProvinceSelected(String province) {
    setState(() {
      selectedProvince = province;
    });
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
                        AppLocalizations.of(context).translate("Hotel Booking"),
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
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 28.h),
            BudgetSlider(
              onBudgetChanged: onBudgetChanged,
              initialMin: minBudget,
              initialMax: maxBudget,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DateTimePicker(
                    selectedDate: startDate,
                    onDateSelected: (date) {
                      setState(() {
                        startDate = date;
                        if (endDate.isBefore(startDate)) {
                          endDate = startDate.add(const Duration(days: 1));
                        }
                      });
                    },
                    title: "Check-in Date",
                    rentOption: selectedRentOption,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate("Guests"),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      CustomComboBox(
                        hintText: "Select",
                        value: selectedGuests,
                        items: guestOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedGuests = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DateTimePicker(
                    selectedDate: endDate,
                    onDateSelected: (date) {
                      setState(() {
                        if (date.isAfter(startDate)) {
                          endDate = date;
                        }
                      });
                    },
                    title: "Check-out Date",
                    rentOption: selectedRentOption,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: DisabledTextField(
                    labelText: AppLocalizations.of(context).translate("Duration"),
                    text: duration,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            LocationPicker(
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
                    builder: (context) => HotelListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
