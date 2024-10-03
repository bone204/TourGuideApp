import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneNumberField extends StatelessWidget {
  final String labelText;
  final List<String> countryCodes; 
  final String selectedCode; 
  final Function(String?) onCodeChanged; 
  final bool enabled;
  final TextEditingController controller; // Add this line

  const PhoneNumberField({
    required this.labelText,
    required this.countryCodes,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.enabled,
    required this.controller, // Add this line
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); 
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
        Row(
          children: [
            // Country Code Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F9),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: DropdownButton<String>(
                value: selectedCode,
                items: countryCodes
                    .map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(
                            code,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ))
                    .toList(),
                onChanged: onCodeChanged, // Callback when country code changes
                underline: const SizedBox(),
              ),
            ),
            SizedBox(width: 10.w), 
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: TextField(
                  enabled: enabled,
                  controller: controller, // Use the provided controller
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
            ),
          ],
        ),
      ],
    );
  }
}
