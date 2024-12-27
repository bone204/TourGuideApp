import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart'; 

class DateTimePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String title;

  const DateTimePicker({
    Key? key, 
    this.selectedDate,
    required this.onDateSelected,
    required this.title,
  }) : super(key: key);

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(DateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null && widget.selectedDate != currentDate) {
      currentDate = widget.selectedDate!;
    }
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
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: currentDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null) {
              setState(() {
                currentDate = pickedDate;
              });
              widget.onDateSelected(pickedDate);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F9),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/img/calendar.png',
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 12.w),
                Text(
                  "${_getDayAbbreviation(currentDate, context)}, ${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


