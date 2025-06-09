import 'package:flutter/material.dart';
import 'package:tourguideapp/views/explore/explore.dart';
import 'package:tourguideapp/views/my_vehicle/my_vehicle_screen.dart';
import 'package:tourguideapp/views/service/service_screen.dart';
import 'package:tourguideapp/views/user/profile_screen.dart';
import '../../widgets/bottombar.dart'; 
import 'home_screen.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/blocs/auth_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Check auth status when screen loads
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const ServiceScreen(),
    const MyVehicleScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: CustomBottomBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
