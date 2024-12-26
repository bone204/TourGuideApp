import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';


class DeliveryBill extends StatefulWidget {
  const DeliveryBill({super.key});

  @override
  State<DeliveryBill> createState() => _DeliveryBillScreenState();
}

class _DeliveryBillScreenState extends State<DeliveryBill> {
  String? selectedBank;
  
  final List<Map<String, String>> bankOptions = [
    {'id': 'visa', 'image': 'assets/img/Logo_Visa.png'},
    {'id': 'mastercard', 'image': 'assets/img/Logo_Mastercard.png'},
    {'id': 'paypal', 'image': 'assets/img/Logo_PayPal.png'},
    {'id': 'momo', 'image': 'assets/img/Logo_Momo.png'},
    {'id': 'zalopay', 'image': 'assets/img/Logo_Zalopay.png'},
    {'id': 'shopee', 'image': 'assets/img/Logo_Shopee.png'},
  ];

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
                        AppLocalizations.of(context).translate('Delivery Information'),
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
            padding: EdgeInsets.only(bottom: 20.h, right: 20.w, left: 20.w),
            child: Column(children: [
              Image.network(
                "https://dq5r178u4t83b.cloudfront.net/wp-content/uploads/sites/125/2021/08/11060441/deluxe_harbour_web.jpg",
                height: 256.h,
                fit: BoxFit.contain,
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
                  Text('Trần Trung Thông',
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
                  Text('0914259475',
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
                  Text("Recipient:",
                      style:
                          TextStyle(fontSize: 16.sp, color: AppColors.black)),
                  Text('Nguyễn Hữu Trường',
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
                  Text('0914259475',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pick-up Location:",
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
                          'Bcons Sala, Phan Boi Chau Street, Di An City, Binh Duong Province',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Delivery Adress:",
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
                          '75/57/13 Nguyen Luong Bang Street, Hoa Thang Commune, Buon Ma Thuot City, Dak Lak Province',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
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
                        "Fragile - Please Handle with Care",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
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
                      Text("Delivery Vehicle:",
                          style:
                              TextStyle(fontSize: 16.sp, color: AppColors.black)),
                      Text("Motorbike",
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
                      Text("Delivery Brand:",
                          style:
                              TextStyle(fontSize: 16.sp, color: AppColors.black)),
                      Text("J&T Express",
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
                      Text("Price:",
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.bold)),
                      Text(
                          '650,000 ₫',
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
                      onPressed: () {},
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
                              )),
                      ),
                  ],
                ),
              ],
              ),
            ),
          ),
      ),
    );
  }
}