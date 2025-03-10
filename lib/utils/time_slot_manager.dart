class TimeSlotManager {
  static String getTimeSlot(int index) {
    final timeSlot = generateTimeSlot(index);
    return formatTimeRange(timeSlot['startTime']!, timeSlot['endTime']!);
  }

  static Map<String, String> generateTimeSlot(int index) {
    // Bắt đầu từ 8:00 AM
    final startHour = 8 + (index * 2);
    if (startHour >= 22) {
      return {
        'startTime': '08:00',
        'endTime': '09:00'
      };
    }
    
    final endHour = startHour + 1;
    return {
      'startTime': '${startHour.toString().padLeft(2, '0')}:00',
      'endTime': '${endHour.toString().padLeft(2, '0')}:00'
    };
  }

  static String formatTimeRange(String startTime, String endTime) {
    final start = _convert24To12Hour(startTime);
    final end = _convert24To12Hour(endTime);
    return "$start - $end";
  }

  static String _convert24To12Hour(String time24) {
    final hour = int.parse(time24.split(':')[0]);
    final period = hour >= 12 ? "PM" : "AM";
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return "${displayHour.toString().padLeft(2, '0')}:00 $period";
  }
} 