
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DestinationCardData {
  final String imageUrl;
  final String placeName;
  final String time;

  DestinationCardData({
    required this.imageUrl,
    required this.placeName,
    required this.time,
  });
}

class DestinationCard extends StatelessWidget {
  final DestinationCardData data;

  const DestinationCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Container(
      width: 335.w,
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
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r), 
                child: Image.network(
                  data.imageUrl,
                  height: 90.h, 
                  width: 160.w, 
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: const Color(0xFF7D848D),
                        size: 13.sp,
                      ),
                      Text(
                        data.time, 
                        style: TextStyle(
                          color: const Color(0xFF7D848D), 
                          fontSize: 13.sp, 
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    data.placeName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                  )
                ],
              ),
            ],
          ),
      )
    );
  }
}