import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  final EdgeInsetsGeometry? margin;

  const CustomSearchBar({
    Key? key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     ScreenUtil.init(context, designSize: const Size(375, 812));
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.lightGrey,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate(hintText),
          hintStyle: TextStyle(fontSize: 16.sp, color: AppColors.grey),
          labelStyle: TextStyle(fontSize: 16.sp, color: AppColors.black),
          prefixIcon: Icon(Icons.search_sharp, size: 28.sp, color: AppColors.grey,),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
} 