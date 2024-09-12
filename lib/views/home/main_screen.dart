import 'package:flutter/material.dart';
import '../../widgets/bottombar.dart'; // Import NavigationExample
import 'home_screen.dart'; // Import HomeScreen
import '../explore/explore_profile.dart';
import '../user/profile_screen.dart'; // Import ProfileScreen

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình mà bạn muốn điều hướng tới
  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    const ProfileScreen(),
    // Thêm các màn hình khác vào đây
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], 
      bottomNavigationBar: NavigationExample( // Sử dụng NavigationExample cho BottomNavigationBar
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
