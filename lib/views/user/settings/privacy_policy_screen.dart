import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Privacy Policy"),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 50.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/img/ic_brand.png',
                  width: 160.w,
                  height: 60.h,
                ),
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).translate('TRAVELINE PRIVACY POLICY'),
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp, 
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).translate('Last modified on 05/09/2025'),
                  style: TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp, 
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate('1. Term 1'),
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp, 
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).translate('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viverra condimentum eget purus in. Consectetur eget id morbi amet amet, in. Ipsum viverra pretium tellus neque. Ullamcorper suspendisse aenean leo pharetra in sit semper et. Amet quam placerat sem.'),
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, 
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate('2. Term 2'),
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp, 
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).translate('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viverra condimentum eget purus in. Consectetur eget id morbi amet amet, in. Ipsum viverra pretium tellus neque. Ullamcorper suspendisse aenean leo pharetra in sit semper et. Amet quam placerat sem.'),
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, 
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate('3. Term 3'),
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp, 
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).translate('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viverra condimentum eget purus in. Consectetur eget id morbi amet amet, in. Ipsum viverra pretium tellus neque. Ullamcorper suspendisse aenean leo pharetra in sit semper et. Amet quam placerat sem.'),
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, 
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate('4. Term 4'),
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp, 
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).translate('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viverra condimentum eget purus in. Consectetur eget id morbi amet amet, in. Ipsum viverra pretium tellus neque. Ullamcorper suspendisse aenean leo pharetra in sit semper et. Amet quam placerat sem.'),
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
