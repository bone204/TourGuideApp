import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'custom_bottom_bar_clip.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';

class NavigationExample extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationExample({
    super.key, 
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Container(
      height: 64.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipPath(
        clipper: CustomBottomBarClipper(),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, 
          currentIndex: currentIndex,
          onTap: onTap,
          elevation: 8,
          selectedItemColor: AppColors.primaryColor, 
          unselectedItemColor: AppColors.grey, 
          selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700), // Use ScreenUtil for font size
          unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700), // Use ScreenUtil for font size
          showUnselectedLabels: true,
          backgroundColor: Colors.white, 
          items: [
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  currentIndex == 0
                      ? Image.asset('assets/img/Logo_blue.png', width: 24.w, height: 24.h)
                      : Image.asset('assets/img/Logo_grey.png', width: 24.w, height: 24.h),
                  SizedBox(height: 4.h),
                ],
              ),
              label: AppLocalizations.of(context).translate('Home'),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, size: 24.sp),
                  SizedBox(height: 4.h),
                ],
              ),
              label: AppLocalizations.of(context).translate('Explore'),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.supervisor_account, size: 24.sp),
                  SizedBox(height: 4.h),
                ],
              ),
              label: AppLocalizations.of(context).translate('Services'),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car, size: 24.sp),
                  SizedBox(height: 4.h),
                ],
              ),
              label: AppLocalizations.of(context).translate('My Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
