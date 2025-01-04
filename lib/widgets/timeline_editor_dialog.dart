import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';

class TimelineEditorDialog extends StatefulWidget {
  final String initialTimeline;
  final TimeOfDay? previousEndTime;
  final TimeOfDay? nextStartTime;
  final VoidCallback? onDelete;

  const TimelineEditorDialog({
    Key? key,
    required this.initialTimeline,
    this.previousEndTime,
    this.nextStartTime,
    this.onDelete,
  }) : super(key: key);

  @override
  _TimelineEditorDialogState createState() => _TimelineEditorDialogState();
}

class _TimelineEditorDialogState extends State<TimelineEditorDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _parseInitialTimeline();
  }

  void _parseInitialTimeline() {
    try {
      final times = widget.initialTimeline.split(' - ');
      _startTime = _parseTimeString(times[0]);
      _endTime = _parseTimeString(times[1]);
    } catch (e) {
      _startTime = const TimeOfDay(hour: 8, minute: 0);
      _endTime = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final components = timeStr.split(':');
    final hour = int.parse(components[0]);
    final minute = int.parse(components[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool _isValidTimeRange(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (endMinutes <= startMinutes) {
      setState(() => _errorMessage = 'End time must be after start time');
      return false;
    }

    if (widget.previousEndTime != null) {
      final previousEndMinutes =
          widget.previousEndTime!.hour * 60 + widget.previousEndTime!.minute;
      if (startMinutes < previousEndMinutes) {
        setState(() => _errorMessage =
            'Start time must be after previous destination\'s end time');
        return false;
      }
    }

    if (widget.nextStartTime != null) {
      final nextStartMinutes =
          widget.nextStartTime!.hour * 60 + widget.nextStartTime!.minute;
      if (endMinutes > nextStartMinutes) {
        setState(() => _errorMessage =
            'End time must be before next destination\'s start time');
        return false;
      }
    }

    setState(() => _errorMessage = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Timeline',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildTimePickerTile(
                    'Start Time',
                    _startTime,
                    (time) {
                      if (time != null) {
                        setState(() {
                          _startTime = time;
                          _endTime = TimeOfDay(
                            hour: (time.hour + 1) % 24,
                            minute: time.minute,
                          );
                        });
                        _isValidTimeRange(_startTime, _endTime);
                      }
                    },
                  ),
                  Divider(height: 1.h, color: Colors.grey[300]),
                  _buildTimePickerTile(
                    'End Time',
                    _endTime,
                    (time) {
                      if (time != null) {
                        setState(() => _endTime = time);
                        _isValidTimeRange(_startTime, _endTime);
                      }
                    },
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 12.h),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 24.h),
            Row(
              children: [
                if (widget.onDelete != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (widget.onDelete != null) SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isValidTimeRange(_startTime, _endTime)) {
                        final timeline =
                            '${_formatTimeOfDay(_startTime)} - ${_formatTimeOfDay(_endTime)}';
                        Navigator.pop(context, timeline);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerTile(
    String title,
    TimeOfDay time,
    Function(TimeOfDay?) onTimeSelected,
  ) {
    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        onTimeSelected(newTime);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.black,
              ),
            ),
            Text(
              _formatTimeOfDay(time),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
