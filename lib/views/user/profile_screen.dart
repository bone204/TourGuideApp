import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/views/favourite_destinations/favourite_destinations.dart';
import 'package:tourguideapp/views/my_vehicle/my_vehicle_screen.dart';
import 'package:tourguideapp/views/settings/setting_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/travel_history/travel_history_screen.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../auth/login_screen.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/interactive_row_widget.dart';
import 'package:image_picker/image_picker.dart';

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
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40.h,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft, 
                        child: CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          AppLocalizations.of(context).translate('Profile'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        profileViewModel.avatar,
                      ),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Fallback nếu load ảnh thất bại
                        const AssetImage('assets/img/bg_route_1.png');
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(Icons.photo_camera),
                                        title: Text(AppLocalizations.of(context).translate('Take Photo')),
                                        onTap: () {
                                          Navigator.pop(context);
                                          profileViewModel.changeProfileImage(ImageSource.camera);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: Text(AppLocalizations.of(context).translate('Choose from Gallery')),
                                        onTap: () {
                                          Navigator.pop(context);
                                          profileViewModel.changeProfileImage(ImageSource.gallery);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
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
                      _buildInteractiveRow(context, Icons.location_pin, 'Favourite Destinations', navigateToFavouriteDestinations: true), 
                      SizedBox(height: 16.h),
                      _buildInteractiveRow(context, Icons.history, 'Travel History', navigateToTravelHistory: true),
                      SizedBox(height: 16.h),
                      _buildInteractiveRow(context, CupertinoIcons.car_detailed, 'My Vehicle', navigateToMyVehicle: true),
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
    final profileViewModel = Provider.of<ProfileViewModel>(context);
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
          _buildStatsColumn(
            context, 
            AppLocalizations.of(context).translate('Travel Points'), 
            profileViewModel.travelPoint.toString()
          ),
          SizedBox(width: 25.w),
          _buildStatsColumn(
            context, 
            AppLocalizations.of(context).translate('Travel Trips'), 
            profileViewModel.travelTrip.toString()
          ),
          SizedBox(width: 25.w),
          _buildStatsColumn(
            context, 
            AppLocalizations.of(context).translate('Feedback Times'), 
            profileViewModel.feedbackTimes.toString()
          ),
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

  Widget _buildInteractiveRow(BuildContext context, IconData leadingIcon, String title, {bool navigateToSettings = false, bool navigateToFavouriteDestinations = false, bool navigateToTravelHistory = false, bool navigateToMyVehicle = false}) {
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
        } else if (navigateToFavouriteDestinations) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FavouriteDestinationsScreen()), // Navigate to the FavouriteScreen
          );
        }  else if (navigateToTravelHistory) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TravelHistoryScreen()),
          );
        }  else if (navigateToMyVehicle) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyVehicleScreen()),
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
