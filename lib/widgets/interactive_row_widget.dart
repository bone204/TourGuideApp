import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart'; // Import ScreenUtil

class InteractiveRowWidget extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final bool isSelected;

  const InteractiveRowWidget({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.trailingIcon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Khởi tạo ScreenUtil với kích thước thiết kế
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); 

    // Sử dụng màu sắc tuỳ theo trạng thái được chọn
    final textColor = isSelected ? AppColors.primaryColor : AppColors.black;
    final iconColor = isSelected ? AppColors.primaryColor : AppColors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 20.w), // Sử dụng ScreenUtil
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r), // Sử dụng ScreenUtil
          boxShadow:  [
            BoxShadow(
              color: const Color(0x0ff00000).withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 2.r, // Sử dụng ScreenUtil
              offset: const Offset(0, 2), 
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(leadingIcon, color: textColor, size: 24.sp), // Sử dụng ScreenUtil
                SizedBox(width: 12.w), // Sử dụng ScreenUtil
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp, // Sử dụng ScreenUtil
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Icon(trailingIcon, color: iconColor, size: 24.sp), // Sử dụng ScreenUtil
          ],
        ),
      ),
    );
  }
}
