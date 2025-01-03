import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/home_navigator.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:tourguideapp/widgets/home_card_list_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/views/home/view_all_destinations_screen.dart';
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/views/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;
  String _selectedProvince = 'All';
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  int _currentDestinationIndex = 0;
  Timer? _destinationTimer;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _startDestinationTimer() {
    _destinationTimer?.cancel();
    _destinationTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (mounted) {
        setState(() {
          final destinations = Provider.of<DestinationsViewModel>(context, listen: false).destinations;
          if (destinations.isNotEmpty) {
            _currentDestinationIndex = (_currentDestinationIndex + 1) % destinations.length;
          }
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 10) {
      if (!_isScrolled) {
        setState(() => _isScrolled = true);
      }
    } else {
      if (_isScrolled) {
        setState(() => _isScrolled = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _destinationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final destinationsViewModel = Provider.of<DestinationsViewModel>(context, listen: false);
      destinationsViewModel.fetchDestinations();
      _isInitialized = true;
      _startDestinationTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            controller: _scrollController,
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
                        padding: EdgeInsets.fromLTRB(20.w, 70.h, 20.w, 10.h),
                        child: Column(
                          children: [
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
                              child: SizedBox(
                                height: 180.h,
                                child: PageView(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                    });
                                  },
                                  children: [
                                    // Page 1: Services
                                    GridView.count(
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 2.h,
                                      crossAxisSpacing: 2.w,
                                      childAspectRatio: 1.2,
                                      children: const [
                                        HomeNavigator(
                                          image: 'assets/img/car_home.png', 
                                          text: "Car Rental"
                                        ),
                                        HomeNavigator(
                                          image: 'assets/img/motorbike_home.png', 
                                          text: "Motorbike Rental"
                                        ),
                                        HomeNavigator(
                                          image: 'assets/img/travel_home.png', 
                                          text: "Travel"
                                        ),
                                        HomeNavigator(
                                          image: 'assets/img/restaurant_home.png', 
                                          text: "Find Restaurant"
                                        ),
                                        HomeNavigator(
                                          image: 'assets/img/hotel_home.png', 
                                          text: "Find Hotel"
                                        ),
                                        HomeNavigator(
                                          image: 'assets/img/delivery_home.png', 
                                          text: "Fast Delivery"
                                        ),
                                      ],
                                    ),
                                    // Page 2: More
                                    GridView.count(
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 4.h,
                                      crossAxisSpacing: 4.w,
                                      childAspectRatio: 1.2,
                                      children: const [
                                        HomeNavigator(
                                          image: 'assets/img/eatery_home.png', 
                                          text: "Find Eatery"
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ],
                ),
                // Popular Destinations
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                  child: buildSectionHeadline(
                    context, 
                    "Popular", 
                    "The best destination for you", 
                    destinationsViewModel.horizontalCardsData
                  ),
                ),
                // Province Section
                ProvinceSection(
                  selectedProvince: _selectedProvince,
                  provinces: ['All', ...destinationsViewModel.uniqueProvinces],
                  onProvinceSelected: (province) {
                    setState(() {
                      _selectedProvince = province;
                    });
                  },
                  cardDataList: _selectedProvince == 'All'
                      ? destinationsViewModel.horizontalCardsData
                      : destinationsViewModel.getDestinationsByProvince(_selectedProvince),
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
                SizedBox(height: 32.h),
                // Inspiration Section
                InspirationSection(
                  cardDataList: destinationsViewModel.horizontalCardsData,
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
                SizedBox(height: 10.h),
              ],
            ),
          ),
          // Search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: _isScrolled
                    ? const LinearGradient(
                        colors: [Colors.white, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : const LinearGradient(
                        colors: [Colors.transparent, Colors.transparent],
                      ),
                boxShadow: _isScrolled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            initialHint: destinationsViewModel.destinations.isNotEmpty
                                ? destinationsViewModel.destinations[_currentDestinationIndex].destinationName
                                : AppLocalizations.of(context).translate('Search destinations...'),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _isScrolled ? AppColors.lightGrey : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.grey,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  destinationsViewModel.destinations.isNotEmpty
                                      ? destinationsViewModel.destinations[_currentDestinationIndex].destinationName
                                      : AppLocalizations.of(context).translate('Search destinations...'),
                                  key: ValueKey<int>(_currentDestinationIndex),
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

class ProvinceSection extends StatelessWidget {
  final String selectedProvince;
  final List<String> provinces;
  final Function(String) onProvinceSelected;
  final List<HomeCardData> cardDataList;
  final Function(HomeCardData) onCardTap;

  const ProvinceSection({
    Key? key,
    required this.selectedProvince,
    required this.provinces,
    required this.onProvinceSelected,
    required this.cardDataList,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate("Explore top spots by province"),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).translate("Discover places across provinces"),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16.h),
          CategorySelector(
            selectedCategory: selectedProvince,
            categories: provinces,
            onCategorySelected: onProvinceSelected,
          ),
          SizedBox(height: 16.h),
          HomeCardListView(
            cardDataList: cardDataList,
            onCardTap: onCardTap,
          ),
        ],
      ),
    );
  }
}

class InspirationSection extends StatelessWidget {
  final List<HomeCardData> cardDataList;
  final Function(HomeCardData) onCardTap;

  const InspirationSection({
    Key? key,
    required this.cardDataList,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate("More travel inspiration"),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  AppLocalizations.of(context).translate("Extra highlights just for you"),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 161.w / 190.h,
              mainAxisSpacing: 20.h,
              crossAxisSpacing: 10.w,
            ),
            itemCount: cardDataList.length,
            itemBuilder: (context, index) {
              final cardData = cardDataList[index];
              return GestureDetector(
                onTap: () => onCardTap(cardData),
                child: FavouriteCard(
                  data: FavouriteCardData(
                    placeName: cardData.placeName,
                    imageUrl: cardData.imageUrl,
                    description: cardData.description,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
