import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimePicker extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final String selectedPackage;

  const TimePicker({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.selectedPackage,
  }) : super(key: key);

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? ' PM' : ' AM';
    return '${hour.toString().padLeft(2, '0')}:00$period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: startTime.hour, minute: 0),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: false,
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      timePickerTheme: TimePickerThemeData(
                        dayPeriodTextStyle: const TextStyle(color: Colors.black),
                        hourMinuteTextStyle: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ),
                    child: child!,
                  ),
                );
              },
            );
            if (picked != null && picked.hour >= 6 && picked.hour <= 18) {
              onStartTimeChanged(TimeOfDay(hour: picked.hour, minute: 0));
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
                Icon(Icons.access_time, size: 24.w),
                SizedBox(width: 12.w),
                Text(
                  "${_formatTime(startTime)} - ${_formatTime(endTime)}",
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