import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/views/settings/setting_screen.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../auth/login_screen.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/interactive_row_widget.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.13),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: Icons.chevron_left,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    AppLocalizations.of(context).translate('Profile'),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.05),
                  ),
                  CustomIconButton(
                    icon: Icons.edit,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit button pressed')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.01),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                Text(
                  profileViewModel.name,
                  style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  profileViewModel.email,
                  style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey),
                ),
                SizedBox(height: screenHeight * 0.035),
                _buildStatsRow(context, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.015),
                Expanded(
                  child: ListView(
                    children: [
                      _buildInteractiveRow(context, Icons.location_pin, 'Favourite Destinations'),
                      _buildInteractiveRow(context, Icons.history, 'Travel History'),
                      _buildInteractiveRow(context, Icons.car_crash, 'Vehicle Rental Registration'),
                      _buildInteractiveRow(context, Icons.feedback, 'Feedback'),
                      _buildInteractiveRow(context, Icons.settings, 'Settings', navigateToSettings: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(0, screenHeight * 0.015, 0, screenHeight * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatsColumn(context, AppLocalizations.of(context).translate('Reward Points'), '360', screenWidth),
          const SizedBox(width: 25),
          _buildStatsColumn(context, AppLocalizations.of(context).translate('Travel Trips'), '238', screenWidth),
          const SizedBox(width: 25),
          _buildStatsColumn(context, AppLocalizations.of(context).translate('Bucket Lists'), '473', screenWidth),
        ],
      ),
    );
  }

  Widget _buildStatsColumn(BuildContext context, String title, String value, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            color: Color(0xFFFF7029),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveRow(BuildContext context, IconData leadingIcon, String title, {bool navigateToSettings = false}) {
    return InteractiveRowWidget(
      leadingIcon: leadingIcon,
      title: AppLocalizations.of(context).translate(title),
      trailingIcon: Icons.chevron_right,
      onTap: () {
        if (navigateToSettings) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Row clicked')),
          );
        }
      },
    );
  }
}
