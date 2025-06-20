import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/hotel_card.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
//import 'package:tourguideapp/views/service/hotel/hotel_detail_screen.dart';

class HotelListScreen extends StatelessWidget {
  // Dữ liệu mẫu
  final List<CooperationModel> hotels = [
    CooperationModel(
      cooperationId: '1',
      name: 'Rex Hotel Saigon',
      type: 'hotel',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '141 Nguyễn Huệ, Bến Nghé, Quận 1, TP.HCM',
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
      name: 'Caravelle Saigon',
      type: 'hotel',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '19 Lam Sơn, Bến Nghé, Quận 1, TP.HCM',
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
      name: 'InterContinental Saigon',
      type: 'hotel',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: 'Corner of Hai Ba Trung St. & Le Duan Blvd, District 1, TP.HCM',
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
      name: 'Sheraton Saigon Hotel',
      type: 'hotel',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '88 Đồng Khởi, Bến Nghé, Quận 1, TP.HCM',
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
    CooperationModel(
      cooperationId: '5',
      name: 'Sofitel Saigon Plaza',
      type: 'hotel',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '17 Lê Duẩn, Bến Nghé, Quận 1, TP.HCM',
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
      averageRating: 4.2,
    ),
    CooperationModel(
      cooperationId: '6',
      name: 'Grand Hotel Saigon',
      type: 'hotel',
      numberOfObjects: 0,
      numberOfObjectTypes: 0,
      latitude: 0,
      longitude: 0,
      bossName: '',
      bossPhone: '',
      bossEmail: '',
      address: '8 Đồng Khởi, Bến Nghé, Quận 1, TP.HCM',
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
      averageRating: 4.6,
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
            // Giả lập giá phòng rẻ nhất cho từng khách sạn
            int? minRoomPrice;
            switch (index) {
              case 0:
                minRoomPrice = 1200000;
                break;
              case 1:
                minRoomPrice = 900000;
                break;
              case 2:
                minRoomPrice = 1500000;
                break;
              case 3:
                minRoomPrice = 2000000;
                break;
              case 4:
                minRoomPrice = 1100000;
                break;
              case 5:
                minRoomPrice = 1000000;
                break;
              default:
                minRoomPrice = null;
            }
            return HotelCard(hotel: hotels[index], minRoomPrice: minRoomPrice);
          },
        ),
      ),
    );
  }
}
