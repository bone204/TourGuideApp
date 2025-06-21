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
        width: 161.w,
        height: 190.h,
        margin: EdgeInsets.symmetric(horizontal: 10.w),
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
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  restaurant.photo,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                restaurant.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                restaurant.address,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
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
              SizedBox(height: 4.h),
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
      ),
    );
  }
}
