import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class StyledTextField extends StatefulWidget {
  final Function(String) onTextChanged;
  final String title;
  final String hintText;

  const StyledTextField({
    Key? key,
    required this.onTextChanged,
    required this.title,
    required this.hintText,
  }) : super(key: key);

  @override
  _StyledTextFieldState createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<StyledTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: AppLocalizations.of(context).translate(widget.hintText),
                    ),
                    onChanged: widget.onTextChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 