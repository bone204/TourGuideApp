import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class RouteCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback? onTap;

  const RouteCard({
    Key? key,
    required this.name,
    required this.imagePath,
    required this.startDate,
    required this.endDate,
    this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 335.w,
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: imagePath.startsWith('http') || imagePath.startsWith('https')
                ? NetworkImage(imagePath) as ImageProvider
                : AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay
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
            // Content
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên route
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
                  // Ngày bắt đầu và kết thúc
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(59.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 315.w),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 14.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
