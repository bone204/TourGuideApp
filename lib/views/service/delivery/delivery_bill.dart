import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/core/services/momo_service.dart';
import 'package:tourguideapp/widgets/app_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:tourguideapp/core/services/used_services_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/viewmodels/profile_viewmodel.dart';
import 'package:tourguideapp/models/voucher_model.dart';
import 'package:tourguideapp/views/service/voucher/voucher_selection_screen.dart';
//import 'package:tourguideapp/services/momo_payment_service.dart';
//import 'package:uuid/uuid.dart';

class DeliveryBill extends StatefulWidget {
  final CooperationModel? selectedBrand;
  final String selectedVehicle;
  final String pickupLocation;
  final String deliveryLocation;
  final String recipientName;
  final String recipientPhone;
  final String senderName;
  final String senderPhone;
  final String requirements;
  final List<String> packagePhotos;

  const DeliveryBill({
    super.key,
    this.selectedBrand,
    this.selectedVehicle = 'Motorbike',
    this.pickupLocation = '',
    this.deliveryLocation = '',
    this.recipientName = '',
    this.recipientPhone = '',
    this.senderName = '',
    this.senderPhone = '',
    this.requirements = '',
    this.packagePhotos = const [],
  });

  @override
  State<DeliveryBill> createState() => _DeliveryBillState();
}

class _DeliveryBillState extends State<DeliveryBill> {
  String? selectedBank;
  final currencyFormat = NumberFormat('#,###', 'vi_VN');
  final UsedServicesService _usedServicesService = UsedServicesService();
  int travelPointToUse = 0;
  VoucherModel? selectedVoucher;

  final List<Map<String, String>> bankOptions = [
    {'id': 'visa', 'image': 'assets/img/Logo_Visa.png'},
    {'id': 'mastercard', 'image': 'assets/img/Logo_Mastercard.png'},
    {'id': 'paypal', 'image': 'assets/img/Logo_PayPal.png'},
    {'id': 'momo', 'image': 'assets/img/Logo_Momo.png'},
    {'id': 'zalopay', 'image': 'assets/img/Logo_Zalopay.png'},
    {'id': 'shopee', 'image': 'assets/img/Logo_Shopee.png'},
  ];

  // Giá cố định cho delivery
  final int deliveryPrice = 650000;

  Future<void> _processPayment() async {
    try {
      // Tạo order ID
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Tính tổng tiền sau khi trừ travelPoint và voucher
      final totalAfterPoint =
          (deliveryPrice - travelPointToUse).clamp(0, deliveryPrice).toDouble();
      final totalAfterVoucher = selectedVoucher != null
          ? (totalAfterPoint -
                  selectedVoucher!.calculateDiscount(totalAfterPoint))
              .clamp(0, totalAfterPoint)
              .toDouble()
          : totalAfterPoint;

      // Lưu vào used services
      await _usedServicesService.addDeliveryOrderToUsedServices(
        userId: currentUser.uid,
        orderId: orderId,
        deliveryBrandName: widget.selectedBrand?.name ?? 'Delivery Service',
        selectedVehicle: widget.selectedVehicle,
        pickupLocation: widget.pickupLocation,
        deliveryLocation: widget.deliveryLocation,
        recipientName: widget.recipientName,
        recipientPhone: widget.recipientPhone,
        senderName: widget.senderName,
        senderPhone: widget.senderPhone,
        requirements: widget.requirements,
        amount: totalAfterVoucher,
        packagePhotos: widget.packagePhotos,
        travelPointsUsed: travelPointToUse,
        status: 'confirmed',
      );

      // Hiển thị thông báo thành công
      if (mounted) {
        showAppDialog(
          context: context,
          title: AppLocalizations.of(context).translate('Notification'),
          content: AppLocalizations.of(context).translate(
              'Your delivery order has been confirmed. The service will be added to your used list.'),
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
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeMomo();
  // }

  // Future<void> _initializeMomo() async {
  //   await _momoService.initializeMomo();
  // }

  // Future<void> _handleMomoPayment() async {
  //   if (selectedBank != 'momo') return;

  //   final orderId = _uuid.v4();
  //   final amount = '650000';

  //   await _momoService.requestPayment(
  //     amount: amount,
  //     orderId: orderId,
  //     orderLabel: 'Thanh toán đơn giao hàng',
  //     orderInfo: 'Thanh toán đơn giao hàng - $orderId',
  //     customerName: 'Nguyễn Hữu Trường',
  //     customerEmail: 'customer@example.com',
  //     customerPhone: '0914259475',
  //     context: context,
  //     onSuccess: (String message) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Thanh toán thành công: $message'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       Navigator.of(context).pop();
  //     },
  //     onError: (String error) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Lỗi thanh toán: $error'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     },
  //   );
  // }

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
                            .translate('Delivery Information'),
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
                final total = deliveryPrice;
                final totalAfterPoint =
                    (total - travelPointToUse).clamp(0, total).toDouble();
                final totalAfterVoucher = selectedVoucher != null
                    ? (totalAfterPoint -
                            selectedVoucher!.calculateDiscount(totalAfterPoint))
                        .clamp(0, totalAfterPoint)
                        .toDouble()
                    : totalAfterPoint;
                return Column(children: [
                  // Delivery image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: widget.packagePhotos.isNotEmpty
                          ? Image.file(
                              File(widget.packagePhotos.first),
                              height: 256.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/img/my_vehicle_1.png',
                              height: 256.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  const Divider(
                    thickness: 1,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16.h),

                  // Delivery brand information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          AppLocalizations.of(context)
                              .translate("Delivery Brand"),
                          style: TextStyle(
                              fontSize: 16.sp, color: AppColors.black)),
                      Text(widget.selectedBrand?.name ?? 'Delivery Service',
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
                              .translate("Delivery Vehicle:"),
                          style: TextStyle(
                              fontSize: 16.sp, color: AppColors.black)),
                      Text(widget.selectedVehicle,
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                  if (widget.selectedBrand != null) ...[
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context).translate("Rating:"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
                        Row(
                          children: [
                            Text(
                              widget.selectedBrand!.averageRating
                                  .toStringAsFixed(1),
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          ],
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 16.h),
                  const Divider(
                    thickness: 1,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16.h),

                  // Pickup information
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate("Pickup Address:"),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.black,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(widget.senderName,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black)),
                                      Text(widget.senderPhone,
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.grey)),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    widget.pickupLocation,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.black,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Delivery information
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate("Delivery Address:"),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.black,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(widget.recipientName,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black)),
                                      Text(widget.recipientPhone,
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.grey)),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    widget.deliveryLocation,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.black,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(
                    thickness: 1,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16.h),

                  // Requirements
                  if (widget.requirements.isNotEmpty) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate("Requirements:"),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.requirements,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    const Divider(
                      thickness: 1,
                      color: AppColors.grey,
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Total
                  if (travelPointOptions.isNotEmpty) ...[
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
                              border: Border.all(color: Colors.orange.shade200),
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
                              color: AppColors.primaryColor.withOpacity(0.1),
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
                                        'Tiết kiệm: ${currencyFormat.format(selectedVoucher!.calculateDiscount(totalAfterPoint))} ₫',
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
                  // Chi tiết giảm giá
                  if (selectedVoucher != null || travelPointToUse > 0) ...[
                    SizedBox(height: 12.h),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 8.h),
                    // Voucher giảm giá
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
                            '-${currencyFormat.format(selectedVoucher!.calculateDiscount(total.toDouble()))} ₫',
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
                            '${currencyFormat.format(totalAfterPoint)} ₫',
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
                    // Điểm thưởng
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
                    // Tổng cuối cùng
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
                  SizedBox(height: 24.h),

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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  SizedBox(height: 16.h),
                  // Hàng 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  SizedBox(height: 32.h),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedBank == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)
                                .translate('Please select a payment method')),
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
                          orderId:
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          orderLabel: 'Đơn giao hàng',
                          merchantNameLabel: 'HLGD',
                          fee: 0,
                          description: 'Thanh toán đơn giao hàng',
                          username:
                              FirebaseAuth.instance.currentUser?.uid ?? '',
                          partner: 'merchant',
                          extra:
                              '{"deliveryBrandId":"${widget.selectedBrand?.cooperationId ?? ""}","vehicleType":"${widget.selectedVehicle}"}',
                          isTestMode: true,
                          onSuccess: (response) async {
                            final userId =
                                FirebaseAuth.instance.currentUser?.uid;
                            if (userId != null && travelPointToUse > 0) {
                              await FirebaseFirestore.instance
                                  .collection('USER')
                                  .doc(userId)
                                  .update({
                                'travelPoint':
                                    FieldValue.increment(-travelPointToUse),
                              });
                            }
                            final reward =
                                totalAfterVoucher > 500000 ? 2000 : 1000;
                            if (userId != null) {
                              await FirebaseFirestore.instance
                                  .collection('USER')
                                  .doc(userId)
                                  .update({
                                'travelPoint': FieldValue.increment(reward),
                              });
                            }
                            await _processPayment();
                          },
                          onError: (response) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLocalizations.of(context)
                                          .translate('MoMo payment failed:') +
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: Text(
                        AppLocalizations.of(context)
                            .translate("Confirm Payment"),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
