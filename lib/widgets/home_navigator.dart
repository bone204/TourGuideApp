import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/rental/vehicle_rental_screen.dart';

import 'package:tourguideapp/views/service/travel/travel_screen.dart';

class HomeNavigator extends StatelessWidget {
  final String image;
  final String text;

  const HomeNavigator({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (text == "Car Rental") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VehicleRentalScreen(
                initialCategory: 'Car',
              ),
            ),
          );
        }

        if (text == "Motorbike Rental") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VehicleRentalScreen(
                initialCategory: 'Motorbike',
              ),
            ),
          );
        }

        if (text == "Travel") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TravelScreen(),
            ),
          );
        }
      },
      child: SizedBox(
        width: 90.w,
        height: 60.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 39.w,
              height: 39.h,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 5.h),
            Text(
              AppLocalizations.of(context).translate(text),
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
