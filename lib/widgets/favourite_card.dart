
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavouriteCardData {
  final String imageUrl;
  final String placeName;
  final String description;

  FavouriteCardData({
    required this.imageUrl,
    required this.placeName,
    required this.description,
  });
}

class FavouriteCard extends StatelessWidget {
  final FavouriteCardData data;

  const FavouriteCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Container(
      width: 161.w,
      height: 190.h,
      margin: EdgeInsets.fromLTRB(10.w, 0.h, 10.w, 0.h),
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
                borderRadius: BorderRadius.circular(16.r), // Cắt góc cho ảnh
                child: Image.network(
                  data.imageUrl,
                  height: 124.h, 
                  width: 137.w, 
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                data.placeName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000000),
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: const Color(0xFF7D848D),
                    size: 12.sp,
                  ),
                  Text(
                    data.description, 
                    style: TextStyle(
                      color: const Color(0xFF7D848D), 
                      fontSize: 12.sp, 
                    ),
                  ),
                ],
              )
            ],
          ),
      )
    );
  }
}