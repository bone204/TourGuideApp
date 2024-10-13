import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/textfield.dart';

class VehicleRentalDetail extends StatelessWidget {
  final String model;
  final String imagePath;
  final DateTime startDate;
  final DateTime endDate;

  const VehicleRentalDetail({
    Key? key,
    required this.model,
    required this.imagePath,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  String _getDayAbbreviation(DateTime date, BuildContext context) {
    List<String> daysVi = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    List<String> daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    String languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'vi') {
      return daysVi[date.weekday % 7];
    } else {
      return daysEn[date.weekday % 7];
    }
  }

  String _getDurationText(BuildContext context, int durationDays) {
    String languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'vi') {
      return "$durationDays ${durationDays == 1 ? 'ngày' : 'ngày'}"; // "1 ngày" hoặc "2 ngày"
    } else {
      return "$durationDays ${durationDays == 1 ? 'day' : 'days'}"; // "1 day" hoặc "2 days"
    }
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                        AppLocalizations.of(context).translate(model),
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
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                child: Image.asset(
                  imagePath,
                  height: 140.h,
                  width: 260.w,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).translate("Specs"),
              style: TextStyle(
                  fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildInteractiveRow(
                      context,
                      AppLocalizations.of(context).translate("Power"),
                      'Detail 1'),
                  SizedBox(width: 16.w),
                  _buildInteractiveRow(
                      context,
                      AppLocalizations.of(context).translate("Max Speed"),
                      'Detail 2'),
                  SizedBox(width: 16.w),
                  _buildInteractiveRow(
                      context,
                      AppLocalizations.of(context).translate("Acceleration"),
                      'Detail 3'),
                ],
              ),
            ),
            SizedBox(height: 26.h),
            InfoTextField(
              size: 335,
              labelText: AppLocalizations.of(context).translate("Location"),
              text: "VCLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL",
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: 26.h),
            Row(
              children: [
                InfoTextField(
                  size: 186,
                  labelText: AppLocalizations.of(context).translate("Start Date"),
                  text:
                      "${_getDayAbbreviation(startDate, context)}, ${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}",
                  icon: Icons.calendar_month,
                ),
                SizedBox(width: 11.h),
                InfoTextField(
                  size: 137,
                  labelText: AppLocalizations.of(context).translate("Duration"),
                  text: _getDurationText(context, endDate.difference(startDate).inDays + 1), // Hiển thị số ngày với văn bản thích hợp
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
            SizedBox(height: 26.h),
            Row(
              children: [
                InfoTextField(
                  size: 186,
                  labelText: AppLocalizations.of(context).translate("End Date"),
                  text:
                      "${_getDayAbbreviation(endDate, context)}, ${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}",
                  icon: Icons.calendar_month,
                ),
                SizedBox(width: 11.h),
                InfoTextField(
                  size: 137,
                  labelText: AppLocalizations.of(context).translate("Pick-up Time"),
                  text: "08:00 AM",
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
            SizedBox(height: 26.h),
            ElevatedButton(
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text(
                AppLocalizations.of(context).translate("Confirm"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                )
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveRow(BuildContext context, String title, String detail) {
    return Container(
      width: 155.w,
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0ff00000).withOpacity(0.25),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 110.w,
            child: Text(
              detail,
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
