import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/image_stack.dart';

class HorizontalCardData {
  final String imageUrl;
  final String placeName;
  final String description;
  final double rating;

  HorizontalCardData({
    required this.imageUrl,
    required this.placeName,
    required this.description,
    required this.rating,
  });
}

class HorizontalCard extends StatelessWidget {
  final HorizontalCardData data;
  final VoidCallback onTap; // Thêm onTap callback

  const HorizontalCard({required this.data, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return GestureDetector(
      onTap: onTap, // Gọi hàm onTap khi nhấn vào card
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
              Container(
                color: const Color(0xFFFFFFFF),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          data.placeName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF000000),
                          ),
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
                            Text(
                              data.description,
                              style: TextStyle(
                                color: const Color(0xFF7D848D),
                                fontSize: 15.sp,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rate,
                              color: Colors.yellow,
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
