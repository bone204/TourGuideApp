import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/views/user/favourite_destinations/favourite_destinations.dart';
import 'package:tourguideapp/views/user/help_center/help_screen.dart';
import 'package:tourguideapp/views/user/settings/setting_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/user/travel_history/travel_history_screen.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../auth/login_screen.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/interactive_row_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';

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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 160.h,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.zero, topRight: Radius.zero, bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF66B2FF),
                          Color(0xFF007BFF),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 335.w,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r), 
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: const Color(0xFF000000).withOpacity(0.25),
                                  blurRadius: 4.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(
                                    profileViewModel.avatar,
                                  ),
                                  onBackgroundImageError: (exception, stackTrace) {
                                    // Fallback nếu load ảnh thất bại
                                    const AssetImage('assets/img/bg_route_1.png');
                                  },
                                ),
                                SizedBox(width: 20.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profileViewModel.name,
                                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      profileViewModel.email,
                                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _buildStatsRow(context),
                          SizedBox(height: 20.h),
                          Text(
                            AppLocalizations.of(context).translate('Member Features'),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 16.h),
                          Expanded(
                            child: ListView(
                              children: [
                                InteractiveRowWidget(
                                  leadingIcon: Icons.location_pin,
                                  title: AppLocalizations.of(context).translate('Favourite Destinations'),
                                  trailingIcon: Icons.chevron_right,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const FavouriteDestinationsScreen()),
                                    );
                                  },
                                ),
                                SizedBox(height: 16.h),
                                InteractiveRowWidget(
                                  leadingIcon: Icons.history,
                                  title: AppLocalizations.of(context).translate('Travel History'),
                                  trailingIcon: Icons.chevron_right,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const TravelHistoryScreen()),
                                    );
                                  },
                                ),
                                SizedBox(height: 16.h),
                                InteractiveRowWidget(
                                  leadingIcon: Icons.help_center,
                                  title: AppLocalizations.of(context).translate('Help Center'),
                                  trailingIcon: Icons.chevron_right,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HelpScreen()),
                                    );
                                  },
                                ),
                                SizedBox(height: 16.h),
                                InteractiveRowWidget(
                                  leadingIcon: Icons.settings,
                                  title: AppLocalizations.of(context).translate('Settings'),
                                  trailingIcon: Icons.chevron_right,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
            ),
          );
        }
        return LoginScreen(); // Redirect to login if not authenticated
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatsColumn(
          context, 
          AppLocalizations.of(context).translate('Travel Points'), 
          profileViewModel.travelPoint.toString()
        ),
        _buildStatsColumn(
          context, 
          AppLocalizations.of(context).translate('Travel Trips'), 
          profileViewModel.travelTrip.toString()
        ),
        _buildStatsColumn(
          context, 
          AppLocalizations.of(context).translate('Reviews'), 
          profileViewModel.feedbackTimes.toString()
        ),
      ],
    );
  }

  Widget _buildStatsColumn(BuildContext context, String title, String value) {
    return Container(
      width: 104.w,
      height: 100.h,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r), 
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF000000).withOpacity(0.25),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            width: 90.w,
            child: Text(
              title,
              style: TextStyle(fontSize: 13.sp, color: AppColors.white,fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              color: AppColors.yellow,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}