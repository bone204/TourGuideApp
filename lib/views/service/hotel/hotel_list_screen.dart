import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/hotel_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class HotelListScreen extends StatelessWidget {
  // Dữ liệu mẫu
  final List<HotelCardData> hotels = [
    HotelCardData(
      imageUrl: 'https://cdn3.ivivu.com/2022/08/Capella-Hanoi-ivivu.jpg',
      hotelName: 'Vinpearl Resort',
      rating: 4.5,
      pricePerDay: 2500000,
    ),
    HotelCardData(
      imageUrl: 'https://cdn3.ivivu.com/2022/08/Capella-Hanoi-ivivu.jpg',
      hotelName: 'Mường Thanh Hotel',
      rating: 4.0,
      pricePerDay: 1500000,
    ),
    HotelCardData(
      imageUrl: 'https://cdn3.ivivu.com/2022/08/Capella-Hanoi-ivivu.jpg',
      hotelName: 'InterContinental',
      rating: 5.0,
      pricePerDay: 3500000,
    ),
    HotelCardData(
      imageUrl: 'https://cdn3.ivivu.com/2022/08/Capella-Hanoi-ivivu.jpg',
      hotelName: 'Sheraton Hotel',
      rating: 4.8,
      pricePerDay: 2800000,
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