import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/models/room_model.dart';
import 'package:tourguideapp/models/hotel_bill_model.dart';
import 'package:tourguideapp/models/room_availability_model.dart';
import 'package:tourguideapp/core/services/hotel_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/core/services/momo_service.dart';

class HotelBookingBillScreen extends StatefulWidget {
  final CooperationModel hotel;
  final RoomModel? room;
  final RoomAvailabilityModel? roomAvailability;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? numberOfGuests;

  const HotelBookingBillScreen({
    super.key,
    required this.hotel,
    this.room,
    this.roomAvailability,
    this.checkInDate,
    this.checkOutDate,
    this.numberOfGuests,
  });

  @override
  State<HotelBookingBillScreen> createState() => _HotelBookingBillScreenState();
}

class _HotelBookingBillScreenState extends State<HotelBookingBillScreen> {
  String? selectedBank;
  final HotelService _hotelService = HotelService();
  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  // Thông tin booking
  late DateTime checkInDate;
  late DateTime checkOutDate;
  int numberOfRooms = 1;
  late int numberOfGuests;

  // Thông tin phòng trống
  RoomAvailabilityModel? roomAvailability;
  bool isLoadingAvailability = false;

  final List<Map<String, String>> bankOptions = [
    {'id': 'visa', 'image': 'assets/img/Logo_Visa.png'},
    {'id': 'mastercard', 'image': 'assets/img/Logo_Mastercard.png'},
    {'id': 'paypal', 'image': 'assets/img/Logo_PayPal.png'},
    {'id': 'momo', 'image': 'assets/img/Logo_Momo.png'},
    {'id': 'zalopay', 'image': 'assets/img/Logo_Zalopay.png'},
    {'id': 'shopee', 'image': 'assets/img/Logo_Shopee.png'},
  ];

  @override
  void initState() {
    super.initState();

    // Khởi tạo thông tin booking
    checkInDate =
        widget.checkInDate ?? DateTime.now().add(const Duration(days: 1));
    checkOutDate =
        widget.checkOutDate ?? DateTime.now().add(const Duration(days: 2));
    numberOfGuests = widget.numberOfGuests ?? 2;

    // Nếu có roomAvailability được truyền vào, sử dụng luôn
    if (widget.roomAvailability != null) {
      roomAvailability = widget.roomAvailability;
    } else {
      // Nếu không có, kiểm tra availability
      _checkRoomAvailability();
    }
  }

  Future<void> _checkRoomAvailability() async {
    if (widget.room == null) return;

    setState(() {
      isLoadingAvailability = true;
    });

    try {
      final availabilityList = await _hotelService.checkRoomAvailability(
        hotelId: widget.hotel.cooperationId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        roomType: widget.room!.roomType,
      );

      // Tìm phòng phù hợp
      roomAvailability = availabilityList.firstWhere(
        (availability) => availability.roomType == widget.room!.roomType,
        orElse: () => RoomAvailabilityModel(
          roomId: widget.room!.roomId,
          roomName: widget.room!.roomName,
          roomType: widget.room!.roomType,
          capacity: widget.room!.capacity,
          price: widget.room!.basePrice,
          availableRooms: 0,
          totalRooms: 1,
          photo: widget.room!.photo,
          amenities: widget.room!.amenities,
          description: widget.room!.description,
        ),
      );

      setState(() {
        isLoadingAvailability = false;
      });
    } catch (e) {
      print('Error checking availability: $e');
      setState(() {
        isLoadingAvailability = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn phương thức thanh toán'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (roomAvailability == null || !roomAvailability!.hasAvailability) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phòng không còn trống cho ngày đã chọn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Gọi API đặt phòng
      final bookingSuccess = await _hotelService.bookRoom(
        hotelId: widget.hotel.cooperationId,
        roomId: roomAvailability!.roomId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfRooms: numberOfRooms,
      );

      if (!bookingSuccess) {
        throw Exception('Đặt phòng thất bại, vui lòng thử lại');
      }

      // Tính tổng tiền
      final numberOfNights = checkOutDate.difference(checkInDate).inDays;
      final totalPrice =
          roomAvailability!.price * numberOfNights * numberOfRooms;

      // Tạo bill trong database
      final bill = HotelBillModel(
        billId: '',
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        checkInDate: DateFormat('yyyy-MM-dd').format(checkInDate),
        checkOutDate: DateFormat('yyyy-MM-dd').format(checkOutDate),
        createdDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        numberOfRooms: numberOfRooms,
        total: totalPrice,
        voucherId: '',
        travelPointsUsed: 0,
        status: 'confirmed',
        roomIds: [roomAvailability!.roomId],
      );

      final billId = await _hotelService.createHotelBooking(bill);

      // Hiển thị thông báo thành công
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Thanh toán thành công!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Đặt phòng khách sạn của bạn đã được xác nhận. Dịch vụ sẽ được thêm vào danh sách đã sử dụng.',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('OK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
        onBackPressed: () {
          Navigator.of(context).pop();
        },
        title: AppLocalizations.of(context).translate("Booking Information"),
      ),
        body: SingleChildScrollView(
          child: Container(
            color: AppColors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(children: [
                // Hotel image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    widget.room?.photo.isNotEmpty == true
                        ? widget.room!.photo
                        : widget.hotel.photo,
                    height: 256.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8.h),
                const Divider(
                  thickness: 1,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16.h),

                // Hotel information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Hotel:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text(widget.hotel.name,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Room:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text(widget.room?.roomName ?? '',
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(
                  thickness: 1,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16.h),

                // Date information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Check-in Date:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text(DateFormat('dd/MM/yyyy').format(checkInDate),
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Check-out Date:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text(DateFormat('dd/MM/yyyy').format(checkOutDate),
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700))
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(
                  thickness: 1,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16.h),

                // Room availability information
                if (isLoadingAvailability) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Đang kiểm tra phòng trống...",
                        style:
                            TextStyle(fontSize: 14.sp, color: AppColors.grey),
                      ),
                    ],
                  ),
                ] else if (roomAvailability != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Phòng trống:",
                          style: TextStyle(
                              fontSize: 16.sp, color: AppColors.black)),
                      Text(
                          roomAvailability!.hasAvailability
                              ? "${roomAvailability!.availableRooms} phòng"
                              : "Hết phòng",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: roomAvailability!.hasAvailability
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Số đêm:",
                          style: TextStyle(
                              fontSize: 16.sp, color: AppColors.black)),
                      Text("${checkOutDate.difference(checkInDate).inDays} đêm",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Giá/đêm:",
                          style: TextStyle(
                              fontSize: 16.sp, color: AppColors.black)),
                      Text(
                          "${currencyFormat.format(roomAvailability!.price)} ₫",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ],
                SizedBox(height: 16.h),
                const Divider(
                  thickness: 1,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16.h),

                // Total
                if (roomAvailability != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tổng cộng:",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w700)),
                      Text(
                          '${currencyFormat.format(roomAvailability!.price * checkOutDate.difference(checkInDate).inDays * numberOfRooms)} ₫',
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],

                // Payment methods
                Text(
                  "Chọn phương thức thanh toán:",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 16.h),

                // Hàng 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: bankOptions
                      .sublist(0, 3)
                      .map((bank) => BankOptionSelector(
                            bankImageUrl: bank['image']!,
                            isSelected: selectedBank == bank['id'],
                            onTap: () {
                              setState(() {
                                selectedBank = bank['id'];
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 24.h),
                // Hàng 2
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: bankOptions
                      .sublist(3, 6)
                      .map((bank) => BankOptionSelector(
                            bankImageUrl: bank['image']!,
                            isSelected: selectedBank == bank['id'],
                            onTap: () {
                              setState(() {
                                selectedBank = bank['id'];
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 24.h),

                // Confirm button
                ElevatedButton(
                  onPressed: (roomAvailability?.hasAvailability ?? false)
                      ? () async {
                          if (selectedBank == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng chọn phương thức thanh toán'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (selectedBank == 'momo') {
                            // Gọi thanh toán momo
                            // TODO: Thay các tham số bên dưới bằng dữ liệu thực tế của bạn
                            await MomoService.processPayment(
                              merchantName: 'TTN',
                              appScheme: 'MOMO',
                              merchantCode: 'MOMO',
                              partnerCode: 'MOMO',
                              amount: (roomAvailability!.price * (checkOutDate.difference(checkInDate).inDays) * numberOfRooms).toInt(),
                              orderId: DateTime.now().millisecondsSinceEpoch.toString(),
                              orderLabel: 'Đặt phòng khách sạn',
                              merchantNameLabel: 'HLGD',
                              fee: 0,
                              description: 'Thanh toán đặt phòng khách sạn',
                              username: FirebaseAuth.instance.currentUser?.uid ?? '',
                              partner: 'merchant',
                              extra: '{"hotelId":"${widget.hotel.cooperationId}","roomId":"${roomAvailability!.roomId}"}',
                              isTestMode: true,
                              onSuccess: (response) async {
                                // Gọi _processPayment để lưu bill
                                await _processPayment();
                              },
                              onError: (response) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Thanh toán MoMo thất bại: ${response.message}'), backgroundColor: Colors.red),
                                );
                              },
                            );
                          } else {
                            // Các phương thức khác chỉ hiện thông báo Coming soon
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng này sẽ sớm ra mắt!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text(AppLocalizations.of(context).translate("Confirm"),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ]),
            ),
          ),
        ));
  }
}
