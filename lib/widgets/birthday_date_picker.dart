import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class BirthdayDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String title;

  const BirthdayDatePicker({
    Key? key,
    this.selectedDate,
    required this.onDateSelected,
    required this.title,
  }) : super(key: key);

  @override
  State<BirthdayDatePicker> createState() => _BirthdayDatePickerState();
}

class _BirthdayDatePickerState extends State<BirthdayDatePicker> {
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = widget.selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)); // Mặc định 18 tuổi
  }

  String _getDayAbbreviation(DateTime date, BuildContext context) {
    List<String> daysVi = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    List<String> daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    String languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'vi'
        ? daysVi[date.weekday % 7]
        : daysEn[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate(widget.title),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime hundredYearsAgo = DateTime(now.year - 100);
            
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: currentDate,
              firstDate: hundredYearsAgo,
              lastDate: now,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              setState(() {
                currentDate = pickedDate;
              });
              widget.onDateSelected(pickedDate);
            }
          },
          child: Container(
            width: double.infinity,
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/img/calendar.png',
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 12.w),
                Text(
                  "${_getDayAbbreviation(currentDate, context)}, ${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 