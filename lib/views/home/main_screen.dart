import 'package:flutter/material.dart';
import 'package:tourguideapp/views/explore/explore.dart';
import 'package:tourguideapp/views/service/service_screen.dart';
import '../../widgets/bottombar.dart'; 
import 'home_screen.dart'; 
import '../user/profile_screen.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    ExploreScreen(),
    const ServiceScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
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
      body: _currentIndex != 3 ? _screens[_currentIndex] : Container(),
      bottomNavigationBar: NavigationExample(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
