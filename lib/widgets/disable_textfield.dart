import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class DisabledTextField extends StatelessWidget {
  final String labelText;
  final String text;

  const DisabledTextField({
    Key? key,
    required this.labelText,
    required this.text,
  }) : super(key: key);

  Widget _getIcon(String text) {
    if (text.trim().isEmpty) {
      return const Icon(
        Icons.warning_amber,
        color: AppColors.orange,
      );
    }
    return const Icon(
      Icons.check_sharp,
      color: AppColors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              _getIcon(text),
            ],
          ),
        ),
      ],
    );
  }
}
