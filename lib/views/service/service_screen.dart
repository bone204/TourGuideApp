import 'package:flutter/material.dart';
import 'package:tourguideapp/views/service/rental/vehicle_rental_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/interactive_row_widget.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812)); // Thiết lập kích thước màn hình
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _buildInteractiveRow(context, Icons.bike_scooter, 'Car Rental'), 
                      SizedBox(height: 16.h),
                      _buildInteractiveRow(context, Icons.restaurant, 'Restaurant'),
                      SizedBox(height: 16.h),
                      _buildInteractiveRow(context, Icons.hotel, 'Hotel'),
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

  Widget _buildInteractiveRow(BuildContext context, IconData leadingIcon, String title, {bool navigateToCarRental = false}) {
    return InteractiveRowWidget(
      leadingIcon: leadingIcon,
      title: AppLocalizations.of(context).translate(title),
      trailingIcon: Icons.chevron_right,
      onTap: () {
        if (navigateToCarRental) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VehicleRentalScreen(
                initialCategory: 'Car',
              ),
            ),
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
