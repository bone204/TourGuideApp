import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/models/room_availability_model.dart';
import 'package:tourguideapp/core/services/hotel_service.dart';
import 'package:tourguideapp/views/service/hotel/hotel_booking_bill.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/widgets/range_date_time_picker.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class RoomListScreen extends StatefulWidget {
  final CooperationModel hotel;

  const RoomListScreen({super.key, required this.hotel});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final HotelService _hotelService = HotelService();
  List<RoomAvailabilityModel> rooms = [];
  bool isLoading = true;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int? numberOfGuests;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Lấy thông tin từ navigation arguments hoặc sử dụng ngày mặc định
      checkInDate ??= DateTime.now().add(const Duration(days: 1));
      checkOutDate ??= DateTime.now().add(const Duration(days: 2));
      numberOfGuests ??= 2;

      // Kiểm tra phòng trống cho khách sạn
      final availability = await _hotelService.checkRoomAvailability(
        hotelId: widget.hotel.cooperationId,
        checkInDate: checkInDate!,
        checkOutDate: checkOutDate!,
      );

      setState(() {
        rooms = availability;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading rooms: $e');
      setState(() {
        isLoading = false;
        rooms = _getSampleRooms();
      });
    }
  }

  // Dữ liệu mẫu cho phòng
  List<RoomAvailabilityModel> _getSampleRooms() {
    return [
      RoomAvailabilityModel(
        roomId: 'R00001',
        roomName: AppLocalizations.of(context).translate("Standard Room"),
        roomType: AppLocalizations.of(context).translate("Standard"),
        capacity: 2,
        price: 800000,
        availableRooms: 5,
        totalRooms: 10,
        photo:
            'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        amenities: [
          AppLocalizations.of(context).translate("WiFi"),
          AppLocalizations.of(context).translate("TV"),
          AppLocalizations.of(context).translate("Air conditioning"),
          AppLocalizations.of(context).translate("Refrigerator")
        ],
        description: AppLocalizations.of(context).translate("Standard room with basic amenities"),
      ),
      RoomAvailabilityModel(
        roomId: 'R00002',
        roomName: AppLocalizations.of(context).translate("Deluxe Room"),
        roomType: AppLocalizations.of(context).translate("Deluxe"),
        capacity: 3,
        price: 1200000,
        availableRooms: 3,
        totalRooms: 8,
        photo:
            'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400',
        amenities: [
          AppLocalizations.of(context).translate("WiFi"),
          AppLocalizations.of(context).translate("TV"),
          AppLocalizations.of(context).translate("Air conditioning"),
          AppLocalizations.of(context).translate("Refrigerator"),
          AppLocalizations.of(context).translate("Mini bar"),
          AppLocalizations.of(context).translate("Bathtub")
        ],
        description: AppLocalizations.of(context).translate("Luxury room with beautiful view and elegant amenities"),
      ),
      RoomAvailabilityModel(
        roomId: 'R00003',
        roomName: AppLocalizations.of(context).translate("Suite Room"),
        roomType: AppLocalizations.of(context).translate("Suite"),
        capacity: 4,
        price: 2000000,
        availableRooms: 1,
        totalRooms: 3,
        photo:
            'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400',
        amenities: [
          AppLocalizations.of(context).translate("WiFi"),
          AppLocalizations.of(context).translate("TV"),
          AppLocalizations.of(context).translate("Air conditioning"),
          AppLocalizations.of(context).translate("Refrigerator"),
          AppLocalizations.of(context).translate("Mini bar"),
          AppLocalizations.of(context).translate("Bathtub"),
          AppLocalizations.of(context).translate("Living room"),
          AppLocalizations.of(context).translate("Balcony")
        ],
        description: AppLocalizations.of(context).translate("Luxury suite with spacious space"),
      ),
    ];
  }

  void _bookRoom(RoomAvailabilityModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelBookingBillScreen(
          hotel: widget.hotel,
          roomAvailability: room,
          checkInDate: checkInDate,
          checkOutDate: checkOutDate,
          numberOfGuests: numberOfGuests,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.hotel.name,
        onBackPressed: () {
          Navigator.of(context).pop();
        }
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bed, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).translate("No rooms available"),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // RangeDateTimePicker để chọn lại ngày nhận/trả phòng
                    Padding(
                      padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 16.h),
                      child: RangeDateTimePicker(
                        startDate: checkInDate!,
                        endDate: checkOutDate!,
                        onDateRangeSelected: (range) async {
                          setState(() {
                            checkInDate = range.start;
                            checkOutDate = range.end;
                          });
                          await _loadRooms();
                        },
                      ),
                    ),
                    // Danh sách phòng
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 16.h),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          final numberOfNights =
                              checkOutDate!.difference(checkInDate!).inDays;
                          final totalPrice = room.price * numberOfNights;

                          return Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ảnh phòng
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.r),
                                    topRight: Radius.circular(12.r),
                                  ),
                                  child: Image.network(
                                    room.photo,
                                    height: 200.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Thông tin phòng
                                Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              room.roomName,
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: room.hasAvailability
                                                  ? Colors.green[50]
                                                  : Colors.red[50],
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Text(
                                              room.status,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: room.hasAvailability
                                                    ? Colors.green[700]
                                                    : Colors.red[700],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        room.description,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      // Tiện nghi
                                      Wrap(
                                        spacing: 8.w,
                                        runSpacing: 8.h,
                                        children: room.amenities.map((amenity) {
                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: Text(
                                              amenity,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 16.h),
                                      // Thông tin giá và đặt phòng
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${NumberFormat('#,###', 'vi_VN').format(room.price.toInt())} ₫${AppLocalizations.of(context).translate("per night")}',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Text(
                                                '${AppLocalizations.of(context).translate("Total")}: ${NumberFormat('#,###', 'vi_VN').format(totalPrice.toInt())} ₫',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                '${room.capacity} ${AppLocalizations.of(context).translate("people")} • ${room.availableRooms}/${room.totalRooms} ${AppLocalizations.of(context).translate("available rooms")}',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: room.hasAvailability
                                                ? () => _bookRoom(room)
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  room.hasAvailability
                                                      ? Colors.red
                                                      : Colors.grey,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                            ),
                                            child: Text(
                                              room.hasAvailability
                                                  ? AppLocalizations.of(context).translate("Book room")
                                                  : AppLocalizations.of(context).translate("No rooms left"),
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
