import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/core/utils/currency_formatter.dart';

class RoomCard extends StatelessWidget {
  final String name;
  final String area;
  final String bedType;
  final String bathType;
  final int maxPerson;
  final int roomsLeft;
  final double price;
  final String imageUrl;
  final VoidCallback onChoose;

  const RoomCard({
    Key? key,
    required this.name,
    required this.area,
    required this.bedType,
    required this.bathType,
    required this.maxPerson,
    required this.roomsLeft,
    required this.price,
    required this.imageUrl,
    required this.onChoose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                imageUrl,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              name,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),
            // Room Features
            Row(
              children: [
                _buildFeature(Icons.square_foot, area),
                SizedBox(width: 16.w),
                _buildFeature(Icons.bed, bedType),
                SizedBox(width: 16.w),
                _buildFeature(Icons.shower, bathType),
              ],
            ),
            SizedBox(height: 16.h),
            const Divider(
              thickness: 1,
              color: AppColors.grey,
            ),
            SizedBox(height: 14.h),
            // Person and Room Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16.w, color: AppColors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          '$maxPerson person(s)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(Icons.wifi, size: 16.w, color: AppColors.grey),
                        SizedBox(width: 8.w),
                        Icon(Icons.smoke_free,
                            size: 16.w, color: AppColors.grey),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(Icons.room_preferences,
                            size: 16.w, color: AppColors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          '$roomsLeft room(s) left',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(width: 16.w),
                Column(
                  children: [
                    Text(
                      CurrencyFormatter.format(price),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: onChoose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        'Choose',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: AppColors.grey),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
