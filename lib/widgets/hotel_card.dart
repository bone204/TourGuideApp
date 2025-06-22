// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class HotelCard extends StatelessWidget {
  final CooperationModel hotel;
  final double minPrice;
  final int availableRooms;
  final VoidCallback? onTap;

  const HotelCard({
    Key? key,
    required this.hotel,
    required this.minPrice,
    required this.availableRooms,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w),
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
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh khách sạn
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Image.network(
                hotel.photo,
                height: 170.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 170.h,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên khách sạn
                  Text(
                    hotel.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Icon tiện ích
                  Row(
                    children: [
                      Icon(Icons.wifi, size: 18.sp, color: Colors.blueAccent),
                      SizedBox(width: 8.w),
                      Icon(Icons.free_breakfast, size: 18.sp, color: Colors.orangeAccent),
                      SizedBox(width: 8.w),
                      Icon(Icons.pool, size: 18.sp, color: Colors.cyan),
                      SizedBox(width: 8.w),
                      Icon(Icons.fitness_center, size: 18.sp, color: Colors.deepPurple),
                      SizedBox(width: 8.w),
                      Icon(Icons.local_parking, size: 18.sp, color: Colors.green),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // // Địa chỉ
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Icon(Icons.location_on, size: 16.sp, color: Colors.blueAccent),
                  //     SizedBox(width: 4.w),
                  //     Expanded(
                  //       child: Text(
                  //         hotel.address,
                  //         style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                  //         maxLines: 2,
                  //         overflow: TextOverflow.ellipsis,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 6.h),
                  // // Loại hình & Số lần đặt
                  // Row(
                  //   children: [
                  //     Icon(Icons.category, size: 15.sp, color: Colors.deepPurple),
                  //     SizedBox(width: 4.w),
                  //     Text(hotel.type, style: TextStyle(fontSize: 13.sp)),
                  //     SizedBox(width: 12.w),
                  //     Icon(Icons.shopping_bag, size: 15.sp, color: Colors.orange),
                  //     SizedBox(width: 4.w),
                  //     Text('Đặt: ${hotel.bookingTimes}', style: TextStyle(fontSize: 13.sp)),
                  //   ],
                  // ),
                  // SizedBox(height: 6.h),
                  // Doanh thu
                  // Row(
                  //   children: [
                  //     Icon(Icons.attach_money, size: 15.sp, color: Colors.green[700]),
                  //     SizedBox(width: 4.w),
                  //     Text('${hotel.revenue.toStringAsFixed(0)} VNĐ', style: TextStyle(fontSize: 13.sp)),
                  //   ],
                  // ),
                  // SizedBox(height: 6.h),
                  // // Phòng trống & Giá
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bed, size: 14.sp, color: Colors.green[700]),
                            SizedBox(width: 4.w),
                            Text(
                              '$availableRooms ${AppLocalizations.of(context).translate("Available rooms")}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${AppLocalizations.of(context).translate("From")} ${NumberFormat('#,###', 'vi_VN').format(minPrice.toInt())} ₫',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, size: 16.sp, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        hotel.averageRating.toString(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
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
    );
  }
}
