import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisabledTextField extends StatelessWidget {
  final String labelText;
  final String text;
  final bool enabled;

  const DisabledTextField({
    required this.labelText,
    required this.text,
    this.enabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: TextField(
            enabled: enabled,
            controller: TextEditingController(text: text), 
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F9),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
            ),
          ),
        ),
      ],
    );
  }
}
