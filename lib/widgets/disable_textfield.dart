import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';

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
        Icons.warning_amber_rounded,
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
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16.sp,
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
