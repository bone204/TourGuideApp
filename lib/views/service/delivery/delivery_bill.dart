import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
//import 'package:tourguideapp/services/momo_payment_service.dart';
//import 'package:uuid/uuid.dart';

class DeliveryBill extends StatefulWidget {
  final CooperationModel? selectedBrand;
  final String selectedVehicle;
  final String pickupLocation;
  final String deliveryLocation;
  final String recipientName;
  final String recipientPhone;
  final String requirements;

  const DeliveryBill({
    super.key,
    this.selectedBrand,
    this.selectedVehicle = 'Motorbike',
    this.pickupLocation = '8 DT743 Street, Di An City, Binh Duong Province',
    this.deliveryLocation =
        '875 Cach Mang Thang 8 Street, District 1, Ho Chi Minh City',
    this.recipientName = 'Nguyễn Hữu Trường',
    this.recipientPhone = '00914259475',
    this.requirements = 'Fragile - Please Handle with Care',
  });

  @override
  State<DeliveryBill> createState() => _DeliveryBillState();
}

class _DeliveryBillState extends State<DeliveryBill> {
  String selectedBank = 'momo';
  //final _momoService = MomoPaymentService();
  //final _uuid = Uuid();

  final List<Map<String, String>> bankOptions = [
    {'id': 'momo', 'image': 'assets/img/ic_momo.png'},
    {'id': 'vnpay', 'image': 'assets/img/ic_vnpay.png'},
    {'id': 'zalo', 'image': 'assets/img/ic_zalo.png'},
    {'id': 'airpay', 'image': 'assets/img/ic_airpay.png'},
    {'id': 'shopee', 'image': 'assets/img/ic_shopee.png'},
    {'id': 'bank', 'image': 'assets/img/ic_bank.png'},
  ];

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
            padding: EdgeInsets.only(bottom: 20.h, right: 20.w, left: 20.w),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  'assets/img/bg_delivery.png',
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedBrand?.name ?? 'Delivery Service',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  if (widget.selectedBrand != null)
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.selectedBrand!.averageRating.floor()
                              ? Icons.star
                              : (index < widget.selectedBrand!.averageRating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 16.sp,
                        );
                      }),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              if (widget.selectedBrand != null)
                Text(
                  widget.selectedBrand!.address,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              SizedBox(height: 16.h),
              const Divider(thickness: 1, color: AppColors.grey),
              SizedBox(height: 16.h),
              Text(
                "Pickup Address:",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.black,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.recipientName,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black)),
                            Text(widget.recipientPhone,
                                style: TextStyle(
                                    fontSize: 12.sp, color: AppColors.grey)),
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
              SizedBox(height: 16.h),
              Text(
                "Delivery Address:",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.black,
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
                    child: Text(
                      widget.deliveryLocation,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                      ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Requirements:",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).translate("Delivery Vehicle:"),
                      style:
                          TextStyle(fontSize: 16.sp, color: AppColors.black)),
                  Text(widget.selectedVehicle,
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
                  Text(AppLocalizations.of(context).translate("Delivery Brand:"),
                      style:
                          TextStyle(fontSize: 16.sp, color: AppColors.black)),
                  Text(widget.selectedBrand?.name ?? 'N/A',
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.w700))
                ],
              ),
              if (widget.selectedBrand != null) ...[
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate("Rating:"),
                        style:
                            TextStyle(fontSize: 16.sp, color: AppColors.black)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).translate("Price:"),
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.w700)),
                  Text('650,000 ₫',
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
                          bankImageUrl: bank['image'] ?? '',
                          isSelected: selectedBank == bank['id'],
                          onTap: () {
                            setState(() {
                              selectedBank = bank['id'] ?? '';
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
                          bankImageUrl: bank['image'] ?? '',
                          isSelected: selectedBank == bank['id'],
                          onTap: () {
                            setState(() {
                              selectedBank = bank['id'] ?? '';
                            });
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  // if (selectedBank == 'momo') {
                  //   _handleMomoPayment();
                  // }
                },
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
      ),
    );
  }
}
