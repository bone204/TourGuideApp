import 'package:flutter/material.dart';
import 'custom_bottom_bar_clip.dart'; // Import CustomBottomBarClipper

import 'package:tourguideapp/localization/app_localizations.dart';

class NavigationExample extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationExample({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0, // Chiều cao của BottomNavigationBar
      color: Colors.white, // Màu nền của BottomNavigationBar
      child: ClipPath(
        clipper: CustomBottomBarClipper(),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Đảm bảo các tab cách đều và không thay đổi kích thước
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: const Color(0xFF24BAEC), // Màu cho mục đã chọn
          unselectedItemColor: const Color(0xFF7D848D), // Màu cho mục chưa chọn
          selectedLabelStyle: const TextStyle(fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          showUnselectedLabels: true,
          backgroundColor: Colors.white, // Đặt nền của BottomNavigationBar thành trong suốt
          items:  [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context).translate('Home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore),
              label: AppLocalizations.of(context).translate('Explore'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bike_scooter),
              label: AppLocalizations.of(context).translate('Rental'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: AppLocalizations.of(context).translate('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
