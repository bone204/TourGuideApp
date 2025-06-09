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
    return '$startTime - $endTime';
  }

  static String convertTo24Hour(String time) {
    // Nếu không có AM/PM, giả định là đã ở định dạng 24h
    if (!time.toUpperCase().contains('AM') && !time.toUpperCase().contains('PM')) {
      return time;
    }

    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = timeParts[1];
    final isPM = parts[1].toUpperCase() == 'PM';

    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  static String convertTo12Hour(String time) {
    final parts = time.split(':');
    var hour = int.parse(parts[0]);
    final minute = parts[1];
    final isPM = hour >= 12;

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute ${isPM ? 'PM' : 'AM'}';
  }
} 