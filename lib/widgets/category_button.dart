import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';

class CategoryButton extends StatelessWidget {
  final String category;
  final bool isSelected;
  final Function(String) onTap;

  const CategoryButton({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(category),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007BFF) : Colors.white,
          border: Border.all(
            color: const Color(0xFF007BFF),
            width: isSelected ? 0 : 2,
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
