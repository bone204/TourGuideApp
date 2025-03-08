class TimeSlotManager {
  static String getTimeSlot(int index) {
    // Bắt đầu từ 8:00 AM
    final startHour = 8 + (index * 2);
    if (startHour >= 22) return "No time slot available"; // Sau 10 PM
    
    final endHour = startHour + 1;
    final startTime = _formatHour(startHour);
    final endTime = _formatHour(endHour);
    
    return "$startTime - $endTime";
  }

  static String _formatHour(int hour) {
    final period = hour >= 12 ? "PM" : "AM";
    final displayHour = hour > 12 ? hour - 12 : hour;
    return "${displayHour.toString().padLeft(2, '0')}:00 $period";
  }
} 