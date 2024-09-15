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
      return const SizedBox.shrink(); // Trả về widget trống trong khi chuyển hướng
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
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
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CustomIconButton(
                    icon: Icons.edit,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nút chỉnh sửa đã được bấm')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
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
                const SizedBox(height: 20),
                Text(
                  profileViewModel.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  profileViewModel.email,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                _buildStatsRow(context),
                const SizedBox(height: 20),
                InteractiveRowWidget(
                  leadingIcon: Icons.location_pin,
                  title: AppLocalizations.of(context).translate('Favourite Destinations'),
                  trailingIcon: Icons.chevron_right,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications clicked')),
                    );
                  },
                ),
                const SizedBox(height: 5),
                InteractiveRowWidget(
                  leadingIcon: Icons.history,
                  title: AppLocalizations.of(context).translate('Travel History'),
                  trailingIcon: Icons.chevron_right,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications clicked')),
                    );
                  },
                ),
                const SizedBox(height: 5),
                InteractiveRowWidget(
                  leadingIcon: Icons.car_crash,
                  title: AppLocalizations.of(context).translate('Vehicle Rental Registration'),
                  trailingIcon: Icons.chevron_right,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications clicked')),
                    );
                  },
                ),
                const SizedBox(height: 5),
                InteractiveRowWidget(
                  leadingIcon: Icons.feedback,
                  title: AppLocalizations.of(context).translate('Feedback'),
                  trailingIcon: Icons.chevron_right,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications clicked')),
                    );
                  },
                ),
                const SizedBox(height: 5),
                InteractiveRowWidget(
                  leadingIcon: Icons.settings,
                  title: AppLocalizations.of(context).translate('Settings'),
                  trailingIcon: Icons.chevron_right,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatsColumn(context, AppLocalizations.of(context).translate('Reward Points'), '360'),
          const SizedBox(width: 30),
          _buildStatsColumn(context, AppLocalizations.of(context).translate('Travel Trips'), '238'),
          const SizedBox(width: 30),
          _buildStatsColumn(context, AppLocalizations.of(context).translate('Bucket Lists'), '473'),
        ],
      ),
    );
  }

  Widget _buildStatsColumn(BuildContext context, String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFFF7029),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
