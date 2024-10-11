import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class CategoryButton extends StatelessWidget {
  final String category;
  final bool isSelected;
  final Function(String) onTap;

  const CategoryButton({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return ElevatedButton(
      onPressed: () => onTap(category),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(100.w, 40.h),
        backgroundColor: isSelected ? const Color(0xFF007BFF) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF007BFF),
        side: const BorderSide(color: Color(0xFF007BFF)),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      child: Center(child: Text(AppLocalizations.of(context).translate(category), style: TextStyle(fontSize: 14.sp))),
    );
  }
}
