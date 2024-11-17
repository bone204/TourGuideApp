import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/home_navigator.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';
import 'package:tourguideapp/widgets/horizontal_card_list_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812)); // Khởi tạo ScreenUtil

    final homeViewModel = Provider.of<HomeViewModel>(context);

    final List<HorizontalCardData> horizontalCards = [
      HorizontalCardData(
        imageUrl: 'https://www.pullman-danang.com/wp-content/uploads/sites/86/2023/03/hue-city-g228d128fd_1920.jpg',
        placeName: 'Kinh Thành Huế',
        description: 'Thừa Thiên Huế',
        rating: 4.5,
      ),
      HorizontalCardData(
        imageUrl: 'https://vnpay.vn/s1/statics.vnpay.vn/2023/9/01gg1bq72tx21695660244678.jpg',
        placeName: 'Nhà thờ Đá',
        description: 'Nha Trang',
        rating: 4.5,
      ),
      HorizontalCardData(
        imageUrl: 'https://ik.imagekit.io/tvlk/xpe-asset/AyJ40ZAo1DOyPyKLZ9c3RGQHTP2oT4ZXW+QmPVVkFQiXFSv42UaHGzSmaSzQ8DO5QIbWPZuF+VkYVRk6gh-Vg4ECbfuQRQ4pHjWJ5Rmbtkk=/2001357730516/Ba-Na-Hills-%2528Vietnam-Golden-Bridge%2529---Day-Tour-fe2e456e-05a1-4081-96df-c8fff570575b.png?tr=q-60,c-at_max,w-1280,h-720&_src=imagekit',
        placeName: 'Cầu Vàng',
        description: 'Đà Nẵng',
        rating: 4.5,
      ),
      HorizontalCardData(
        imageUrl: 'https://topquangngai.vn/wp-content/uploads/2022/08/mot-ngay-nang-tren-deo-violac-quang-ngai-296275938_164623472787479_2300489940475416046_n.jpg',
        placeName: 'Đèo Vi Ô Lắc',
        description: 'Quảng Ngãi',
        rating: 4.5,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 310.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 232.h,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.zero, topRight: Radius.zero, bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF66B2FF),
                          Color(0xFF007BFF),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 10.h),
                    child: Column(
                      children: [
                        UserHeader(
                          name: homeViewModel.name,
                          profileImageUrl: homeViewModel.profileImageUrl,
                        ),
                        SizedBox(height: 40.h),
                        Container(
                          width: 335.w,
                          height: 164.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r), 
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF000000).withOpacity(0.25),
                                blurRadius: 4.r,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: HomeNavigator(
                                        image: 'assets/img/car_home.png', 
                                        text: "Car Rental"
                                      ),
                                    ),
                                    Expanded(
                                      child: HomeNavigator(
                                        image: 'assets/img/motorbike_home.png', 
                                        text: "Motorbike Rental"
                                      ),
                                    ),
                                    Expanded(
                                      child: HomeNavigator(
                                        image: 'assets/img/travel_home.png', 
                                        text: "Travel"
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: HomeNavigator(
                                        image: 'assets/img/restaurant_home.png', 
                                        text: "Find Restaurant"
                                      ),
                                    ),
                                    Expanded(
                                      child: HomeNavigator(
                                        image: 'assets/img/delivery_home.png', 
                                        text: "Fast Delivery"
                                      ),
                                    ),
                                    Expanded(
                                      child: HomeNavigator(
                                        image: 'assets/img/hotel_home.png', 
                                        text: "Find Hotel"
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
              ]
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: buildSectionHeadline(context, "Popular", "The best destination for you", horizontalCards),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: buildSectionHeadline(context, "Nearest Places", "The best destination close to you", horizontalCards)
            ),
            // Thêm các phần khác tương tự...
          ],
        ),
      ),
    );
  }

  Widget buildSectionHeadline(BuildContext context, String title, String subtitle, List<HorizontalCardData> cardDataList) {
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeadline(
          title: title,
          subtitle: subtitle,
          viewAllColor: const Color(0xFFFF7029),
        ),
        SizedBox(height: 12.h),
        HorizontalCardListView(
          cardDataList: cardDataList,
          onCardTap: (cardData) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DestinationDetailPage(
                  data: cardData,
                  isFavourite: favouriteViewModel.isFavourite(cardData),
                  onFavouriteToggle: (isFavourite) {
                    favouriteViewModel.toggleFavourite(cardData);
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class UserHeader extends StatelessWidget {
  final String name;
  final String profileImageUrl;

  const UserHeader({
    required this.name,
    required this.profileImageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProfileContainer(),
        _buildNotificationButton(context),
      ],
    );
  }

  Widget _buildProfileContainer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(22.r),
      ),
      padding: EdgeInsets.fromLTRB(8.w, 4.w, 12.w, 4.w), // Điều chỉnh padding
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.w, // Sử dụng ScreenUtil cho radius
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            child: profileImageUrl.isEmpty
                ? Icon(Icons.person, color: Colors.grey[600], size: 20.sp) // Điều chỉnh kích thước icon
                : null,
          ),
          SizedBox(width: 12.w), // Điều chỉnh khoảng cách
          Text(
            name,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp, // Điều chỉnh kích thước văn bản
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: IconButton(
        icon: const Icon(Icons.notifications),
        iconSize: 24.sp, // Điều chỉnh kích thước icon
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification button pressed')),
          );
        },
      ),
    );
  }
}

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore the',
              style: TextStyle(
                color: Colors.black,
                fontSize: 38.sp, 
              ),
            ),
            SizedBox(height: 5.h), 
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Beautiful ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 38.sp, 
                    ),
                  ),
                  TextSpan(
                    text: 'world!',
                    style: TextStyle(
                      color: const Color(0xFFFF7029),
                      fontWeight: FontWeight.bold,
                      fontSize: 34.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SectionHeadline extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color viewAllColor;

  const SectionHeadline({
    required this.title,
    required this.subtitle,
    required this.viewAllColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate(title),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp, 
              ),
            ),
            SizedBox(height: 5.h), 
            Text(
              AppLocalizations.of(context).translate(subtitle),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp, 
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            AppLocalizations.of(context).translate("View all"),
            style: TextStyle(
              color: viewAllColor,
              fontSize: 14.sp, // Điều chỉnh kích thước văn bản
            ),
          ),
        ),
      ],
    );
  }
}
