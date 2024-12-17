import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart'; 

class DateTimePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final String title;
  final String rentOption;

  const DateTimePicker({
    Key? key, 
    required this.selectedDate, 
    required this.onDateSelected,
    required this.title,
    required this.rentOption,
  }) : super(key: key);

  String _getDayAbbreviation(DateTime date, BuildContext context) {
    List<String> daysVi = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']; 
    List<String> daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']; 

    String languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'vi' 
        ? daysVi[date.weekday % 7]
        : daysEn[date.weekday % 7];
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    print('Current DateTime: ${selectedDate.toString()}');
    print('Rent Option: $rentOption');

    ScreenUtil.init(context, designSize: const Size(375, 812));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate(title),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  print('Opening Date Picker...');
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    print('Selected Date: ${pickedDate.toString()}');
                    final newDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      selectedDate.hour,
                      selectedDate.minute,
                    );
                    print('New DateTime after date selection: ${newDateTime.toString()}');
                    onDateSelected(newDateTime);
                  } else {
                    print('Date selection cancelled');
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
                        "${_getDayAbbreviation(selectedDate, context)}, ${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (rentOption == 'Hourly') ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () async {
                  print('Opening Time Picker...');
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDate),
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          alwaysUse24HourFormat: true,
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedTime != null) {
                    print('Selected Time: ${pickedTime.format(context)}');
                    if (pickedTime.hour >= 6 && pickedTime.hour <= 18) {
                      final newDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      print('New DateTime after time selection: ${newDateTime.toString()}');
                      onDateSelected(newDateTime);
                    } else {
                      print('Invalid time selected: ${pickedTime.format(context)} (must be between 6:00-18:00)');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).translate('Time must be between 6:00 and 18:00'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    print('Time selection cancelled');
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
                        _formatTime(TimeOfDay.fromDateTime(selectedDate)),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}


