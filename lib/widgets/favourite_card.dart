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
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r), 
                child: Image.network(
                  data.imageUrl,
                  height: 124.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.h),
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
                  Icon(
                    Icons.location_on_outlined,
                    color: const Color(0xFF7D848D),
                    size: 12.sp,
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
    );
  }
}