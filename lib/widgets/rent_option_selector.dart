import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class RentOptionSelector extends StatelessWidget {
  final String selectedOption;
  final Function(String) onOptionSelected;

  const RentOptionSelector({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOptionCard(
          context,
          icon: Icons.access_time,
          title: 'Hourly Rent',
          description: "Best for business appointments",
          isSelected: selectedOption == 'Hourly',
          onTap: () => onOptionSelected('Hourly'),
        ),
        const SizedBox(width: 16.0),
        _buildOptionCard(
          context,
          icon: Icons.calendar_today,
          title: 'Daily Rent',
          description: "Best for travel",
          isSelected: selectedOption == 'Daily',
          onTap: () => onOptionSelected('Daily'),
        ),
      ],
    );
  }

  Widget _buildOptionCard(BuildContext context, {required IconData icon, required String title, required String description, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF007BFF) : Colors.black,
            width: 2.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 80.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFFCCE4FF),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), bottomLeft: Radius.circular(16.r)),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF007BFF) : Colors.black,
                size: 24.sp,
              ),
            ),
            Container(
              width: 2.w,
              height: 80.h,
              color: isSelected ? const Color(0xFF007BFF) : Colors.black,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h, right: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate(title),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context).translate(description),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF6F7789),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}