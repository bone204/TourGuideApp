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
import 'package:tourguideapp/views/home/view_all_destinations_screen.dart';

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
                                avatar: homeViewModel.avatar,
                              ),
                              SizedBox(height: 40.h),
                              Container(
                                width: 335.w,
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
                                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const HomeNavigator(
                                            image: 'assets/img/car_home.png', 
                                            text: "Car Rental"
                                          ),
                                          SizedBox(height: 8.h),
                                          const HomeNavigator(
                                            image: 'assets/img/restaurant_home.png', 
                                            text: "Find Eatery"
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const HomeNavigator(
                                            image: 'assets/img/motorbike_home.png', 
                                            text: "Motorbike Rental"
                                          ),
                                          SizedBox(height: 8.h),
                                          const HomeNavigator(
                                            image: 'assets/img/delivery_home.png', 
                                            text: "Fast Delivery"
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const HomeNavigator(
                                            image: 'assets/img/travel_home.png', 
                                            text: "Travel"
                                          ),
                                          SizedBox(height: 8.h),
                                          const HomeNavigator(
                                            image: 'assets/img/hotel_home.png', 
                                            text: "Find Hotel"
                                          ),
                                        ],
                                      ),
                                    ),
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
                      "Popular", 
                      "The best destination for you", 
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
          cardDataList: cardDataList,
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
  final String avatar;

  const UserHeader({
    required this.name,
    required this.avatar,
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
      padding: EdgeInsets.fromLTRB(8.w, 8.w, 12.w, 8.w), // Điều chỉnh padding
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.w, // Sử dụng ScreenUtil cho radius
            backgroundImage: avatar.isNotEmpty
                ? NetworkImage(avatar)
                : null,
            child: avatar.isEmpty
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

class SectionHeadline extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color viewAllColor;
  final List<HomeCardData> cardDataList;

  const SectionHeadline({
    required this.title,
    required this.subtitle,
    required this.viewAllColor,
    required this.cardDataList,
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewAllDestinationsScreen(
                  sectionTitle: title,
                  cardDataList: cardDataList,
                ),
              ),
            );
          },
          child: Text(
            AppLocalizations.of(context).translate("View all"),
            style: TextStyle(
              color: viewAllColor,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
