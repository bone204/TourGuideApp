import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHomeCard extends StatelessWidget {
  const ShimmerHomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Container(
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
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
          child: Column(
            children: [
              Container(
                height: 285.h,
                width: 240.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 190.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150.w,
                            height: 18.h,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.h,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                width: 100.w,
                                height: 15.h,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.h,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              width: 30.w,
                              height: 15.h,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.h,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              width: 30.w,
                              height: 15.h,
                              color: Colors.white,
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
      ),
    );
  }
}

class ShimmerFavoriteCard extends StatelessWidget {
  const ShimmerFavoriteCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 124.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 100.w,
                height: 14.h,
                color: Colors.white,
              ),
              SizedBox(height: 6.h),
              Container(
                width: 120.w,
                height: 12.h,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 