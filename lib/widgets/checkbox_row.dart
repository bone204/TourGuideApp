import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_checkbox.dart';


class CheckboxRow extends StatelessWidget {
  final String title;
  final String link;
  final VoidCallback onTitleTap;
  final ValueChanged<bool?> onChanged;
  final bool value;

  const CheckboxRow({
    super.key,
    required this.title,
    required this.link,
    required this.onTitleTap,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomCheckbox(
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  )
                ),
                TextSpan(
                  text: link,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF007BFF),
                    fontWeight: FontWeight.w500,
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