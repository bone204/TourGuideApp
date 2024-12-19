import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/home_navigator.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:tourguideapp/widgets/home_card_list_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Gọi fetchDestinations một lần duy nhất khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        final destinationsViewModel = Provider.of<DestinationsViewModel>(context, listen: false);
        destinationsViewModel.fetchDestinations();
        _isInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final homeViewModel = Provider.of<HomeViewModel>(context);
    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: destinationsViewModel.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : destinationsViewModel.error.isNotEmpty
          ? Center(child: Text(destinationsViewModel.error))
          : SingleChildScrollView(
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
                                          // Expanded(
                                          //   child: HomeNavigator(
                                          //     image: 'assets/img/restaurant_home.png', 
                                          //     text: "Find Restaurant"
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   child: HomeNavigator(
                                          //     image: 'assets/img/destination.png', 
                                          //     text: "Find Destination"
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   child: HomeNavigator(
                                          //     image: 'assets/img/review.png', 
                                          //     text: "Review"
                                          //   ),
                                          // ),
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
                  // Popular Destinations
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                    child: buildSectionHeadline(
                      context, 
                      "Destinations", 
                      "Explore beautiful places", 
                      destinationsViewModel.horizontalCardsData
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildSectionHeadline(BuildContext context, String title, String subtitle, List<HomeCardData> cardDataList) {
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);
    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeadline(
          title: title,
          subtitle: subtitle,
          viewAllColor: const Color(0xFFFF7029),
        ),
        SizedBox(height: 12.h),
        HomeCardListView(
          cardDataList: cardDataList,
          onCardTap: (cardData) {
            final destination = destinationsViewModel.destinations.firstWhere(
              (dest) => dest.destinationName == cardData.placeName,
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DestinationDetailPage(
                  cardData: cardData,
                  destinationData: destination,
                  isFavourite: favouriteViewModel.isFavourite(destination),
                  onFavouriteToggle: (isFavourite) {
                    favouriteViewModel.toggleFavourite(destination);
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
