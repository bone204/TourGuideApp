import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class VehicleRentalBill extends StatefulWidget {
  final String billId;
  final String model;
  final String vehicleId;
  final String vehicleRegisterId;
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
    required this.vehicleRegisterId,
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
          print('Fetching vehicle info for ID: ${widget.vehicleRegisterId}');
        }

        final vehicleDoc = await FirebaseFirestore.instance
            .collection('RENTAL_VEHICLE')
            .doc(widget.vehicleRegisterId)
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
              child: Column(children: [
                Row(
                  children: [
                    Consumer<RentalVehicleViewModel>(
                      builder: (context, viewModel, child) {
                        return FutureBuilder<String>(
                          future: viewModel.getVehiclePhoto(widget.vehicleId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final imagePath =
                                snapshot.data ?? 'assets/img/car_default.png';
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
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
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text("Customer:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
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
                    Text("Phone Number:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
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
                    Text("Owner:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
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
                    Text("Phone Number:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
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
                    Text("Selected:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
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
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
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
                    Text("Price:",
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total:",
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
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
