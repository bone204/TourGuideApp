import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';

class DateAndTimePicker extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;

  const DateAndTimePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[date.weekday - 1];
    
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    
    return '$dayName, ${date.day} ${_getMonth(date.month)} ${date.year} - $hour:$minute $period';
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (pickedDate != null) {
      onDateSelected(pickedDate);
      
      // Show time picker after date is selected
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
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

      if (pickedTime != null) {
        onTimeSelected(pickedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDateTime(context),
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
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                _formatDateTime(selectedDate, selectedTime),
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 