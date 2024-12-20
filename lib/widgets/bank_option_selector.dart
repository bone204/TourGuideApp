import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';

class BankOptionSelector extends StatelessWidget {
  final String bankImageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const BankOptionSelector({
    Key? key,
    required this.bankImageUrl,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 80.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.black,
            width: 1.5.w,
          ),
        ),
        child: Center(
          child: Image.asset(
            bankImageUrl,
            width: 80.w,
            height: 60.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
} 