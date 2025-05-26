import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/restaurant_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';

class RestaurantListScreen extends StatelessWidget {
  // Dữ liệu mẫu
  final List<RestaurantCardData> restaurants = [
    RestaurantCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      restaurantName: 'Nhà Hàng Ngon',
      rating: 4.5,
      pricePerPerson: 250000,
      address: '160 Pasteur, Bến Nghé, Quận 1, TP.HCM',
    ),
    RestaurantCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      restaurantName: 'Quán Ăn Ngon Sài Gòn',
      rating: 4.0,
      pricePerPerson: 150000,
      address: '138 Nam Kỳ Khởi Nghĩa, Bến Thành, Quận 1, TP.HCM',
    ),
    RestaurantCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      restaurantName: 'Nhà Hàng Phố Cổ',
      rating: 5.0,
      pricePerPerson: 350000,
      address: '76 Lê Lợi, Bến Nghé, Quận 1, TP.HCM',
    ),
    RestaurantCardData(
      imageUrl: 'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      restaurantName: 'Quán Ẩm Thực Huế',
      rating: 4.8,
      pricePerPerson: 280000,
      address: '45 Nguyễn Du, Bến Nghé, Quận 1, TP.HCM',
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
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return RestaurantCard(data: restaurants[index]);
          },
        ),
      ),
    );
  }
} 