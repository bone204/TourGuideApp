import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/restaurant/restaurant_booking_bill.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/date_and_time_picker.dart';
import 'package:tourguideapp/widgets/person_picker.dart';
import 'package:tourguideapp/widgets/table_card.dart';
import 'package:tourguideapp/models/cooperation_model.dart';

class TableListScreen extends StatefulWidget {
  final CooperationModel restaurant;

  const TableListScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<TableListScreen> createState() => _TableListScreenState();
}

class _TableListScreenState extends State<TableListScreen> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late PersonCount personCount;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    personCount = PersonCount(adults: 2, children: 0);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      selectedTime = time;
    });
  }

  void _onPersonCountChanged(PersonCount count) {
    setState(() {
      personCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 40.h,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomIconButton(
                        icon: Icons.chevron_left,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)
                            .translate(widget.restaurant.name),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: DateAndTimePicker(
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onDateSelected: _onDateSelected,
                    onTimeSelected: _onTimeSelected,
                  ),
                ),
                SizedBox(width: 12.w),
                PersonPicker(
                  personCount: personCount,
                  onPersonCountChanged: _onPersonCountChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              itemCount: 3,
              itemBuilder: (context, index) {
                return TableCard(
                  name: 'VIP Table ${index + 1}',
                  capacity: 4,
                  location: 'Window Side',
                  tablesLeft: 2,
                  price: 450000,
                  imageUrl:
                      "https://www.mydomaine.com/thmb/9vOxtjXGcq8Ajsu4G5yF7PXHepw=/2000x0/filters:no_upscale():strip_icc()/dining-room-table-decor-ideas-21-mindy-gayer-marigold-project-6a8c8379f8c94eb785747e3305803588.jpg",
                  onChoose: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RestaurantBookingBillScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
