import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class UseServiceCard extends StatelessWidget {
  final String vehicleName;
  final String dateRange;
  final double price;
  final VoidCallback? onDetailPressed;
  final VoidCallback? onCancelPressed;
  final String imageUrl;

  const UseServiceCard({
    Key? key,
    required this.vehicleName,
    required this.dateRange,
    required this.price,
    this.onDetailPressed,
    this.onCancelPressed,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100.w,
              height: 120.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleName,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_month, size: 16.sp),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              dateRange,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Image.asset(
                            'assets/img/ic_money.png',
                            width: 16.w,
                            height: 16.h,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${NumberFormat('#,###').format(price)} ₫",
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onDetailPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate('Detail'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(width: 8.w),
                      // Expanded(
                      //   child: ElevatedButton(
                      //     onPressed: onCancelPressed,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color(0xFF007BFF),
                      //       foregroundColor: Colors.white,
                      //       padding: EdgeInsets.symmetric(vertical: 8.h),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8.r),
                      //       ),
                      //     ),
                      //     child: Text(
                      //       'Cancel',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 12.sp,
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
