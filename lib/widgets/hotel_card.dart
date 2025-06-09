import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/views/service/hotel/hotel_detail_screen.dart';

class HotelCardData {
  final String imageUrl;
  final String hotelName;
  final double rating;
  final double pricePerDay;
  final String address;

  HotelCardData({
    required this.imageUrl,
    required this.hotelName,
    required this.rating,
    required this.pricePerDay,
    required this.address,
  });
}

class HotelCard extends StatelessWidget {
  final HotelCardData data;
  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  HotelCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailScreen(data: data),
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
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  data.imageUrl,
                  height: 100.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                data.hotelName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                    ...List.generate(5, (index) {
                    return Icon(
                      index < data.rating.floor()
                          ? Icons.star
                          : (index < data.rating 
                              ? Icons.star_half
                              : Icons.star_border),
                      color: Colors.amber,
                      size: 16.sp,
                    );
                  }),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '${currencyFormat.format(data.pricePerDay)} ₫ / ${isVietnamese ? 'ngày' : 'day'}',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}