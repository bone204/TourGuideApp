import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/delivery/delivery_screen.dart';
import 'package:tourguideapp/views/service/eatery/eatery_screen.dart';
import 'package:tourguideapp/views/service/hotel/hotel_booking_screen.dart';
import 'package:tourguideapp/views/service/rental_vehicle/vehicle_rental_screen.dart';
import 'package:tourguideapp/views/service/restaurant/restaurant_booking_screen.dart';

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
              settings: const RouteSettings(name: '/travel'),
              builder: (context) => const TravelScreen(),
            ),
          );
        }

        if (text == "Find Hotel") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelBookingScreen(),
            ),
          );
        }

        if (text == "Find Restaurant") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantBookingScreen(),
            ),
          );
        }

        if (text == "Find Eatery") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EateryScreen(),
            ),
          );
        }

        if (text == "Fast Delivery") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeliveryScreen(),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 40.w,
              height: 40.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4.h),
            Text(
              AppLocalizations.of(context).translate(text),
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
