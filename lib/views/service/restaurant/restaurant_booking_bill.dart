import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';


class RestaurantBookingBillScreen extends StatefulWidget {
  const RestaurantBookingBillScreen({super.key});

  @override
  State<RestaurantBookingBillScreen> createState() => _RestaurantBookingBillScreenState();
}

class _RestaurantBookingBillScreenState extends State<RestaurantBookingBillScreen> {
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
                        AppLocalizations.of(context).translate('Booking Information'),
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
                "https://www.mydomaine.com/thmb/9vOxtjXGcq8Ajsu4G5yF7PXHepw=/2000x0/filters:no_upscale():strip_icc()/dining-room-table-decor-ideas-21-mindy-gayer-marigold-project-6a8c8379f8c94eb785747e3305803588.jpg",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Type:",
                      style:
                          TextStyle(fontSize: 16.sp, color: AppColors.black)),
                  Text("Small Table",
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
                  Text("Check-in Date:",
                      style:
                          TextStyle(fontSize: 16.sp, color: AppColors.black)),
                  Text("28/12/2024",
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
                  Text("Check-in Time:",
                      style:
                          TextStyle(fontSize: 16.sp, color: AppColors.black)),
                  Text("05:00 PM",
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold))
                ],
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
                          ))),
            ]),
          ),
        ),
      )
    );
  }
} 