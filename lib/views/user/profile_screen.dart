import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/views/settings/setting_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../auth/login_screen.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/interactive_row_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812)); // Thiết lập kích thước màn hình
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h), 
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
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.sp),
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                SizedBox(height: 16.h),
                Text(
                  profileViewModel.name,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  profileViewModel.email,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(height: 34.h),
                _buildStatsRow(context),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView(
                    children: [
                      _buildInteractiveRow(context, Icons.location_pin, 'Favourite Destinations'),
                      SizedBox(height: 16.h),
                      _buildInteractiveRow(context, Icons.history, 'Travel History'),
                      SizedBox(height: 16.h),
                      _buildInteractiveRow(context, Icons.car_crash, 'Vehicle Rental Registration'),
                      SizedBox(height: 16.h),
                      _buildInteractiveRow(context, Icons.feedback, 'Feedback'),
                      SizedBox(height: 16.h),
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

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),  // Sử dụng ScreenUtil để điều chỉnh bo góc
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatsColumn(context, AppLocalizations.of(context).translate('Reward Points'), '360'),
          SizedBox(width: 25.w),
          _buildStatsColumn(context, AppLocalizations.of(context).translate('Travel Trips'), '238'),
          SizedBox(width: 25.w),
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
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFFFF7029),
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
