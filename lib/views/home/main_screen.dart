import 'package:flutter/material.dart';
import '../../widgets/bottombar.dart'; 
import 'home_screen.dart'; 
import '../explore/explore_profile.dart';
import '../user/profile_screen.dart'; 

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0; 

  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) { 
      _previousIndex = _currentIndex; 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(),
        ),
      ).then((_) {
        setState(() {
          _currentIndex = _previousIndex; 
        });
      });
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
