import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehicleCardData {
  final String model;
  final String transmission;
  final String seats;
  final String fuelType;

  VehicleCardData({
    required this.model,
    required this.transmission,
    required this.seats,
    required this.fuelType,
  });
}

class VehicleCard extends StatelessWidget {
  final VehicleCardData data;

  const VehicleCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 12.h),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.model,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Transmission: ${data.transmission}',
                  style: TextStyle(fontSize: 14.sp),
                ),
                Text(
                  'Seats: ${data.seats}',
                  style: TextStyle(fontSize: 14.sp),
                ),
                Text(
                  'Fuel: ${data.fuelType}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
