import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/widgets/bank_option_selector.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class VehicleRentalBill extends StatefulWidget {
  const VehicleRentalBill({super.key});

  @override
  State<VehicleRentalBill> createState() => _VehicleRentalBillState();
}

class _VehicleRentalBillState extends State<VehicleRentalBill> {
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
                        AppLocalizations.of(context).translate('Rental Information'),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/img/icon-cx3.png",
                      width: 184.w,
                      height: 144.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("S 500 Sedan", style: TextStyle(fontSize: 12.sp, color: AppColors.black, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text("650,000 ₫", style: TextStyle(fontSize: 12.sp, color: AppColors.orange, fontWeight: FontWeight.bold)),
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
                            ...List.generate(5, (index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14.sp,
                            )),
                          ],
                        ),
                      ],
                    )
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
                    Text("Customer:", style: TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text("Nguyễn Hữu Trường", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Phone Number:", style: TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text("0914259475", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Owner:", style: TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text("Trần Trung Thông", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Phone Number:", style: TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text("0914259475", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold))
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
                    Text("Selected:", style: TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text("1", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Days:", style: TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text("1", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Price:", style: TextStyle(fontSize: 16.sp, color: AppColors.black)),
                    Text("650,000 ₫", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold))
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
                    Text("Total:", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold)),
                    Text("650,000 ₫", style: TextStyle(fontSize: 16.sp, color: AppColors.black, fontWeight: FontWeight.bold))
                  ],
                ),
                SizedBox(height: 24.h),
                // Hàng 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: bankOptions.sublist(0, 3).map((bank) => 
                    BankOptionSelector(
                      bankImageUrl: bank['image']!,
                      isSelected: selectedBank == bank['id'],
                      onTap: () {
                        setState(() {
                          selectedBank = bank['id'];
                        });
                      },
                    )
                  ).toList(),
                ),
                SizedBox(height: 24.h),
                // Hàng 2
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: bankOptions.sublist(3, 6).map((bank) => 
                    BankOptionSelector(
                      bankImageUrl: bank['image']!,
                      isSelected: selectedBank == bank['id'],
                      onTap: () {
                        setState(() {
                          selectedBank = bank['id'];
                        });
                      },
                    )
                  ).toList(),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const VehicleRentalBill())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate("Confirm"),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    )
                  )
                ),
              ]
            ),
          ),
        ),
      )
    );
  }
} 