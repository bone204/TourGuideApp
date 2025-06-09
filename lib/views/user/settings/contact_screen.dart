import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Contact Us"),
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
                  AppLocalizations.of(context).translate('Mobile application to support tourists in Vietnam'),
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp, 
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate('Version: 1.0.0'),
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, 
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).translate('Last updated 05/29/2025'),
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, 
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '1. ${AppLocalizations.of(context).translate('Contact Us')}',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp, 
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).translate('Hotline: 0971072923'),
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, 
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).translate('Supporter name: Tran Trung Thong'),
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp, 
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '2. ${AppLocalizations.of(context).translate('Other information')}',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp, 
                ),
              ),
              SizedBox(height: 8.h),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: AppLocalizations.of(context).translate('Check out our support center '),
                      style: TextStyle(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp, 
                      ),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context).translate('here'),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp, 
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
