import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/restaurant_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
//import 'package:tourguideapp/views/service/restaurant/restaurant_detail_screen.dart';

class RestaurantListScreen extends StatelessWidget {
  // Dữ liệu mẫu
  final List<CooperationModel> restaurants = [
    CooperationModel(
      cooperationId: '1',
      name: 'Nhà Hàng Ngon',
      type: 'restaurant',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '160 Pasteur, Bến Nghé, Quận 1, TP.HCM',
      district: '',
      city: '',
      province: '',
      photo:
          'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      extension: '',
      introduction: '',
      contractDate: '',
      contractTerm: '',
      bankAccountNumber: '',
      bankAccountName: '',
      bankName: '',
      bookingTimes: 0,
      revenue: 0,
      averageRating: 4.5,
    ),
    CooperationModel(
      cooperationId: '2',
      name: 'Quán Ăn Ngon Sài Gòn',
      type: 'restaurant',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '138 Nam Kỳ Khởi Nghĩa, Bến Thành, Quận 1, TP.HCM',
      district: '',
      city: '',
      province: '',
      photo:
          'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      extension: '',
      introduction: '',
      contractDate: '',
      contractTerm: '',
      bankAccountNumber: '',
      bankAccountName: '',
      bankName: '',
      bookingTimes: 0,
      revenue: 0,
      averageRating: 4.0,
    ),
    CooperationModel(
      cooperationId: '3',
      name: 'Nhà Hàng Phố Cổ',
      type: 'restaurant',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '76 Lê Lợi, Bến Nghé, Quận 1, TP.HCM',
      district: '',
      city: '',
      province: '',
      photo:
          'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      extension: '',
      introduction: '',
      contractDate: '',
      contractTerm: '',
      bankAccountNumber: '',
      bankAccountName: '',
      bankName: '',
      bookingTimes: 0,
      revenue: 0,
      averageRating: 5.0,
    ),
    CooperationModel(
      cooperationId: '4',
      name: 'Quán Ẩm Thực Huế',
      type: 'restaurant',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '45 Nguyễn Du, Bến Nghé, Quận 1, TP.HCM',
      district: '',
      city: '',
      province: '',
      photo:
          'https://images.foody.vn/res/g103/1025073/prof/s576x330/foody-upload-api-foody-mobile-hinh-anh-nha-hang-190425151748.jpg',
      extension: '',
      introduction: '',
      contractDate: '',
      contractTerm: '',
      bankAccountNumber: '',
      bankAccountName: '',
      bankName: '',
      bookingTimes: 0,
      revenue: 0,
      averageRating: 4.8,
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
                        AppLocalizations.of(context)
                            .translate('Restaurant List'),
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
            // Giả lập giá bàn rẻ nhất cho từng nhà hàng
            int? minTablePrice;
            switch (index) {
              case 0:
                minTablePrice = 250000;
                break;
              case 1:
                minTablePrice = 150000;
                break;
              case 2:
                minTablePrice = 350000;
                break;
              case 3:
                minTablePrice = 280000;
                break;
              default:
                minTablePrice = null;
            }
            return RestaurantCard(
                restaurant: restaurants[index], minTablePrice: minTablePrice);
          },
        ),
      ),
    );
  }
}
