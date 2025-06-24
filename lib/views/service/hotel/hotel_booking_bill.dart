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
import 'package:tourguideapp/widgets/app_dialog.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/viewmodels/profile_viewmodel.dart';
import 'package:tourguideapp/models/voucher_model.dart';
import 'package:tourguideapp/views/service/voucher/voucher_selection_screen.dart';

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
  int travelPointToUse = 0;
  VoucherModel? selectedVoucher;
  bool _isBookingSaved = false;
  bool _isProcessingPayment = false;

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
    // Kiểm tra xem đã lưu chưa để tránh duplicate
    if (_isBookingSaved) {
      print('Hotel booking already saved, skipping duplicate save');
      return;
    }

    // Kiểm tra xem đang xử lý thanh toán không để tránh duplicate
    if (_isProcessingPayment) {
      print('Payment is already being processed, skipping duplicate payment');
      return;
    }

    // Đánh dấu đang xử lý thanh toán
    _isProcessingPayment = true;

    if (selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('Please select a payment method')),
          backgroundColor: Colors.red,
        ),
      );
      _isProcessingPayment = false; // Reset trạng thái
      return;
    }

    if (roomAvailability == null || !roomAvailability!.hasAvailability) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('No rooms available for the selected dates')),
          backgroundColor: Colors.red,
        ),
      );
      _isProcessingPayment = false; // Reset trạng thái
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
        throw Exception(AppLocalizations.of(context)
            .translate('Booking failed, please try again'));
      }

      // Tính tổng tiền
      final numberOfNights = checkOutDate.difference(checkInDate).inDays;
      final totalPrice =
          roomAvailability!.price * numberOfNights * numberOfRooms;
      final totalAfterPoint =
          (totalPrice - travelPointToUse).clamp(0, totalPrice).toDouble();
      final voucherDiscount = selectedVoucher != null
          ? selectedVoucher!.calculateDiscount(totalAfterPoint)
          : 0.0;
      final totalAfterVoucher = (totalAfterPoint - voucherDiscount)
          .clamp(0, totalAfterPoint)
          .toDouble();

      // Tạo bill trong database
      final bill = HotelBillModel(
        billId: '',
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        checkInDate: DateFormat('yyyy-MM-dd').format(checkInDate),
        checkOutDate: DateFormat('yyyy-MM-dd').format(checkOutDate),
        createdDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        numberOfRooms: numberOfRooms,
        total: totalAfterVoucher,
        voucherId: selectedVoucher?.voucherId ?? '',
        travelPointsUsed: travelPointToUse,
        status: 'confirmed',
        roomIds: [roomAvailability!.roomId],
      );

      final billId = await _hotelService.createHotelBooking(bill);

      // Trừ điểm thưởng
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null && travelPointToUse > 0) {
        await FirebaseFirestore.instance.collection('USER').doc(userId).update({
          'travelPoint': FieldValue.increment(-travelPointToUse),
        });
      }
      // Cộng điểm thưởng
      final reward = totalAfterVoucher > 500000 ? 2000 : 1000;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('USER').doc(userId).update({
          'travelPoint': FieldValue.increment(reward),
        });
      }

      // Đánh dấu đã lưu thành công
      _isBookingSaved = true;

      // Hiển thị thông báo thành công
      if (mounted) {
        showAppDialog(
          context: context,
          title: AppLocalizations.of(context).translate('Notification'),
          content: AppLocalizations.of(context).translate(
              'Your hotel booking has been confirmed. The service will be added to your used list.'),
          icon: Icons.check_circle,
          iconColor: Colors.green,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(AppLocalizations.of(context).translate('OK')),
            ),
          ],
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).translate('Error:') + ' $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset trạng thái xử lý thanh toán
      _isProcessingPayment = false;
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
              child: Consumer<ProfileViewModel>(
                builder: (context, profile, child) {
                  final travelPoint = profile.travelPoint;
                  final List<int> travelPointOptions = [];
                  for (int i = 1000; i <= travelPoint; i += 1000) {
                    travelPointOptions.add(i);
                  }
                  final total = roomAvailability != null
                      ? roomAvailability!.price *
                          checkOutDate.difference(checkInDate).inDays *
                          numberOfRooms
                      : 0;
                  final totalAfterPoint =
                      (total - travelPointToUse).clamp(0, total).toDouble();
                  final voucherDiscount = selectedVoucher != null
                      ? selectedVoucher!.calculateDiscount(totalAfterPoint)
                      : 0.0;
                  final totalAfterVoucher = (totalAfterPoint - voucherDiscount)
                      .clamp(0, totalAfterPoint)
                      .toDouble();
                  return Column(children: [
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
                        Text(AppLocalizations.of(context).translate("Hotel"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
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
                        Text(AppLocalizations.of(context).translate("Room"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
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
                        Text(
                            AppLocalizations.of(context)
                                .translate("Check-in Date"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
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
                        Text(
                            AppLocalizations.of(context)
                                .translate("Check-out Date"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
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

                    // Chọn điểm thưởng
                    if (roomAvailability != null &&
                        travelPointOptions.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.orange.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Sử dụng điểm thưởng',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Điểm hiện có: ${currencyFormat.format(travelPoint)} điểm',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: DropdownButtonFormField<int>(
                                value: travelPointToUse,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 12.h),
                                  hintText: 'Chọn số điểm muốn sử dụng',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel_outlined,
                                            color: Colors.grey, size: 16.sp),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Không sử dụng điểm',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...travelPointOptions
                                      .map((points) => DropdownMenuItem(
                                            value: points,
                                            child: Text(
                                              '${currencyFormat.format(points)} điểm (-${currencyFormat.format(points)} ₫)',
                                              style: TextStyle(
                                                color: Colors.orange.shade800,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    travelPointToUse = value ?? 0;
                                  });
                                },
                                dropdownColor: Colors.white,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: Colors.orange),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                            if (travelPointToUse > 0) ...[
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border:
                                      Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.savings,
                                        color: Colors.green, size: 16.sp),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Tiết kiệm: ${currencyFormat.format(travelPointToUse)} ₫',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Chọn voucher
                    if (roomAvailability != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Voucher',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w700)),
                                GestureDetector(
                                  onTap: () async {
                                    final result =
                                        await Navigator.push<VoucherModel>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VoucherSelectionScreen(
                                          totalAmount: totalAfterPoint,
                                          onVoucherSelected: (voucher) {
                                            setState(() {
                                              selectedVoucher = voucher;
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        selectedVoucher = result;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Text(
                                      selectedVoucher != null
                                          ? 'Thay đổi'
                                          : 'Chọn voucher',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            if (selectedVoucher != null) ...[
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_offer,
                                      color: AppColors.primaryColor,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'GIẢM ${selectedVoucher!.value}% HÓA ĐƠN',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          Text(
                                            'Tiết kiệm: ${currencyFormat.format(voucherDiscount)} ₫',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedVoucher = null;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.grey,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Text(
                                'Chưa chọn voucher',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Tổng tiền
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context).translate("Total"),
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.black,
                                fontWeight: FontWeight.w700)),
                        Text('${currencyFormat.format(total)} ₫',
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.black,
                                fontWeight: FontWeight.w700))
                      ],
                    ),
                    if (travelPointToUse > 0 || selectedVoucher != null) ...[
                      SizedBox(height: 12.h),
                      Divider(height: 1, color: Colors.grey.shade300),
                      SizedBox(height: 8.h),
                      if (selectedVoucher != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Giảm ${selectedVoucher!.value}% voucher:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '-${currencyFormat.format(voucherDiscount)} ₫',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sau voucher:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(totalAfterVoucher)} ₫',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                      ],
                      if (travelPointToUse > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trừ điểm thưởng:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '-${currencyFormat.format(travelPointToUse)} ₫',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                      ],
                      Divider(height: 1, color: Colors.grey.shade300),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng thanh toán:',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            '${currencyFormat.format(totalAfterVoucher)} ₫',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Payment methods
                    Text(
                      AppLocalizations.of(context).translate("Payment Method"),
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
                      onPressed: (roomAvailability?.hasAvailability ?? false) &&
                              !_isProcessingPayment
                          ? () async {
                              if (selectedBank == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)
                                        .translate(
                                            'Please select a payment method')),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (selectedBank == 'momo') {
                                await MomoService.processPayment(
                                  merchantName: 'TTN',
                                  appScheme: 'MOMO',
                                  merchantCode: 'MOMO',
                                  partnerCode: 'MOMO',
                                  amount: totalAfterVoucher.toInt(),
                                  orderId: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  orderLabel: 'Đặt phòng khách sạn',
                                  merchantNameLabel: 'HLGD',
                                  fee: 0,
                                  description: 'Thanh toán đặt phòng khách sạn',
                                  username:
                                      FirebaseAuth.instance.currentUser?.uid ??
                                          '',
                                  partner: 'merchant',
                                  extra:
                                      '{"hotelId":"${widget.hotel.cooperationId}","roomId":"${roomAvailability!.roomId}"}',
                                  isTestMode: true,
                                  onSuccess: (response) async {
                                    // Gọi _processPayment để lưu bill
                                    await _processPayment();
                                  },
                                  onError: (response) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(AppLocalizations.of(
                                                      context)
                                                  .translate(
                                                      'MoMo payment failed:') +
                                              ' ${response.message}'),
                                          backgroundColor: Colors.red),
                                    );
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)
                                        .translate(
                                            'This feature will be available soon!')),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isProcessingPayment
                            ? Colors.grey
                            : const Color(0xFF007BFF),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: _isProcessingPayment
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Đang xử lý...',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              AppLocalizations.of(context).translate("Confirm"),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ]);
                },
              ),
            ),
          ),
        ));
  }
}
