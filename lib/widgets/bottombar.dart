import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'custom_bottom_bar_clip.dart'; 
import 'package:tourguideapp/localization/app_localizations.dart';

class NavigationExample extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationExample({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // Define your design size
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Container(
      height: 92.h, // Use ScreenUtil for height
      color: Colors.white, 
      child: ClipPath(
        clipper: CustomBottomBarClipper(),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, 
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: const Color(0xFF24BAEC), 
          unselectedItemColor: const Color(0xFF7D848D), 
          selectedLabelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold), // Use ScreenUtil for font size
          unselectedLabelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold), // Use ScreenUtil for font size
          showUnselectedLabels: true,
          backgroundColor: Colors.white, 
          items: [
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min, // Use min to avoid extra space
                children: [
                  const Icon(Icons.home, size: 24),
                  SizedBox(height: 8.h), // Spacing of 8 logical pixels
                ],
              ),
              label: AppLocalizations.of(context).translate('Home'),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.explore, size: 24),
                  SizedBox(height: 8.h),
                ],
              ),
              label: AppLocalizations.of(context).translate('Explore'),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.supervisor_account, size: 24),
                  SizedBox(height: 8.h),
                ],
              ),
              label: AppLocalizations.of(context).translate('Services'),
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person,size: 24),
                  SizedBox(height: 8.h),
                ],
              ),
              label: AppLocalizations.of(context).translate('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
