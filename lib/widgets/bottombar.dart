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
      height: 92.0, 
      color: Colors.white, 
      child: ClipPath(
        clipper: CustomBottomBarClipper(),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, 
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: const Color(0xFF24BAEC), 
          unselectedItemColor: const Color(0xFF7D848D), 
          selectedLabelStyle: const TextStyle(fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          showUnselectedLabels: true,
          backgroundColor: Colors.white, 
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
