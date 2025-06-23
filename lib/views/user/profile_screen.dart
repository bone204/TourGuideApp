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
    ScreenUtil.init(context, designSize: const Size(375, 812)); 
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
                                  color: const Color(0xFF000000).withOpacity(0.15),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withOpacity(0.25),
                                        blurRadius: 16.r,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: AppColors.primaryColor.withOpacity(0.2),
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 48.r,
                                    backgroundImage: NetworkImage(profileViewModel.avatar),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      const AssetImage('assets/img/bg_route_1.png');
                                    },
                                  ),
                                ),
                                SizedBox(width: 18.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              profileViewModel.name,
                                              style: TextStyle(
                                                fontSize: 22.sp,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // Nút chỉnh sửa thông tin (nếu muốn)
                                          /*IconButton(
                                            icon: Icon(Icons.edit, size: 20.sp, color: AppColors.primaryColor),
                                            onPressed: () {},
                                            tooltip: 'Chỉnh sửa',
                                          ),*/
                                        ],
                                      ),
                                      SizedBox(height: 6.h),
                                      _buildTierBadge(context, profileViewModel.userTier),
                                      SizedBox(height: 10.h),
                                      Row(
                                        children: [
                                          Icon(Icons.email, size: 16.sp, color: Colors.grey[600]),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Text(
                                              profileViewModel.email,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 15.sp, color: AppColors.primaryColor),
                                          SizedBox(width: 6.w),
                                          Text(
                                            _getMemberSinceText(context, profileViewModel.createdAt),
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatsColumn(
            context, 
            AppLocalizations.of(context).translate('Travel Points'), 
            profileViewModel.travelPoint.toString(),
            Icons.star,
          ),
          _buildStatsColumn(
            context, 
            AppLocalizations.of(context).translate('Travel Trips'), 
            profileViewModel.travelTrip.toString(),
            Icons.flight_takeoff,
          ),
          _buildStatsColumn(
            context, 
            AppLocalizations.of(context).translate('Reviews'), 
            profileViewModel.feedbackTimes.toString(),
            Icons.rate_review,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsColumn(BuildContext context, String title, String value, IconData icon) {
    return Container(
      width: 104.w,
      height: 130.h,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            Color(0xFF0056b3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.15),
            blurRadius: 8.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.yellow,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              color: AppColors.yellow,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(BuildContext context, String tier) {
    final locale = Localizations.localeOf(context).languageCode;
    Color bgColor;
    IconData icon;
    String label;
    switch (tier) {
      case 'Bronze':
        bgColor = Color(0xFFCD7F32);
        icon = Icons.emoji_events;
        label = locale == 'vi' ? 'Thành viên Đồng' : 'Bronze Member';
        break;
      case 'Silver':
        bgColor = Color(0xFFC0C0C0);
        icon = Icons.emoji_events;
        label = locale == 'vi' ? 'Thành viên Bạc' : 'Silver Member';
        break;
      case 'Gold':
        bgColor = Color(0xFFFFD700);
        icon = Icons.emoji_events;
        label = locale == 'vi' ? 'Thành viên Vàng' : 'Gold Member';
        break;
      case 'Platinum':
        bgColor = Color(0xFFE5E4E2);
        icon = Icons.workspace_premium;
        label = locale == 'vi' ? 'Thành viên Bạch Kim' : 'Platinum Member';
        break;
      default:
        bgColor = AppColors.primaryColor;
        icon = Icons.verified_user;
        label = tier;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.25),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _getMemberSinceText(BuildContext context, DateTime? createdAt) {
    final locale = Localizations.localeOf(context).languageCode;
    if (createdAt == null) {
      return locale == 'vi'
          ? 'Thành viên được ${0} ngày'
          : 'Member for ${0} days';
    }
    final now = DateTime.now();
    final days = now.difference(createdAt).inDays + 1;
    return locale == 'vi'
        ? 'Thành viên được $days ngày'
        : 'Member for $days days';
  }
}