import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/utils/time_slot_manager.dart';

class DestinationEditModal extends StatefulWidget {
  final String destinationName;
  final String currentStartTime;
  final String currentEndTime;
  final Function(String startTime, String endTime) onUpdateTime;
  final VoidCallback onDelete;

  const DestinationEditModal({
    Key? key,
    required this.destinationName,
    required this.currentStartTime,
    required this.currentEndTime,
    required this.onUpdateTime,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DestinationEditModal> createState() => _DestinationEditModalState();
}

class _DestinationEditModalState extends State<DestinationEditModal> {
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  @override
  void initState() {
    super.initState();
    // Chuyển đổi thời gian từ định dạng 12h sang 24h nếu cần
    final normalizedStartTime = TimeSlotManager.convertTo24Hour(widget.currentStartTime);
    final normalizedEndTime = TimeSlotManager.convertTo24Hour(widget.currentEndTime);
    
    // Chuyển đổi chuỗi thời gian thành TimeOfDay
    final startParts = normalizedStartTime.split(':');
    final endParts = normalizedEndTime.split(':');
    
    startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    
    endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
          // Nếu thời gian bắt đầu lớn hơn hoặc bằng thời gian kết thúc
          if (_compareTimeOfDay(startTime, endTime) >= 0) {
            // Tự động đặt thời gian kết thúc là 1 giờ sau thời gian bắt đầu
            endTime = TimeOfDay(
              hour: (startTime.hour + 1) % 24,
              minute: startTime.minute,
            );
          }
        } else {
          // Nếu thời gian kết thúc nhỏ hơn hoặc bằng thời gian bắt đầu
          if (_compareTimeOfDay(picked, startTime) <= 0) {
            // Hiển thị thông báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thời gian kết thúc phải lớn hơn thời gian bắt đầu'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          endTime = picked;
        }
      });
    }
  }

  int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1.compareTo(minutes2);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.destinationName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thời gian bắt đầu',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          _formatTimeOfDay(startTime),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thời gian kết thúc',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          _formatTimeOfDay(endTime),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onUpdateTime(
                      _formatTimeOfDay(startTime),
                      _formatTimeOfDay(endTime),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Cập nhật',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onDelete();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Xóa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 