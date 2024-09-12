import 'package:flutter/material.dart';
import 'custom_bottom_bar_clip.dart'; // Import CustomBottomBarClipper

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
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: const Color(0xFF24BAEC), // Màu cho mục đã chọn
          unselectedItemColor: const Color(0xFF7D848D), // Màu cho mục chưa chọn
          selectedLabelStyle: const TextStyle(fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          showUnselectedLabels: true,
          backgroundColor: Colors.white, // Đặt nền của BottomNavigationBar thành trong suốt
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
