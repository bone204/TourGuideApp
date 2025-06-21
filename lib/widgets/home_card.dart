import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class HomeCardData {
  final String imageUrl;
  final String placeName;
  final String description;
  final double rating;
  final int favouriteTimes;
  final int userRatingsTotal;

  HomeCardData({
    required this.imageUrl,
    required this.placeName,
    required this.description,
    required this.rating,
    required this.favouriteTimes,
    this.userRatingsTotal = 0,
  });
}

class HomeCard extends StatelessWidget {
  final HomeCardData data;
  final VoidCallback onTap;

  const HomeCard({required this.data, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 268.w,
        margin: EdgeInsets.only(right: 10.w),
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Image.network(
                data.imageUrl,
                height: 285.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 285.h,
                    width: 240.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.grey[400],
                      size: 40.sp,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.placeName,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.h),
                  Row(
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
                            fontSize: 16.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.yellow,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            data.rating > 0
                                ? data.rating.toStringAsFixed(1)
                                : 'N/A',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (data.userRatingsTotal > 0) ...[
                            SizedBox(width: 4.w),
                            Text(
                              '(${data.userRatingsTotal})',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(width: 12.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: AppColors.red,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            data.favouriteTimes.toString(),
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
