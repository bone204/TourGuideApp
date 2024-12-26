import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/date_and_time_picker.dart';
import 'package:tourguideapp/widgets/person_picker.dart';

class TableListScreen extends StatefulWidget {
  final String restaurantName;
  
  const TableListScreen({
    super.key, 
    required this.restaurantName,
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
                        AppLocalizations.of(context).translate(widget.restaurantName),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
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
          // Expanded(
          //   child: ListView.builder(
          //     padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          //     itemCount: 3,
          //     itemBuilder: (context, index) {
          //       return RoomCard(
          //         name: 'Deluxe Room',
          //         area: '22.0 m²',
          //         bedType: '1 queen bed',
          //         bathType: 'Shower',
          //         maxPerson: 2,
          //         roomsLeft: 1,
          //         price: 650000,
          //         imageUrl: 'https://dq5r178u4t83b.cloudfront.net/wp-content/uploads/sites/125/2021/08/11060441/deluxe_harbour_web.jpg',
          //         onChoose: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => const HotelBookingBillScreen(),
          //             ),
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
} 