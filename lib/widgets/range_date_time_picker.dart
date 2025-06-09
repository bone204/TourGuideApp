import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class RangeDateTimePicker extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTimeRange) onDateRangeSelected;

  const RangeDateTimePicker({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
  }) : super(key: key);

  String _getDayAbbreviation(DateTime date, BuildContext context) {
    List<String> daysVi = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    List<String> daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    String languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'vi' 
        ? daysVi[date.weekday % 7]
        : daysEn[date.weekday % 7];
  }

  String _formatDate(DateTime date, BuildContext context) {
    return "${_getDayAbbreviation(date, context)}, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final DateTimeRange? pickedDateRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
              initialDateRange: DateTimeRange(
                start: startDate,
                end: endDate,
              ),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDateRange != null) {
              onDateRangeSelected(pickedDateRange);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
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
            child: Row(
              children: [
                Image.asset(
                  'assets/img/calendar.png',
                  width: 16.w,
                  height: 16.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _formatDate(startDate, context),
                          style: TextStyle(fontSize: 16.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          "-",
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _formatDate(endDate, context),
                          style: TextStyle(fontSize: 16.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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