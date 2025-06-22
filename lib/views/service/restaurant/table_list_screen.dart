import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/views/service/restaurant/restaurant_booking_bill.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/date_and_time_picker.dart';
import 'package:tourguideapp/widgets/person_picker.dart';
import 'package:tourguideapp/widgets/table_card.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/models/table_availability_model.dart';
import 'package:tourguideapp/core/services/restaurant_service.dart';

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
  final RestaurantService _restaurantService = RestaurantService();
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late PersonCount personCount;
  List<TableAvailabilityModel> availableTables = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    personCount = PersonCount(adults: 2, children: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTableAvailability();
    });
  }

  Future<void> _checkTableAvailability() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final tables = await _restaurantService.checkTableAvailability(
        restaurantId: widget.restaurant.cooperationId,
        checkInDate: selectedDate,
        checkInTime: selectedTime,
      );

      setState(() {
        availableTables = tables;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Lỗi khi kiểm tra bàn trống: $e';
        isLoading = false;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _checkTableAvailability();
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      selectedTime = time;
    });
    _checkTableAvailability();
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              error!,
                              style:
                                  TextStyle(fontSize: 16.sp, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _checkTableAvailability,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : availableTables.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.table_restaurant,
                                  size: 64.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Không có bàn trống cho thời gian này',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Vui lòng chọn thời gian khác',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 20.h),
                            itemCount: availableTables.length,
                            itemBuilder: (context, index) {
                              final table = availableTables[index];

                              // Kiểm tra xem bàn có phù hợp với số người không
                              final isSuitableForGroup =
                                  table.capacity >= personCount.total;

                              return TableCard(
                                name: table.tableName,
                                capacity: table.capacity,
                                location: table.location,
                                tablesLeft: table.availableTables,
                                price: table.price,
                                imageUrl: table.photo,
                                onChoose: isSuitableForGroup
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RestaurantBookingBillScreen(
                                              restaurant: widget.restaurant,
                                              table: table,
                                              checkInDate: selectedDate,
                                              checkInTime: selectedTime,
                                              numberOfPeople: personCount.total,
                                            ),
                                          ),
                                        );
                                      }
                                    : () {},
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
