import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_checkbox.dart';


class CheckboxRow extends StatelessWidget {
  final String title;
  final String link;
  final VoidCallback onTitleTap;

  const CheckboxRow({super.key, required this.title, required this.link, required this.onTitleTap});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomCheckbox(),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                  )
                ),
                TextSpan(
                  text: link,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF007BFF),
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTitleTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}