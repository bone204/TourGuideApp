import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehicleCardData {
  final String model;
  final String transmission;
  final String seats;
  final String fuelType;
  final String imagePath;

  VehicleCardData({
    required this.model,
    required this.transmission,
    required this.seats,
    required this.fuelType,
    required this.imagePath
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
        padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 10.h),
                ClipRRect(
                  child: Image.asset(
                    data.imagePath,
                    height: 70.h,
                    width: 140.w,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.transmission,
                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '|',
                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      data.seats,
                      style: TextStyle(fontSize: 14.sp,color: const Color(0xFF7D848D)),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Text(
                  "500,000 ₫ / ngày",
                  style: TextStyle(fontSize: 16.sp, color: const Color(0xFFFF7029), fontWeight: FontWeight.bold),
                ),
            ],)
          ],
        ),
      ),
    );
  }
}
