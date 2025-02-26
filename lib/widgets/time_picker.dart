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
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;
    final period = time.hour >= 12 ? ' PM' : ' AM';
    return '${hour.toString().padLeft(2, '0')}:00$period';
  }

  bool _isValidStartTime(TimeOfDay time, String package) {
    if (package == '4 Hours') {
      return time.hour >= 7 && time.hour <= 13;
    } else {
      return time.hour >= 7 && time.hour <= 9;
    }
  }



  String _getTimeRangeText(String package) {
    if (package == '4 Hours') {
      return '7:00 AM - 1:00 PM';
    } else {
      return '7:00 AM - 9:00 AM';
    }
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final now = TimeOfDay.now();
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 7, minute: 0),
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: false,
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          timePickerTheme: TimePickerThemeData(
                            dayPeriodTextStyle:
                                const TextStyle(color: Colors.black),
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
                  hourLabelText:
                      'Giờ cho phép: ${_getTimeRangeText(selectedPackage)}',
                );

                if (picked != null) {
                  if (_isValidStartTime(picked, selectedPackage)) {
                    // Kiểm tra thời gian hiện tại
                    final today = DateTime.now();
                    if (today.hour == picked.hour) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Không thể chọn giờ hiện tại. Vui lòng chọn sau ${now.hour + 1}:00'),
                        ),
                      );
                      return;
                    }
                    onStartTimeChanged(TimeOfDay(hour: picked.hour, minute: 0));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Vui lòng chọn thời gian trong khoảng ${_getTimeRangeText(selectedPackage)}',
                        ),
                      ),
                    );
                  }
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
            SizedBox(height: 4.h),
            Text(
              "Thời gian cho phép: ${_getTimeRangeText(selectedPackage)}",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
