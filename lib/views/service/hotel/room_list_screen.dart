import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/range_date_time_picker.dart';
import 'package:tourguideapp/widgets/person_picker.dart';
import 'package:tourguideapp/widgets/room_card.dart';

class RoomListScreen extends StatefulWidget {
  final String hotelName;
  
  const RoomListScreen({
    super.key, 
    required this.hotelName,
  });

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late DateTime startDate;
  late DateTime endDate;
  late PersonCount personCount;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    endDate = DateTime.now().add(const Duration(days: 1));
    personCount = PersonCount(adults: 2, children: 0);
  }

  void _onDateRangeSelected(DateTimeRange dateRange) {
    setState(() {
      startDate = dateRange.start;
      endDate = dateRange.end;
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
                        AppLocalizations.of(context).translate(widget.hotelName),
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
                  child: RangeDateTimePicker(
                    startDate: startDate,
                    endDate: endDate,
                    onDateRangeSelected: _onDateRangeSelected,
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
                return RoomCard(
                  name: 'Deluxe Room',
                  area: '22.0 m²',
                  bedType: '1 queen bed',
                  bathType: 'Shower',
                  maxPerson: 2,
                  roomsLeft: 1,
                  price: 650000,
                  imageUrl: 'https://dq5r178u4t83b.cloudfront.net/wp-content/uploads/sites/125/2021/08/11060441/deluxe_harbour_web.jpg',
                  onChoose: () {
                    // Xử lý khi nhấn nút Choose
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