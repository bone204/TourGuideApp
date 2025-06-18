// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/views/admin/admin_screen.dart';
import 'package:tourguideapp/views/chat/chat.dart';
import 'package:tourguideapp/views/momo_payment/momo_screen.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/home_navigator.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:tourguideapp/widgets/home_card_list_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/views/home/view_all_destinations_screen.dart';
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/views/home/search_screen.dart';
import 'package:tourguideapp/widgets/shimmer_cards.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;
  late String _selectedProvince;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  int _currentDestinationIndex = 0;
  Timer? _destinationTimer;
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedProvince = AppLocalizations.of(context).translate('All');
    
    if (!_isInitialized) {
      Provider.of<DestinationsViewModel>(context, listen: false).initialize();
      _isInitialized = true;
      _startDestinationTimer();
    }
  }

  void _startDestinationTimer() {
    _destinationTimer?.cancel();
    _destinationTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (mounted) {
        final destinations = Provider.of<DestinationsViewModel>(context, listen: false).destinations;
        if (destinations.isNotEmpty) {
          setState(() {
            _currentDestinationIndex = (_currentDestinationIndex + 1) % destinations.length;
          });
        }
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
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
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
                        height: 250.h,
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
                        padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 10.h),
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
                              padding: EdgeInsets.fromLTRB(4.w, 16.h, 4.w, 8.h),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 76.h,
                                    child: PageView(
                                      controller: _pageController,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _currentPageIndex = index;
                                        });
                                      },
                                      padEnds: false,
                                      children: [
                                        GridView.count(
                                          physics: const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 4,
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
                                          ],
                                        ),
                                        GridView.count(
                                          physics: const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 4,
                                          children: const [
                                            HomeNavigator(
                                              image: 'assets/img/hotel_home.png', 
                                              text: "Find Hotel"
                                            ),
                                            HomeNavigator(
                                              image: 'assets/img/delivery_home.png', 
                                              text: "Fast Delivery"
                                            ),
                                            HomeNavigator(
                                              image: 'assets/img/eatery_home.png', 
                                              text: "Find Eatery"
                                            ),
                                            HomeNavigator(
                                              image: 'assets/img/bus_home.png', 
                                              text: "Bus Booking"
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(2, (index) {
                                      return Container(
                                        width: 8.w,
                                        height: 8.h,
                                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentPageIndex == index
                                              ? AppColors.primaryColor
                                              : Colors.grey.withOpacity(0.3),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
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
                  provinces: [
                    AppLocalizations.of(context).translate('All'),
                    ...destinationsViewModel.uniqueProvinces
                  ],
                  onProvinceSelected: (province) {
                    setState(() {
                      _selectedProvince = province;
                    });
                  },
                  cardDataList: _selectedProvince == AppLocalizations.of(context).translate('All')
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
              duration: const Duration(milliseconds: 0),
              decoration: BoxDecoration(
                color: _isScrolled
                    ? AppColors.primaryColor
                    : Colors.transparent,
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
                  child: Row(
                    children: [
                      Expanded(
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
                              color:  Colors.white,
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
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminScreen(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.notifications_none,
                          color: AppColors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Chat(),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/img/ic_ai_chat.png',
                          width: 28.w,
                          height: 28.h,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MomoScreen(),
                            ),
                          );
                        },
                        child: Icon(Icons.payment, size: 28.sp, color: AppColors.white)
                      ),
                    ],
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
        cardDataList.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 120.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 200.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ],
              )
            : SectionHeadline(
                title: title,
                subtitle: subtitle,
                viewAllColor: const Color(0xFFFF7029),
                cardDataList: cardDataList,
              ),
        SizedBox(height: 12.h),
        cardDataList.isEmpty
            ? _buildShimmerHomeCards()
            : FutureBuilder<bool>(
                future: _precacheImages(cardDataList, context),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!) {
                    return _buildShimmerHomeCards();
                  }
                  return HomeCardListView(
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
                  );
                },
              ),
      ],
    );
  }

  Widget _buildShimmerHomeCards() {
    return SizedBox(
      height: 400.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(4.w, 4.h, 12.w, 6.h),
            child: const ShimmerHomeCard(),
          );
        },
      ),
    );
  }

  Future<bool> _precacheImages(List<HomeCardData> cardDataList, BuildContext context) async {
    try {
      final imagesToPrecache = cardDataList.take(3); // chỉ lấy 3 ảnh đầu
      await Future.wait(
        imagesToPrecache.map((card) => precacheImage(
          NetworkImage(card.imageUrl),
          context,
        )),
      );
      return true;
    } catch (e) {
      return false;
    }
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
                fontWeight: FontWeight.w700,
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
            AppLocalizations.of(context).translate("View All"),
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
    super.key,
    required this.selectedProvince,
    required this.provinces,
    required this.onProvinceSelected,
    required this.cardDataList,
    required this.onCardTap,
  });

  Future<bool> _precacheImages(List<HomeCardData> cardDataList, BuildContext context) async {
    try {
      await Future.wait(
        cardDataList.map((card) => precacheImage(
          NetworkImage(card.imageUrl),
          context,
        )),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildShimmerHomeCards() {
    return SizedBox(
      height: 400.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(4.w, 4.h, 12.w, 6.h),
            child: const ShimmerHomeCard(),
          );
        },
      ),
    );
  }

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
              fontWeight: FontWeight.w700,
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
          cardDataList.isEmpty
              ? _buildShimmerHomeCards()
              : FutureBuilder<bool>(
                  future: _precacheImages(cardDataList, context),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!) {
                      return _buildShimmerHomeCards();
                    }
                    return HomeCardListView(
                      cardDataList: cardDataList,
                      onCardTap: onCardTap,
                    );
                  },
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
    super.key,
    required this.cardDataList,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate("More travel inspiration"),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
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
          SizedBox(height: 16.h),
          cardDataList.isEmpty
              ? _buildShimmerGrid()
              : FutureBuilder<bool>(
                  future: _precacheImages(cardDataList, context),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!) {
                      return _buildShimmerGrid();
                    }
                    return _buildContentGrid(context);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 161.w / 190.h,
        mainAxisSpacing: 20.h,
        crossAxisSpacing: 10.w,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const ShimmerFavoriteCard(),
    );
  }

  Widget _buildContentGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 161.w / 190.h,
        mainAxisSpacing: 10.h,
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
    );
  }

  Future<bool> _precacheImages(List<HomeCardData> cardDataList, BuildContext context) async {
    try {
      await Future.wait(
        cardDataList.map((card) => precacheImage(
          NetworkImage(card.imageUrl),
          context,
        )),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
