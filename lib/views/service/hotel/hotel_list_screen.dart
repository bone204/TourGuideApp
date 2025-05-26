import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/hotel_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class HotelListScreen extends StatelessWidget {
  // Dữ liệu mẫu
  final List<HotelCardData> hotels = [
    HotelCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      hotelName: 'Rex Hotel Saigon',
      rating: 4.5,
      pricePerDay: 2500000,
      address: '141 Nguyễn Huệ, Bến Nghé, Quận 1, TP.HCM',
    ),
    HotelCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      hotelName: 'Caravelle Saigon',
      rating: 4.0,
      pricePerDay: 1500000,
      address: '19 Lam Sơn, Bến Nghé, Quận 1, TP.HCM',
    ),
    HotelCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      hotelName: 'InterContinental Saigon',
      rating: 5.0,
      pricePerDay: 3500000,
      address: 'Corner of Hai Ba Trung St. & Le Duan Blvd, District 1, TP.HCM',
    ),
    HotelCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      hotelName: 'Sheraton Saigon Hotel',
      rating: 4.8,
      pricePerDay: 2800000,
      address: '88 Đồng Khởi, Bến Nghé, Quận 1, TP.HCM',
    ),
    HotelCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      hotelName: 'Sofitel Saigon Plaza',
      rating: 4.2,
      pricePerDay: 1800000,
      address: '17 Lê Duẩn, Bến Nghé, Quận 1, TP.HCM',
    ),
    HotelCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      hotelName: 'Grand Hotel Saigon',
      rating: 4.6,
      pricePerDay: 2200000,
      address: '8 Đồng Khởi, Bến Nghé, Quận 1, TP.HCM',
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