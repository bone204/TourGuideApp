import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/views/service/hotel/hotel_detail_screen.dart';
import 'package:tourguideapp/models/cooperation_model.dart';

class HotelCard extends StatelessWidget {
  final CooperationModel hotel;
  final int? minRoomPrice;
  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  HotelCard({Key? key, required this.hotel, this.minRoomPrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final isVietnamese = Localizations.localeOf(context).languageCode == 'vi';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailScreen(hotel: hotel),
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
                  hotel.photo,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                hotel.name,
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
                hotel.address,
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                minRoomPrice != null
                    ? 'Từ ${currencyFormat.format(minRoomPrice)} ₫/đêm'
                    : 'Giá: Xem chi tiết',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < hotel.averageRating.floor()
                          ? Icons.star
                          : (index < hotel.averageRating
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
