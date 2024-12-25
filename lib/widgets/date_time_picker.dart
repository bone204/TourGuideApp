import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart'; 

class DateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final String title;
  final String rentOption;

  const DateTimePicker({
    Key? key, 
    this.selectedDate,
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
    final DateTime currentDate = selectedDate ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate(title),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    onDateSelected(pickedDate);
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
            ),
            if (rentOption == 'Hourly') ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () async {
                  print('Opening Time Picker...');
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentDate),
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
                        currentDate.year,
                        currentDate.month,
                        currentDate.day,
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
                        _formatTime(TimeOfDay.fromDateTime(currentDate)),
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


