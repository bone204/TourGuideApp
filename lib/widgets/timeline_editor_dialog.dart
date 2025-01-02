import 'package:flutter/material.dart';

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
    final components = timeStr.split(' ');
    final timeComponents = components[0].split(':');
    int hour = int.parse(timeComponents[0]);
    final minute = int.parse(timeComponents[1]);

    if (components[1] == 'PM' && hour != 12) {
      hour += 12;
    } else if (components[1] == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
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
    return AlertDialog(
      title: const Text('Edit Timeline'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            trailing: Text(_formatTimeOfDay(_startTime)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) {
                if (_isValidTimeRange(time, _endTime)) {
                  setState(() => _startTime = time);
                }
              }
            },
          ),
          ListTile(
            title: const Text('End Time'),
            trailing: Text(_formatTimeOfDay(_endTime)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) {
                if (_isValidTimeRange(_startTime, time)) {
                  setState(() => _endTime = time);
                }
              }
            },
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onDelete,
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_isValidTimeRange(_startTime, _endTime)) {
              final timeline =
                  '${_formatTimeOfDay(_startTime)} - ${_formatTimeOfDay(_endTime)}';
              Navigator.pop(context, timeline);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
