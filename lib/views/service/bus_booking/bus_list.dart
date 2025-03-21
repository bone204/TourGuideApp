import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/date_time_picker.dart';

class BusListScreen extends StatefulWidget {
  final DateTime arrivalDate;
  final DateTime? departureDate;

  const BusListScreen({
    super.key,
    required this.arrivalDate,
    this.departureDate,
  });

  @override
  _BusListScreenState createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen>{
  late DateTime arrivalDate;
  late DateTime? departureDate;

  @override
  void initState() {
    super.initState();
    arrivalDate = widget.arrivalDate;
    departureDate = widget.departureDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
      title: AppLocalizations.of(context).translate('Bus List'),
      onBackPressed: () => Navigator.of(context).pop(),
    ),
    body: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DateTimePicker(
                selectedDate: arrivalDate,
                onDateSelected: (date) {
                  setState(() {
                    arrivalDate = date;
                    if (widget.departureDate != null && widget.departureDate!.isBefore(date)) {
                      arrivalDate = date;
                    }
                  });
                },
                title: AppLocalizations.of(context).translate("Arrival Date"),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: DateTimePicker(
                selectedDate: arrivalDate,
                onDateSelected: (date) {
                  setState(() {
                    arrivalDate = date;
                    if (widget.departureDate != null && widget.departureDate!.isBefore(date)) {
                      arrivalDate = date;
                    }
                  });
                },
                title: AppLocalizations.of(context).translate("Arrival Date"),
              ),
            ),
          ],
        )
      ],
    ),
    );
  }
}