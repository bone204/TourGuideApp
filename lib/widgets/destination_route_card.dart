import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class DestinationRouteCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final String timeRange;
  final VoidCallback? onTap;

  const DestinationRouteCard({
    Key? key,
    required this.name,
    required this.imagePath,
    required this.timeRange,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 335.w,
        height: 140.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: NetworkImage(imagePath),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Xử lý khi ảnh lỗi
              AssetImage('assets/images/default.jpg');
            },
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(59.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 315.w),
                        child: Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(59.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 315.w),
                        child: Text(
                          timeRange,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
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
