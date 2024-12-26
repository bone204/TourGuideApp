import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/restaurant_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class RestaurantListScreen extends StatelessWidget {
  // Dữ liệu mẫu
  final List<RestaurantCardData> restaurants = [
    RestaurantCardData(
      imageUrl: 'https://qul.imgix.net/ca169046-430e-4b8d-b218-3f0f73c446be/625936_sld.jpg',
      restaurantName: 'Nhà hàng Biển Đông',
      rating: 4.5,
      pricePerPerson: 250000,
      address: '208 Trần Phú, Lộc Thọ, Thành phố Nha Trang, Khánh Hòa',
    ),
    RestaurantCardData(
      imageUrl: 'https://qul.imgix.net/ca169046-430e-4b8d-b218-3f0f73c446be/625936_sld.jpg',
      restaurantName: 'Quán Ngon Sài Gòn',
      rating: 4.0,
      pricePerPerson: 150000,
      address: '208 Trần Phú, Lộc Thọ, Thành phố Nha Trang, Khánh Hòa',
    ),
    RestaurantCardData(
      imageUrl: 'https://qul.imgix.net/ca169046-430e-4b8d-b218-3f0f73c446be/625936_sld.jpg',
      restaurantName: 'Nhà hàng Phố Cổ',
      rating: 5.0,
      pricePerPerson: 350000,
      address: '208 Trần Phú, Lộc Thọ, Thành phố Nha Trang, Khánh Hòa',
    ),
    RestaurantCardData(
      imageUrl: 'https://qul.imgix.net/ca169046-430e-4b8d-b218-3f0f73c446be/625936_sld.jpg',
      restaurantName: 'Quán Ẩm Thực Huế',
      rating: 4.8,
      pricePerPerson: 280000,
      address: '208 Trần Phú, Lộc Thọ, Thành phố Nha Trang, Khánh Hòa',
    ),
  ];

  RestaurantListScreen({super.key});

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
                        AppLocalizations.of(context).translate('Restaurant List'),
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
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return RestaurantCard(data: restaurants[index]);
          },
        ),
      ),
    );
  }
} 