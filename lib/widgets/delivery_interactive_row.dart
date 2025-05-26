import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';

class DeliveryInteractiveRow extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final bool isSelected;

  const DeliveryInteractiveRow({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 37.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  imageUrl,
                  height: 24.h,
                  width: 24.w,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(trailingIcon , color: AppColors.black, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
