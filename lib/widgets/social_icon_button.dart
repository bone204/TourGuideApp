import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label; // New label parameter
  final VoidCallback onPressed;

  const SocialIconButton({
    super.key, 
    required this.icon,
    required this.color,
    required this.label, // Include label in constructor
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Container(
      width: 140.w,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(8.0), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), 
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2), 
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent, 
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min, 
            children: [
              FaIcon(icon, color: color, size: 24.sp),
              SizedBox(width: 8.w), 
              Text(
                label,
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold), // Style for the label
              ),
            ],
          ),
        ),
      ),
    );
  }
}
