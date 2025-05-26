import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class InfoTextField extends StatelessWidget {
  final String labelText;
  final String text;
  final IconData icon;
  final int size;

  const InfoTextField({
    required this.labelText,
    required this.text,
    required this.icon,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate(labelText),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 12.h),
        Container(
          width: size.w,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  text,
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
