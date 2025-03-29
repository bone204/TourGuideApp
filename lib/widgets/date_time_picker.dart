import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class DateTimePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String title;
  final DateTime? firstDate;
  final bool showTime;
  final DateTime? minDate;

  const DateTimePicker({
    Key? key,
    this.selectedDate,
    required this.onDateSelected,
    required this.title,
    this.firstDate,
    this.showTime = false,
    this.minDate,
  }) : super(key: key);

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime currentDate;
  TimeOfDay selectedTime = const TimeOfDay(hour: 13, minute: 0);

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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;
    final period = time.hour >= 12 ? ' PM' : ' AM';
    return '${hour.toString().padLeft(2, '0')}:00$period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate(widget.title),
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: currentDate,
              firstDate: widget.minDate ?? DateTime.now(),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null) {
              DateTime finalDateTime = pickedDate;

              if (widget.showTime) {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );

                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                  finalDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                }
              }

              setState(() {
                currentDate = finalDateTime;
              });
              widget.onDateSelected(finalDateTime);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/img/calendar.png',
                  width: 16.w,
                  height: 16.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.showTime
                      ? "${_getDayAbbreviation(currentDate, context)}, ${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year} - ${_formatTime(TimeOfDay.fromDateTime(currentDate))}"
                      : "${_getDayAbbreviation(currentDate, context)}, ${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}",
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
