import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/hotel_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class HotelListScreen extends StatelessWidget {
  // Dữ liệu mẫu
  final List<HotelCardData> hotels = [
    HotelCardData(
      imageUrl: 'https://khachsandep.com.vn/storage/files/dothanhnga/anh1.jpg',
      hotelName: 'Vinpearl Resort & Spa',
      rating: 4.5,
      pricePerDay: 2500000,
      address: '208 Trần Phú, Lộc Thọ, Thành phố Nha Trang, Khánh Hòa',
    ),
    HotelCardData(
      imageUrl: 'https://khachsandep.com.vn/storage/files/dothanhnga/anh1.jpg',
      hotelName: 'Mường Thanh Luxury',
      rating: 4.0,
      pricePerDay: 1500000,
      address: '60 Trần Phú, Vĩnh Nguyên, Thành phố Nha Trang, Khánh Hòa',
    ),
    HotelCardData(
      imageUrl: 'https://khachsandep.com.vn/storage/files/dothanhnga/anh1.jpg',
      hotelName: 'InterContinental',
      rating: 5.0,
      pricePerDay: 3500000,
      address: '32-34 Trần Phú, Vĩnh Nguyên, Thành phố Nha Trang, Khánh Hòa',
    ),
    HotelCardData(
      imageUrl: 'https://khachsandep.com.vn/storage/files/dothanhnga/anh1.jpg',
      hotelName: 'Sheraton Hotel & Spa',
      rating: 4.8,
      pricePerDay: 2800000,
      address: '26-28 Trần Phú, Xương Huân, Thành phố Nha Trang, Khánh Hòa',
    ),
    HotelCardData(
      imageUrl: 'https://khachsandep.com.vn/storage/files/dothanhnga/anh1.jpg',
      hotelName: 'Novotel Nha Trang',
      rating: 4.2,
      pricePerDay: 1800000,
      address: '50 Trần Phú, Lộc Thọ, Thành phố Nha Trang, Khánh Hòa',
    ),
    HotelCardData(
      imageUrl: 'https://khachsandep.com.vn/storage/files/dothanhnga/anh1.jpg',
      hotelName: 'Diamond Bay Resort',
      rating: 4.6,
      pricePerDay: 2200000,
      address: 'Phước Hạ, Phước Đồng, Thành phố Nha Trang, Khánh Hòa',
    ),
  ];

  HotelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        AppLocalizations.of(context).translate('Hotel List'),
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 161.w / 190.h,
            mainAxisSpacing: 20.h,
            crossAxisSpacing: 0,
          ),
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            return HotelCard(data: hotels[index]);
          },
        ),
      ),
    );
  }
} 