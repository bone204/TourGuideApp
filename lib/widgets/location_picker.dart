import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart'; 

class LocationPicker extends StatelessWidget {
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
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, size: 24.sp),
              SizedBox(width: 12.w),
              SizedBox(
                width: 170.w,
                child: Text(
                  "75 Westerdam, Nha Trang",
                  style: TextStyle(fontSize: 14.sp),
                  overflow: TextOverflow.ellipsis, 
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
