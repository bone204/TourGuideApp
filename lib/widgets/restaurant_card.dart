import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/views/service/restaurant/restaurant_detail_screen.dart';
import 'package:tourguideapp/models/cooperation_model.dart';

class RestaurantCard extends StatelessWidget {
  final CooperationModel restaurant;
  final int? minTablePrice;
  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  RestaurantCard({Key? key, required this.restaurant, this.minTablePrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantDetailScreen(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.25),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Image.network(
                restaurant.photo,
                height: 124.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    minTablePrice != null
                        ? 'Từ ${currencyFormat.format(minTablePrice)} ₫/bàn'
                        : 'Giá: Xem chi tiết',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < restaurant.averageRating.floor()
                              ? Icons.star
                              : (index < restaurant.averageRating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 16.sp,
                        );
                      }),
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
