import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/viewmodels/profile_viewmodel.dart';
import 'package:tourguideapp/core/services/momo_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class VehicleRentalBill extends StatefulWidget {
  final String billId;
  final String model;
  final String vehicleId;
  final List<String> licensePlates;
  final DateTime startDate;
  final DateTime endDate;
  final String rentOption;
  final double price;
  final String pickupLocation;

  const VehicleRentalBill({
    Key? key,
    required this.billId,
    required this.model,
    required this.vehicleId,
    required this.licensePlates,
    required this.startDate,
    required this.endDate,
    required this.rentOption,
    required this.price,
    required this.pickupLocation,
  }) : super(key: key);

  @override
  State<VehicleRentalBill> createState() => _VehicleRentalBillState();
}

class _VehicleRentalBillState extends State<VehicleRentalBill> {
  String? selectedBank;
  String? customerName;
  String? customerPhone;
  String? ownerName;
  String? ownerPhone;
  double totalAmount = 0;
  late Timer _timer;
  final ValueNotifier<int> _timeNotifier = ValueNotifier<int>(600);
  int travelPointToUse = 0;

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
    _loadUserDetails();
    _calculateTotal();
    _startTimer();
  }

  Future<void> _loadUserDetails() async {
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      if (currentUser != null) {
        if (kDebugMode) {
          print('Current user UID: ${currentUser.uid}');
        }

        final userDoc = await FirebaseFirestore.instance
            .collection('USER')
            .where('uid', isEqualTo: currentUser.uid)
            .get();

        if (userDoc.docs.isNotEmpty) {
          if (kDebugMode) {
            print(
                'Customer info found - Name: ${userDoc.docs.first['fullName']}, Phone: ${userDoc.docs.first['phoneNumber']}');
          }
          setState(() {
            customerName = userDoc.docs.first['fullName'];
            customerPhone = userDoc.docs.first['phoneNumber'];
          });
        }

        if (kDebugMode) {
          print('Fetching vehicle info for ID: ${widget.licensePlates}');
        }

        final vehicleDoc = await FirebaseFirestore.instance
            .collection('RENTAL_VEHICLE')
            .doc(widget.licensePlates[0])
            .get();

        if (vehicleDoc.exists) {
          final contractId = vehicleDoc.data()?['contractId'];
          if (kDebugMode) {
            print('Found contract ID: $contractId');
          }

          if (contractId != null) {
            final contractDoc = await FirebaseFirestore.instance
                .collection('CONTRACT')
                .doc(contractId)
                .get();

            if (contractDoc.exists) {
              final ownerId = contractDoc.data()?['userId'];
              if (kDebugMode) {
                print('Found owner ID from contract: $ownerId');
              }

              if (ownerId != null) {
                final ownerDoc = await FirebaseFirestore.instance
                    .collection('USER')
                    .where('userId', isEqualTo: ownerId)
                    .get();

                if (ownerDoc.docs.isNotEmpty) {
                  if (kDebugMode) {
                    print(
                        'Owner info found - Name: ${ownerDoc.docs.first['fullName']}, Phone: ${ownerDoc.docs.first['phoneNumber']}');
                  }
                  setState(() {
                    ownerName = ownerDoc.docs.first['fullName'];
                    ownerPhone = ownerDoc.docs.first['phoneNumber'];
                  });
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi tải thông tin người dùng: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi tải thông tin người dùng')),
      );
    }
  }

  void _calculateTotal() {
    final duration = widget.endDate.difference(widget.startDate);

    if (widget.rentOption == 'Hourly') {
      totalAmount = widget.price;
    } else {
      // Cộng thêm 1 vì tính cả ngày bắt đầu
      totalAmount = widget.price * duration.inDays;
    }
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeNotifier.value > 0) {
        _timeNotifier.value--;
      } else {
        _timer.cancel();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  Widget _buildTimeRemaining() {
    return ValueListenableBuilder<int>(
      valueListenable: _timeNotifier,
      builder: (context, timeLeft, child) {
        int minutes = timeLeft ~/ 60;
        int seconds = timeLeft % 60;
        return Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 16.sp,
            color: timeLeft < 60 ? Colors.red : Colors.black,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                    AppLocalizations.of(context).translate('Confirm Exit')),
                content: Text(AppLocalizations.of(context).translate(
                    'Are you sure you want to cancel this payment?')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context).translate('No')),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(AppLocalizations.of(context).translate('Yes')),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: CustomIconButton(
              icon: Icons.arrow_back,
              onPressed: () async {
                final shouldPop = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                        AppLocalizations.of(context).translate('Confirm Exit')),
                    content: Text(AppLocalizations.of(context).translate(
                        'Are you sure you want to cancel this payment?')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child:
                            Text(AppLocalizations.of(context).translate('No')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child:
                            Text(AppLocalizations.of(context).translate('Yes')),
                      ),
                    ],
                  ),
                );
                if (shouldPop ?? false) {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).translate('Payment'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _buildTimeRemaining(),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: AppColors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: Consumer<ProfileViewModel>(
                builder: (context, profile, child) {
                  final travelPoint = profile.travelPoint;
                  final List<int> travelPointOptions = [];
                  for (int i = 1000; i <= travelPoint; i += 1000) {
                    travelPointOptions.add(i);
                  }
                  final totalAfterPoint = (totalAmount - travelPointToUse)
                      .clamp(0, totalAmount)
                      .toDouble();

                  return Column(children: [
                    Row(
                      children: [
                        Consumer<RentalVehicleViewModel>(
                          builder: (context, viewModel, child) {
                            return FutureBuilder<String>(
                              future:
                                  viewModel.getVehiclePhoto(widget.vehicleId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final imagePath =
                                    snapshot.data ?? 'assets/img/icon-cx3.png';
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: SizedBox(
                                    width: 184.w,
                                    height: 144.h,
                                    child: imagePath.startsWith('assets/')
                                        ? Image.asset(
                                            imagePath,
                                            width: 184.w,
                                            height: 144.h,
                                            fit: BoxFit.contain,
                                          )
                                        : Image.network(
                                            imagePath,
                                            width: 184.w,
                                            height: 144.h,
                                            fit: BoxFit.contain,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/img/car_default.png',
                                                width: 184.w,
                                                height: 144.h,
                                                fit: BoxFit.contain,
                                              );
                                            },
                                          ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Consumer<RentalVehicleViewModel>(
                            builder: (context, viewModel, child) {
                              return FutureBuilder<Map<String, dynamic>>(
                                future: viewModel
                                    .getVehicleDetailsById(widget.vehicleId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final vehicleDetails = snapshot.data ?? {};
                                  final model =
                                      vehicleDetails['model'] ?? widget.model;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model,
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "${AppLocalizations.of(context).formatPrice(widget.price)} ₫",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.orange,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Text(
                                            "${AppLocalizations.of(context).translate("Rate")}:",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          ...List.generate(
                                              5,
                                              (index) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 14.sp,
                                                  )),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    const Divider(
                      thickness: 1,
                      color: AppColors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.of(context).translate("Customer:"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
                        Text(customerName ?? 'Loading...',
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
                                .translate("Phone Number:"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
                        Text(customerPhone ?? 'Loading...',
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
                        Text(AppLocalizations.of(context).translate("Owner:"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
                        Text(ownerName ?? 'Loading...',
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
                                .translate("Phone Number:"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
                        Text(ownerPhone ?? 'Loading...',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.of(context).translate("Selected:"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
                        Text("1",
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
                        Text(widget.rentOption == 'Hourly' ? "Hours:" : "Days:",
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
                        Text(
                            widget.rentOption == 'Hourly'
                                ? "${widget.endDate.difference(widget.startDate).inHours}"
                                : "${widget.endDate.difference(widget.startDate).inDays + 1}",
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
                        Text(AppLocalizations.of(context).translate("Price:"),
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.black)),
                        Text(
                            "${AppLocalizations.of(context).formatPrice(widget.price)} ₫",
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
                    // Sử dụng điểm thưởng
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
                              'Điểm hiện có: ${NumberFormat('#,###', 'vi_VN').format(travelPoint)} điểm',
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
                                              '${NumberFormat('#,###', 'vi_VN').format(points)} điểm (-${NumberFormat('#,###', 'vi_VN').format(points)} ₫)',
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
                                      'Tiết kiệm: ${NumberFormat('#,###', 'vi_VN').format(travelPointToUse)} ₫',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context).translate("Total:"),
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.black,
                                fontWeight: FontWeight.w700)),
                        Text(
                            "${AppLocalizations.of(context).formatPrice(totalAmount)} ₫",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.black,
                                fontWeight: FontWeight.w700))
                      ],
                    ),
                    // Chi tiết giảm giá
                    if (travelPointToUse > 0) ...[
                      SizedBox(height: 12.h),
                      Divider(height: 1, color: Colors.grey.shade300),
                      SizedBox(height: 8.h),
                      // Điểm thưởng
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
                            '-${NumberFormat('#,###', 'vi_VN').format(travelPointToUse)} ₫',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
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
                            '${NumberFormat('#,###', 'vi_VN').format(totalAfterPoint)} ₫',
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
                            amount: totalAfterPoint.toInt(),
                            orderId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            orderLabel: 'Thuê xe',
                            merchantNameLabel: 'HLGD',
                            fee: 0,
                            description: 'Thanh toán thuê xe',
                            username:
                                FirebaseAuth.instance.currentUser?.uid ?? '',
                            partner: 'merchant',
                            extra:
                                '{"vehicleId":"${widget.vehicleId}","licensePlates":"${widget.licensePlates.join(",")}"}',
                            isTestMode: true,
                            onSuccess: (response) async {
                              // Trừ điểm thưởng
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
                              // Cộng điểm thưởng
                              final reward =
                                  totalAfterPoint > 500000 ? 2000 : 1000;
                              if (userId != null) {
                                await FirebaseFirestore.instance
                                    .collection('USER')
                                    .doc(userId)
                                    .update({
                                  'travelPoint': FieldValue.increment(reward),
                                });
                              }
                              try {
                                await context
                                    .read<RentalVehicleViewModel>()
                                    .confirmPayment(
                                      widget.billId,
                                      selectedBank ?? '',
                                      'account_payment_info',
                                    );

                                if (mounted) {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Thanh toán thành công'),
                                      backgroundColor: Colors.green,
                                    ),
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
                            },
                            onError: (response) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                              .translate(
                                                  'MoMo payment failed:') +
                                          ' ${response.message}'),
                                      backgroundColor: Colors.red),
                                );
                              }
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
                        minimumSize: Size(343.w, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
