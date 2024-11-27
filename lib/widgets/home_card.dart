import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/image_stack.dart';

class HomeCardData {
  final String imageUrl;
  final String placeName;
  final String description;
  final double rating;

  HomeCardData({
    required this.imageUrl,
    required this.placeName,
    required this.description,
    required this.rating,
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
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  data.imageUrl,
                  height: 285.h,
                  width: 240.w,
                  fit: BoxFit.cover,
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
                          Text(
                            data.placeName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF000000),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: const Color(0xFF7D848D),
                                size: 15.sp,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  data.description,
                                  style: TextStyle(
                                    color: const Color(0xFF7D848D),
                                    fontSize: 15.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.yellow,
                              size: 12.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              data.rating.toString(),
                              style: TextStyle(
                                color: const Color(0xFF000000),
                                fontSize: 15.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        const ImageStackWidget(),
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
