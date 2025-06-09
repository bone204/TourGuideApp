import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class PersonCount {
  final int adults;
  final int children;

  PersonCount({
    required this.adults,
    required this.children,
  });

  int get total => adults + children;
}

class PersonPicker extends StatelessWidget {
  final PersonCount personCount;
  final Function(PersonCount) onPersonCountChanged;
  final List<int> personOptions = [1, 2, 3, 4, 5, 6, 7, 8];

  PersonPicker({
    Key? key,
    required this.personCount,
    required this.onPersonCountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.25),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: personCount.total,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, size: 20.w),
          iconSize: 20.w,
          items: personOptions.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    value.toString(),
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              onPersonCountChanged(
                PersonCount(
                  adults: newValue,
                  children: 0,
                ),
              );
            }
          },
        ),
      ),
    );
  }
} 