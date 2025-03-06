import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;
  final double height;
  final BorderSide? side;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF007BFF),
    this.foregroundColor = Colors.white,
    this.fontSize = 18.0,
    this.height = 50.0,
    this.side,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: Size(double.infinity, height.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        side: side,
      ),
      child: Text(
        AppLocalizations.of(context).translate(text),
        style: TextStyle(
          fontSize: fontSize.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}