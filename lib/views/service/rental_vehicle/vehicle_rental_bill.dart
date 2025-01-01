import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/models/bill_model.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:flutter/foundation.dart';

class VehicleRentalBill extends StatefulWidget {
  final String model;
  final String vehicleId;
  final String vehicleRegisterId;
  final DateTime startDate;
  final DateTime endDate;
  final String rentOption;
  final double price;
  final String pickupLocation;

  const VehicleRentalBill({
    super.key,
    required this.model,
    required this.vehicleId,
    required this.vehicleRegisterId,
    required this.startDate,
    required this.endDate,
    required this.rentOption,
    required this.price,
    required this.pickupLocation,
  });

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

  Future<void> _createBill() async {
    if (selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('Please select a payment method'))));
      return;
    }

    try {
      final billId = await _generateBillId();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('USER')
          .where('uid', isEqualTo: currentUser.uid)
          .get();

      if (userDoc.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userId = userDoc.docs.first['userId'];

      final bill = BillModel(
        billId: billId,
        userId: userId,
        startDate: widget.startDate.toIso8601String(),
        endDate: widget.endDate.toIso8601String(),
        rentalType: widget.rentOption,
        total: totalAmount,
        voucherId: '', // Có thể thêm tính năng voucher sau
        travelPointsUsed: 0, // Có thể thêm tính năng điểm sau
        paymentMethod: selectedBank!,
        accountPayment: '', // Có thể thêm số tài khoản sau
        vehicleRegisterId: widget.vehicleRegisterId,
      );

      await FirebaseFirestore.instance
          .collection('BILL')
          .doc(billId)
          .set(bill.toMap());

      // Cập nhật trạng thái xe thành "Đang cho thuê"
      await Provider.of<RentalVehicleViewModel>(context, listen: false)
          .updateVehicleStatus(widget.vehicleRegisterId, 'Đang cho thuê');

      // Hiển thị thông báo thành công và quay về trang chủ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('Booking successful'))));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<String> _generateBillId() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('BILL').get();
    final currentCounter = querySnapshot.size + 1;
    return 'BILL${currentCounter.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
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
                              .translate('Rental Information'),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "${AppLocalizations.of(context).formatPrice(widget.price)} ₫",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.orange,
                                        fontWeight: FontWeight.bold),
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
                            fontWeight: FontWeight.bold))
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
                            fontWeight: FontWeight.bold))
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
                            fontWeight: FontWeight.bold))
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
                            fontWeight: FontWeight.bold))
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
                            fontWeight: FontWeight.bold))
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
                            fontWeight: FontWeight.bold))
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
                            fontWeight: FontWeight.bold))
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
                            fontWeight: FontWeight.bold)),
                    Text(
                        "${AppLocalizations.of(context).formatPrice(totalAmount)} ₫",
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold))
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
                    onPressed: () {
                      _createBill();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child:
                        Text(AppLocalizations.of(context).translate("Confirm"),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ))),
              ]),
            ),
          ),
        ));
  }
}
