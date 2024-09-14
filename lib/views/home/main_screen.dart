import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottombar.dart'; 
import 'home_screen.dart'; 
import '../explore/explore_profile.dart';
import '../user/profile_screen.dart'; 
import '../car_rental/car_rental_screen.dart';
import '../../viewmodels/profile_viewmodel.dart'; // Import ProfileViewModel

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    CarRentalScreen(),
    // ProfileScreen không cần thêm vào danh sách nếu chỉ dùng Navigation
  ];

  void _onTabTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ProfileViewModel(),
            child: ProfileScreen(),
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationExample(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
