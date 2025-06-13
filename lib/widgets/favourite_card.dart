// ignore_for_file: deprecated_member_use

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
              data.imageUrl,
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
                  data.placeName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/img/ic_location.png',
                      width: 16.w,
                      height: 16.h,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        data.description,
                        style: TextStyle(
                          color: const Color(0xFF7D848D),
                          fontSize: 12.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      )
    );
  }
}