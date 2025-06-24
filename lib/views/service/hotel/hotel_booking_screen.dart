import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/hotel/hotel_list_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/budget_slider.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';
import 'package:tourguideapp/widgets/disable_textfield.dart';
import 'package:tourguideapp/widgets/province_picker.dart';
import 'package:tourguideapp/widgets/custom_elevated_button.dart';

class HotelBookingScreen extends StatefulWidget {
  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  DateTime startDate = DateTime.now().add(const Duration(days: 1));
  DateTime endDate = DateTime.now().add(const Duration(days: 2));
  double minBudget = 0;
  double maxBudget = 1000000;
  String selectedProvince = '';
  String selectedProvinceId = '';
  Map<String, String> locationDetails = {};
  String? selectedGuests;
  final List<String> guestOptions = ['1', '2', '3', '4', '5', '6'];

  String get duration {
    final difference = endDate.difference(startDate).inDays;
    final contextLocale = AppLocalizations.of(context);
    final dayText = contextLocale.translate("day");
    return '$difference $dayText';
  }

  @override
  void initState() {
    super.initState();
    // Mặc định chọn 2 khách
    selectedGuests = '2';
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
      selectedProvinceId = details['provinceId'] ?? '';
      locationDetails = details;
    });
  }

  bool get isFormValid {
    return selectedProvince.isNotEmpty &&
        selectedGuests != null &&
        selectedGuests!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Hotel Booking"),
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
              type: 'hotel',
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
                        // Đảm bảo check-out luôn sau check-in ít nhất 1 ngày
                        if (endDate
                            .isBefore(startDate.add(const Duration(days: 1)))) {
                          endDate = startDate.add(const Duration(days: 1));
                        }
                      });
                    },
                    title: "Check-in Date",
                    firstDate: DateTime.now().add(const Duration(
                        days: 1)), // Không cho chọn ngày hôm nay trở về trước
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate("Guests"),
                        style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w700),
                      ),  
                      SizedBox(height: 8.h),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: (int.parse(selectedGuests!) > 1)
                                  ? () {
                                      setState(() {
                                        selectedGuests = (int.parse(selectedGuests!) - 1).toString();
                                      });
                                    }
                                  : null,
                              child: Container(
                                width: 24.w,
                                height: 24.h,
                                child: Icon(
                                  Icons.remove,
                                  size: 16.sp,
                                  color: (int.parse(selectedGuests!) > 1) ? AppColors.red : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              selectedGuests ?? '1',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: (int.parse(selectedGuests!) < 6)
                                  ? () {
                                      setState(() {
                                        selectedGuests = (int.parse(selectedGuests!) + 1).toString();
                                      });
                                    }
                                  : null,
                              child: Container(
                                width: 24.w,
                                height: 24.h,
                                child: Icon(
                                  Icons.add,
                                  size: 16.sp,
                                  color: (int.parse(selectedGuests!) < 6) ? AppColors.red : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        // Chỉ cho phép chọn ngày sau check-in
                        if (date.isAfter(startDate)) {
                          endDate = date;
                        }
                      });
                    },
                    title: "Check-out Date",
                    firstDate: startDate.add(const Duration(days: 1)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: DisabledTextField(
                    labelText:
                        AppLocalizations.of(context).translate("Duration"),
                    text: duration,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            ProvincePicker(
              title: AppLocalizations.of(context).translate("Province"),
              onProvinceSelected: onProvinceSelected,
              selectedProvinceId:
                  selectedProvinceId.isNotEmpty ? selectedProvinceId : null,
            ),
            SizedBox(height: 50.h),
            CustomElevatedButton(
              text: "Confirm",
              onPressed: isFormValid
                  ? () {
                      // Truyền thông tin tìm kiếm đến màn hình danh sách khách sạn
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelListScreen(
                            searchParams: {
                              'province': selectedProvince,
                              'provinceId': selectedProvinceId,
                              'minBudget': minBudget,
                              'maxBudget': maxBudget,
                              'guests': int.parse(selectedGuests!),
                              'checkInDate': startDate,
                              'checkOutDate': endDate,
                              'duration': endDate.difference(startDate).inDays,
                            },
                          ),
                        ),
                      );
                    }
                  : () {},
            ),
          ],
        ),
      ),
    );
  }
}
