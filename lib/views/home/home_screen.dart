// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/views/chat/chat.dart';
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
import 'package:tourguideapp/views/notification/notification_screen.dart';
import 'package:tourguideapp/core/services/notification_service.dart';
import 'package:tourguideapp/core/services/user_service.dart';
import 'package:badges/badges.dart' as badges;
import 'package:tourguideapp/core/services/cooperation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  double _fabRight = 20;
  double _fabBottom = 40;

  // Thêm biến phân trang
  int _visiblePopular = 10;
  int _visibleProvince = 10;
  int _visibleInspiration = 10;
  static const int _itemsPerPage = 10;
  final ScrollController _popularScrollController = ScrollController();
  final ScrollController _provinceScrollController = ScrollController();
  bool _isLoadingPopular = false;
  bool _isLoadingProvince = false;
  bool _isLoadingInspiration = false;

  // Thêm biến cho notification
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  int _unreadNotificationCount = 0;
  Timer? _notificationTimer;
  String? _currentUserId;

  // Thêm biến cho 3 phần mới
  final CooperationService _cooperationService = CooperationService();
  List<HomeCardData> _highRatedPlaces = [];
  List<HomeCardData> _binhDuongHotels = [];
  List<HomeCardData> _binhDuongRestaurants = [];
  bool _isLoadingHighRated = false;
  bool _isLoadingHotels = false;
  bool _isLoadingRestaurants = false;
  int _visibleHighRated = 10;
  int _visibleHotels = 10;
  int _visibleRestaurants = 10;
  final ScrollController _highRatedScrollController = ScrollController();
  final ScrollController _hotelsScrollController = ScrollController();
  final ScrollController _restaurantsScrollController = ScrollController();

  // Biến để lưu danh sách inspiration đã sắp xếp
  List<HomeCardData> _sortedInspirationList = [];
  bool _isLoadingSortedInspiration = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _popularScrollController.addListener(_onPopularScroll);
    _provinceScrollController.addListener(_onProvinceScroll);
    _highRatedScrollController.addListener(_onHighRatedScroll);
    _hotelsScrollController.addListener(_onHotelsScroll);
    _restaurantsScrollController.addListener(_onRestaurantsScroll);
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    try {
      await _notificationService.initialize();
      // Lấy user ID từ UserService
      _currentUserId = await _userService.getCurrentUserId();
      print(
          'Debug: Initialized notification service, User ID: $_currentUserId');

      if (_currentUserId != null) {
        await _notificationService.registerUserToken(_currentUserId!);
        _startNotificationTimer();
      } else {
        print('Debug: No user ID found, using test user ID');
        // Sử dụng test user ID nếu không có user đăng nhập
        _currentUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
        await _userService.saveCurrentUserId(_currentUserId!);
        await _notificationService.registerUserToken(_currentUserId!);
        _startNotificationTimer();
      }
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  void _startNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadUnreadNotificationCount();
    });
    // Load ngay lập tức
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUnreadNotificationCount() async {
    if (_currentUserId != null) {
      try {
        final count = await _notificationService
            .getUnreadNotificationCount(_currentUserId!);
        print('Debug: User ID: $_currentUserId, Unread count: $count');
        if (mounted && count != _unreadNotificationCount) {
          setState(() {
            _unreadNotificationCount = count;
          });
        }
      } catch (e) {
        print('Error loading unread notification count: $e');
      }
    } else {
      print('Debug: Current user ID is null');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedProvince = AppLocalizations.of(context).translate('All');

    if (!_isInitialized) {
      Provider.of<DestinationsViewModel>(context, listen: false).initialize();
      _isInitialized = true;
      _startDestinationTimer();
      // Delay để đảm bảo DestinationsViewModel đã load xong
      Future.delayed(const Duration(milliseconds: 500), () {
        _loadCooperationData();
        // Load danh sách inspiration đã sắp xếp
        final destinationsViewModel =
            Provider.of<DestinationsViewModel>(context, listen: false);
        _loadSortedInspirationList(destinationsViewModel.horizontalCardsData);
      });
    }

    // Cập nhật danh sách đã sắp xếp khi favorite destinations thay đổi
    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);
    if (destinationsViewModel.horizontalCardsData.isNotEmpty &&
        _sortedInspirationList.isEmpty) {
      _loadSortedInspirationList(destinationsViewModel.horizontalCardsData);
    }
  }

  void _startDestinationTimer() {
    _destinationTimer?.cancel();
    _destinationTimer =
        Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (mounted) {
        final destinations =
            Provider.of<DestinationsViewModel>(context, listen: false)
                .destinations;
        if (destinations.isNotEmpty) {
          setState(() {
            _currentDestinationIndex =
                (_currentDestinationIndex + 1) % destinations.length;
          });
        }
      }
    });
  }

  Future<void> _loadCooperationData() async {
    // Load High Rated Places từ DESTINATION
    setState(() => _isLoadingHighRated = true);
    try {
      final destinationsViewModel =
          Provider.of<DestinationsViewModel>(context, listen: false);
      final allDestinations = destinationsViewModel.horizontalCardsData;
      // Sắp xếp theo rating cao đến thấp
      _highRatedPlaces = allDestinations.toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
    } catch (e) {
      print('Error loading high rated places: $e');
    }
    setState(() => _isLoadingHighRated = false);

    // Load Bình Dương Hotels
    setState(() => _isLoadingHotels = true);
    try {
      _binhDuongHotels = await _cooperationService.getBinhDuongHotels();
    } catch (e) {
      print('Error loading Bình Dương hotels: $e');
    }
    setState(() => _isLoadingHotels = false);

    // Load Bình Dương Restaurants
    setState(() => _isLoadingRestaurants = true);
    try {
      _binhDuongRestaurants =
          await _cooperationService.getBinhDuongRestaurants();
    } catch (e) {
      print('Error loading Bình Dương restaurants: $e');
    }
    setState(() => _isLoadingRestaurants = false);
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
    // Logic mới: khi kéo tới đáy trang thì load thêm cho Inspiration
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final total = Provider.of<DestinationsViewModel>(context, listen: false)
        .horizontalCardsData
        .length;
    if (currentScroll >= maxScroll - 100 &&
        !_isLoadingInspiration &&
        _visibleInspiration < total) {
      setState(() {
        _isLoadingInspiration = true;
      });
      Future.delayed(const Duration(milliseconds: 800)).then((_) {
        if (mounted) {
          setState(() {
            _visibleInspiration =
                (_visibleInspiration + _itemsPerPage).clamp(0, total);
            _isLoadingInspiration = false;
          });
        }
      });
    }
  }

  void _onPopularScroll() async {
    if (_popularScrollController.position.pixels >=
            _popularScrollController.position.maxScrollExtent - 100 &&
        !_isLoadingPopular) {
      final total = Provider.of<DestinationsViewModel>(context, listen: false)
          .horizontalCardsData
          .length;
      if (_visiblePopular < total) {
        setState(() {
          _isLoadingPopular = true;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _visiblePopular = (_visiblePopular + _itemsPerPage).clamp(0, total);
          _isLoadingPopular = false;
        });
      }
    }
  }

  void _onProvinceScroll() async {
    final total =
        _selectedProvince == AppLocalizations.of(context).translate('All')
            ? Provider.of<DestinationsViewModel>(context, listen: false)
                .horizontalCardsData
                .length
            : Provider.of<DestinationsViewModel>(context, listen: false)
                .getDestinationsByProvince(_selectedProvince)
                .length;
    if (_provinceScrollController.position.pixels >=
            _provinceScrollController.position.maxScrollExtent - 100 &&
        !_isLoadingProvince) {
      if (_visibleProvince < total) {
        setState(() {
          _isLoadingProvince = true;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _visibleProvince = (_visibleProvince + _itemsPerPage).clamp(0, total);
          _isLoadingProvince = false;
        });
      }
    }
  }

  void _onHighRatedScroll() async {
    if (_highRatedScrollController.position.pixels >=
            _highRatedScrollController.position.maxScrollExtent - 100 &&
        !_isLoadingHighRated) {
      final total = _highRatedPlaces.length;
      if (_visibleHighRated < total) {
        setState(() {
          _isLoadingHighRated = true;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _visibleHighRated =
              (_visibleHighRated + _itemsPerPage).clamp(0, total);
          _isLoadingHighRated = false;
        });
      }
    }
  }

  void _onHotelsScroll() async {
    if (_hotelsScrollController.position.pixels >=
            _hotelsScrollController.position.maxScrollExtent - 100 &&
        !_isLoadingHotels) {
      final total = _binhDuongHotels.length;
      if (_visibleHotels < total) {
        setState(() {
          _isLoadingHotels = true;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _visibleHotels = (_visibleHotels + _itemsPerPage).clamp(0, total);
          _isLoadingHotels = false;
        });
      }
    }
  }

  void _onRestaurantsScroll() async {
    if (_restaurantsScrollController.position.pixels >=
            _restaurantsScrollController.position.maxScrollExtent - 100 &&
        !_isLoadingRestaurants) {
      final total = _binhDuongRestaurants.length;
      if (_visibleRestaurants < total) {
        setState(() {
          _isLoadingRestaurants = true;
        });
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _visibleRestaurants =
              (_visibleRestaurants + _itemsPerPage).clamp(0, total);
          _isLoadingRestaurants = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _destinationTimer?.cancel();
    _pageController.dispose();
    _popularScrollController.dispose();
    _provinceScrollController.dispose();
    _notificationTimer?.cancel();
    _highRatedScrollController.dispose();
    _hotelsScrollController.dispose();
    _restaurantsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);
    final favouriteViewModel =
        Provider.of<FavouriteDestinationsViewModel>(context);

    // Lấy danh sách phân trang cho từng section
    List<HomeCardData> popularList = destinationsViewModel.horizontalCardsData;
    List<HomeCardData> pagedPopularList =
        popularList.take(_visiblePopular).toList();

    List<HomeCardData> provinceList = _selectedProvince ==
            AppLocalizations.of(context).translate('All')
        ? destinationsViewModel.horizontalCardsData
        : destinationsViewModel.getDestinationsByProvince(_selectedProvince);
    List<HomeCardData> pagedProvinceList =
        provinceList.take(_visibleProvince).toList();

    List<HomeCardData> inspirationList =
        destinationsViewModel.horizontalCardsData;
    List<HomeCardData> pagedInspirationList =
        inspirationList.take(_visibleInspiration).toList();

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
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.zero,
                              topRight: Radius.zero,
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16)),
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
                        child: Column(children: [
                          Container(
                            width: 335.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF000000).withOpacity(0.25),
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
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 4,
                                        children: const [
                                          HomeNavigator(
                                              image: 'assets/img/car_home.png',
                                              text: "Car Rental"),
                                          HomeNavigator(
                                              image:
                                                  'assets/img/motorbike_home.png',
                                              text: "Motorbike Rental"),
                                          HomeNavigator(
                                              image:
                                                  'assets/img/travel_home.png',
                                              text: "Travel"),
                                          HomeNavigator(
                                              image:
                                                  'assets/img/restaurant_home.png',
                                              text: "Find Restaurant"),
                                        ],
                                      ),
                                      GridView.count(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 4,
                                        children: const [
                                          HomeNavigator(
                                              image:
                                                  'assets/img/hotel_home.png',
                                              text: "Find Hotel"),
                                          HomeNavigator(
                                              image:
                                                  'assets/img/delivery_home.png',
                                              text: "Fast Delivery"),
                                          HomeNavigator(
                                              image:
                                                  'assets/img/eatery_home.png',
                                              text: "Find Eatery"),
                                          HomeNavigator(
                                              image: 'assets/img/bus_home.png',
                                              text: "Bus Booking"),
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
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4.w),
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
                        ]),
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
                    pagedPopularList,
                    scrollController: _popularScrollController,
                    isLoading: _isLoadingPopular,
                    hasMore: _visiblePopular < popularList.length,
                  ),
                ),
                // High Rates Section
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                  child: buildSectionHeadline(
                    context,
                    "High Rates",
                    "Top rated destinations across Vietnam",
                    _highRatedPlaces.take(_visibleHighRated).toList(),
                    scrollController: _highRatedScrollController,
                    isLoading: _isLoadingHighRated,
                    hasMore: _visibleHighRated < _highRatedPlaces.length,
                  ),
                ),
                // Hotel Nearby Section
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                  child: buildSectionHeadline(
                    context,
                    "Hotel Nearby",
                    "Best hotels in Bình Dương province",
                    _binhDuongHotels.take(_visibleHotels).toList(),
                    scrollController: _hotelsScrollController,
                    isLoading: _isLoadingHotels,
                    hasMore: _visibleHotels < _binhDuongHotels.length,
                  ),
                ),
                // Restaurant Nearby Section
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                  child: buildSectionHeadline(
                    context,
                    "Restaurant Nearby",
                    "Best restaurants in Bình Dương province",
                    _binhDuongRestaurants.take(_visibleRestaurants).toList(),
                    scrollController: _restaurantsScrollController,
                    isLoading: _isLoadingRestaurants,
                    hasMore: _visibleRestaurants < _binhDuongRestaurants.length,
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
                      _visibleProvince = _itemsPerPage; // reset khi đổi tỉnh
                    });
                  },
                  cardDataList: pagedProvinceList,
                  onCardTap: (cardData) {
                    final destination =
                        destinationsViewModel.destinations.firstWhere(
                      (dest) => dest.destinationName == cardData.placeName,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DestinationDetailPage(
                          cardData: cardData,
                          destinationData: destination,
                          isFavourite:
                              favouriteViewModel.isFavourite(destination),
                          onFavouriteToggle: (isFavourite) {
                            favouriteViewModel.toggleFavourite(destination);
                          },
                        ),
                      ),
                    );
                  },
                  scrollController: _provinceScrollController,
                  isLoading: _isLoadingProvince,
                  hasMore: _visibleProvince < provinceList.length,
                ),
                SizedBox(height: 32.h),
                // Inspiration Section
                Consumer<DestinationsViewModel>(
                  builder: (context, destinationsViewModel, child) {
                    if (destinationsViewModel.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    // Chỉ gọi _loadSortedInspirationList khi dữ liệu đã sẵn sàng và chưa có sorted list
                    if (_sortedInspirationList.isEmpty &&
                        destinationsViewModel.horizontalCardsData.isNotEmpty &&
                        !_isLoadingSortedInspiration) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadSortedInspirationList(
                            destinationsViewModel.horizontalCardsData);
                      });
                      return Center(child: CircularProgressIndicator());
                    }
                    return InspirationSection(
                      cardDataList: _sortedInspirationList.isNotEmpty
                          ? _sortedInspirationList
                              .take(_visibleInspiration)
                              .toList()
                          : destinationsViewModel.horizontalCardsData
                              .take(_visibleInspiration)
                              .toList(),
                      onCardTap: (cardData) {
                        final destination =
                            destinationsViewModel.destinations.firstWhere(
                          (dest) => dest.destinationName == cardData.placeName,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DestinationDetailPage(
                              cardData: cardData,
                              destinationData: destination,
                              isFavourite:
                                  favouriteViewModel.isFavourite(destination),
                              onFavouriteToggle: (isFavourite) {
                                favouriteViewModel.toggleFavourite(destination);
                              },
                            ),
                          ),
                        );
                      },
                      isLoading:
                          _isLoadingInspiration || _isLoadingSortedInspiration,
                      hasMore: _visibleInspiration <
                          (_sortedInspirationList.isNotEmpty
                              ? _sortedInspirationList.length
                              : destinationsViewModel
                                  .horizontalCardsData.length),
                    );
                  },
                ),
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
                color:
                    _isScrolled ? AppColors.primaryColor : Colors.transparent,
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
                                  initialHint: destinationsViewModel
                                          .destinations.isNotEmpty
                                      ? destinationsViewModel
                                          .destinations[
                                              _currentDestinationIndex]
                                          .destinationName
                                      : AppLocalizations.of(context)
                                          .translate('Search destinations...'),
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
                              color: Colors.white,
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
                                      duration:
                                          const Duration(milliseconds: 500),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
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
                                        destinationsViewModel
                                                .destinations.isNotEmpty
                                            ? destinationsViewModel
                                                .destinations[
                                                    _currentDestinationIndex]
                                                .destinationName
                                            : AppLocalizations.of(context)
                                                .translate(
                                                    'Search destinations...'),
                                        key: ValueKey<int>(
                                            _currentDestinationIndex),
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
                      SizedBox(width: 12.w),
                      // Notification button with badge
                      _currentUserId == null
                          ? Icon(
                              Icons.notifications,
                              color: AppColors.white,
                              size: 28.sp,
                            )
                          : StreamBuilder<int>(
                              stream: _notificationService
                                  .unreadNotificationCountStream(
                                      _currentUserId!),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                return badges.Badge(
                                  showBadge: count > 0,
                                  badgeStyle: badges.BadgeStyle(
                                    badgeColor: Colors.red,
                                    padding: const EdgeInsets.all(3),
                                    borderRadius: BorderRadius.circular(10),
                                    elevation: 0,
                                  ),
                                  badgeContent: Container(
                                    constraints: const BoxConstraints(
                                        minWidth: 16, minHeight: 16),
                                    alignment: Alignment.center,
                                    child: Text(
                                      count > 99 ? '99+' : count.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  position: badges.BadgePosition.topEnd(
                                      top: -4, end: -6),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_currentUserId != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NotificationScreen(
                                              userId: _currentUserId!,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Icon(
                                      Icons.notifications,
                                      color: AppColors.white,
                                      size: 32.sp,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating draggable button
          Positioned(
            right: _fabRight,
            bottom: _fabBottom,
            child: GestureDetector(
              onPanStart: (details) {
                // _initX = details.globalPosition.dx;
                // _initY = details.globalPosition.dy;
              },
              onPanUpdate: (details) {
                setState(() {
                  _fabRight -= details.delta.dx;
                  _fabBottom -= details.delta.dy;
                  // Giới hạn không cho button ra ngoài màn hình
                  if (_fabRight < 0) _fabRight = 0;
                  if (_fabBottom < 0) _fabBottom = 0;
                });
              },
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                mini: false,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Chat(),
                    ),
                  );
                },
                child: SizedBox(
                    width: 300.w,
                    height: 300.h,
                    child: Image.asset('assets/img/floating.gif')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeadline(BuildContext context, String title,
      String subtitle, List<HomeCardData> cardDataList,
      {ScrollController? scrollController,
      bool isLoading = false,
      bool hasMore = false}) {
    final favouriteViewModel =
        Provider.of<FavouriteDestinationsViewModel>(context);
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
                      _handleCardTap(cardData, title, destinationsViewModel,
                          favouriteViewModel);
                    },
                    scrollController: scrollController,
                    isLoading: isLoading,
                    hasMore: hasMore,
                  );
                },
              ),
      ],
    );
  }

  void _handleCardTap(
      HomeCardData cardData,
      String sectionTitle,
      DestinationsViewModel destinationsViewModel,
      FavouriteDestinationsViewModel favouriteViewModel) {
    // Xử lý tap cho các card từ COOPERATION
    if (sectionTitle == "Hotel Nearby" || sectionTitle == "Restaurant Nearby") {
      // TODO: Navigate to cooperation detail page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cardData.placeName} - Coming soon!'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Xử lý tap cho các card từ DESTINATION (Popular, Province, Inspiration, High Rates)
    try {
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
    } catch (e) {
      print('Destination not found: ${cardData.placeName}');
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

  Future<bool> _precacheImages(
      List<HomeCardData> cardDataList, BuildContext context) async {
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

  // Hàm sắp xếp danh sách inspiration theo user preferences
  Future<List<HomeCardData>> _sortInspirationList(
      List<HomeCardData> originalList) async {
    if (originalList.isEmpty) return originalList;

    final destinationsViewModel =
        Provider.of<DestinationsViewModel>(context, listen: false);
    final favouriteViewModel =
        Provider.of<FavouriteDestinationsViewModel>(context, listen: false);

    // Lấy thông tin user preferences
    final userData = await _getUserPreferences();
    final favoriteDestinationIds =
        List<String>.from(userData['favoriteDestinationIds'] ?? []);
    final hobbies = List<Map<String, dynamic>>.from(userData['hobbies'] ?? []);

    print('🔍 DEBUG: favoriteDestinationIds = $favoriteDestinationIds');
    print('🔍 DEBUG: originalList length = ${originalList.length}');
    print(
        '🔍 DEBUG: originalList names = ${originalList.map((e) => e.placeName).toList()}');

    // Kiểm tra xem có destination nào có tên chứa "vườn quốc gia" không
    final destinationsWithVQG = originalList
        .where((card) => card.placeName.toLowerCase().contains("vườn quốc gia"))
        .toList();
    print(
        '🔍 DEBUG: Destinations with "vườn quốc gia": ${destinationsWithVQG.map((e) => e.placeName).toList()}');

    // Kiểm tra toàn bộ database xem có destination nào có tên chứa "vườn quốc gia" không
    final allDestinationsWithVQG = destinationsViewModel.destinations
        .where((dest) =>
            dest.destinationName.toLowerCase().contains("vườn quốc gia"))
        .toList();
    print(
        '🔍 DEBUG: All destinations in DB with "vườn quốc gia": ${allDestinationsWithVQG.map((e) => e.destinationName).toList()}');

    // Kiểm tra xem D00521 và D01081 có trong danh sách không
    final d00521InList = originalList.any((card) =>
        destinationsViewModel.destinations.any((dest) =>
            dest.destinationId == "D00521" &&
            dest.destinationName == card.placeName));
    final d01081InList = originalList.any((card) =>
        destinationsViewModel.destinations.any((dest) =>
            dest.destinationId == "D01081" &&
            dest.destinationName == card.placeName));
    print(
        '🔍 DEBUG: D00521 in list: $d00521InList, D01081 in list: $d01081InList');

    // Kiểm tra tên của D00521 và D01081
    final d00521Dest = destinationsViewModel.destinations
        .where((dest) => dest.destinationId == "D00521")
        .firstOrNull;
    final d01081Dest = destinationsViewModel.destinations
        .where((dest) => dest.destinationId == "D01081")
        .firstOrNull;
    print(
        '🔍 DEBUG: D00521 name: ${d00521Dest?.destinationName ?? "Not found"}');
    print(
        '🔍 DEBUG: D01081 name: ${d01081Dest?.destinationName ?? "Not found"}');

    List<HomeCardData> sortedList = List.from(originalList);

    // Điều kiện 1: Nếu có D00521 và D01081 trong favorite, ưu tiên "vườn quốc gia"
    final hasD00521 = favoriteDestinationIds.contains("D00521");
    final hasD01081 = favoriteDestinationIds.contains("D01081");
    print('🔍 DEBUG: hasD00521 = $hasD00521, hasD01081 = $hasD01081');

    if (hasD00521 && hasD01081) {
      print(
          '🔍 DEBUG: Đưa tất cả "Vườn Quốc gia" lên đầu danh sách inspiration');
      // 1. Lấy tất cả destination có tên bắt đầu bằng "Vườn Quốc gia"
      final vqgDestinations = destinationsViewModel.destinations
          .where((dest) => dest.destinationName
              .trim()
              .toLowerCase()
              .startsWith("vườn quốc gia"))
          .toList();

      // 2. Chuyển sang HomeCardData
      final vqgCards = vqgDestinations
          .map((dest) => HomeCardData(
                placeName: dest.destinationName,
                imageUrl: dest.photo.isNotEmpty ? dest.photo[0] : '',
                description: dest.province,
                rating: dest.rating,
                favouriteTimes: dest.favouriteTimes,
              ))
          .toList();

      // 3. Loại bỏ các item trùng trong originalList
      final vqgNames = vqgCards.map((e) => e.placeName).toSet();
      final rest = originalList
          .where((card) => !vqgNames.contains(card.placeName))
          .toList();

      // 4. Ghép lại: VQG lên đầu, các item còn lại phía sau
      sortedList = [...vqgCards, ...rest];
      print(
          '🔍 DEBUG: Inspiration list sau khi ưu tiên Vườn Quốc gia: ${sortedList.map((e) => e.placeName).toList()}');
    }

    // Điều kiện 2: Nếu có CA02 trong hobbies, ưu tiên "Giải trí"
    final hasCA02 = hobbies.any((hobby) => hobby['categoriesID'] == "CA02");
    print('🔍 DEBUG: hasCA02 = $hasCA02');
    if (hasCA02) {
      print('🔍 DEBUG: Applying entertainment sorting...');
      sortedList.sort((a, b) {
        // Tìm destination tương ứng để lấy category
        try {
          final destA = destinationsViewModel.destinations.firstWhere(
            (dest) => dest.destinationName == a.placeName,
          );
          final destB = destinationsViewModel.destinations.firstWhere(
            (dest) => dest.destinationName == b.placeName,
          );

          final aIsEntertainment = destA.categories.contains("Giải trí");
          final bIsEntertainment = destB.categories.contains("Giải trí");

          print(
              '🔍 DEBUG: Comparing "${a.placeName}" (isEntertainment: $aIsEntertainment) vs "${b.placeName}" (isEntertainment: $bIsEntertainment)');

          if (aIsEntertainment && !bIsEntertainment) return -1;
          if (!aIsEntertainment && bIsEntertainment) return 1;
          return 0;
        } catch (e) {
          print('🔍 DEBUG: Error finding destination for comparison: $e');
          return 0;
        }
      });
      print(
          '🔍 DEBUG: After entertainment sorting: ${sortedList.map((e) => e.placeName).toList()}');
    }

    // Điều kiện 3: Nếu có D00426 trong danh sách, sắp xếp theo số lượng đánh giá
    final hasD00426 = sortedList.any((card) {
      try {
        final dest = destinationsViewModel.destinations.firstWhere(
          (dest) => dest.destinationName == card.placeName,
        );
        return dest.destinationId == "D00426";
      } catch (e) {
        return false;
      }
    });
    print('🔍 DEBUG: hasD00426 = $hasD00426');

    if (hasD00426) {
      print('🔍 DEBUG: Applying rating sorting...');
      sortedList.sort((a, b) {
        try {
          final destA = destinationsViewModel.destinations.firstWhere(
            (dest) => dest.destinationName == a.placeName,
          );
          final destB = destinationsViewModel.destinations.firstWhere(
            (dest) => dest.destinationName == b.placeName,
          );

          // Sắp xếp từ nhiều đánh giá nhất đến ít nhất
          final result =
              destB.userRatingsTotal.compareTo(destA.userRatingsTotal);
          print(
              '🔍 DEBUG: Comparing "${a.placeName}" (${destA.userRatingsTotal} ratings) vs "${b.placeName}" (${destB.userRatingsTotal} ratings) = $result');
          return result;
        } catch (e) {
          print(
              '🔍 DEBUG: Error finding destination for rating comparison: $e');
          return 0;
        }
      });
      print(
          '🔍 DEBUG: After rating sorting: ${sortedList.map((e) => e.placeName).toList()}');
    }

    // Điều kiện 4: Nếu có D00504, D00488, D00507 trong favorite, ưu tiên "Hồ Chí Minh"
    final hasD00504 = favoriteDestinationIds.contains("D00504");
    final hasD00488 = favoriteDestinationIds.contains("D00488");
    final hasD00507 = favoriteDestinationIds.contains("D00507");
    print(
        '🔍 DEBUG: hasD00504 = $hasD00504, hasD00488 = $hasD00488, hasD00507 = $hasD00507');

    if (hasD00504 && hasD00488 && hasD00507) {
      print('🔍 DEBUG: Applying HCM sorting...');
      sortedList.sort((a, b) {
        try {
          final destA = destinationsViewModel.destinations.firstWhere(
            (dest) => dest.destinationName == a.placeName,
          );
          final destB = destinationsViewModel.destinations.firstWhere(
            (dest) => dest.destinationName == b.placeName,
          );

          final aIsHCM = destA.province == "Hồ Chí Minh";
          final bIsHCM = destB.province == "Hồ Chí Minh";

          print(
              '🔍 DEBUG: Comparing "${a.placeName}" (isHCM: $aIsHCM) vs "${b.placeName}" (isHCM: $bIsHCM)');

          if (aIsHCM && !bIsHCM) return -1;
          if (!aIsHCM && bIsHCM) return 1;
          return 0;
        } catch (e) {
          print('🔍 DEBUG: Error finding destination for HCM comparison: $e');
          return 0;
        }
      });
      print(
          '🔍 DEBUG: After HCM sorting: ${sortedList.map((e) => e.placeName).toList()}');
    }

    print(
        '🔍 DEBUG: Final sorted list: ${sortedList.map((e) => e.placeName).toList()}');
    return sortedList;
  }

  // Hàm lấy thông tin user preferences
  Future<Map<String, dynamic>> _getUserPreferences() async {
    try {
      final userService = UserService();
      final userId = await userService.getCurrentUserId();

      if (userId == null) {
        return {
          'favoriteDestinationIds': [],
          'hobbies': [],
        };
      }

      // Lấy thông tin user từ Firestore
      final userDoc =
          await FirebaseFirestore.instance.collection('USER').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return {
          'favoriteDestinationIds': userData['favoriteDestinationIds'] ?? [],
          'hobbies': userData['hobbies'] ?? [],
        };
      }

      return {
        'favoriteDestinationIds': [],
        'hobbies': [],
      };
    } catch (e) {
      print('Error getting user preferences: $e');
      return {
        'favoriteDestinationIds': [],
        'hobbies': [],
      };
    }
  }

  // Hàm load danh sách inspiration đã sắp xếp
  Future<void> _loadSortedInspirationList(
      List<HomeCardData> originalList) async {
    if (originalList.isEmpty) {
      setState(() {
        _sortedInspirationList = [];
        _isLoadingSortedInspiration = false;
      });
      return;
    }

    setState(() {
      _isLoadingSortedInspiration = true;
    });

    try {
      final sortedList = await _sortInspirationList(originalList);
      setState(() {
        _sortedInspirationList = sortedList;
        _isLoadingSortedInspiration = false;
      });
    } catch (e) {
      print('Error sorting inspiration list: $e');
      setState(() {
        _sortedInspirationList = originalList;
        _isLoadingSortedInspiration = false;
      });
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sử dụng Flexible để tránh overflow
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate(title),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5.h),
              Text(
                AppLocalizations.of(context).translate(subtitle),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasMore;

  const ProvinceSection({
    super.key,
    required this.selectedProvince,
    required this.provinces,
    required this.onProvinceSelected,
    required this.cardDataList,
    required this.onCardTap,
    required this.scrollController,
    required this.isLoading,
    required this.hasMore,
  });

  Future<bool> _precacheImages(
      List<HomeCardData> cardDataList, BuildContext context) async {
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
            AppLocalizations.of(context)
                .translate("Explore top spots by province"),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context)
                .translate("Discover places across provinces"),
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
                      scrollController: scrollController,
                      isLoading: isLoading,
                      hasMore: hasMore,
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
  final bool isLoading;
  final bool hasMore;

  const InspirationSection({
    super.key,
    required this.cardDataList,
    required this.onCardTap,
    required this.isLoading,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)
                    .translate("More travel inspiration"),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                AppLocalizations.of(context)
                    .translate("Extra highlights just for you"),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 161.w / 190.h,
        mainAxisSpacing: 10.h,
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

  Future<bool> _precacheImages(
      List<HomeCardData> cardDataList, BuildContext context) async {
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
