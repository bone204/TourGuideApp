// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/views/admin/admin_screen.dart';
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
import 'package:tourguideapp/services/notification_service.dart';
import 'package:tourguideapp/services/user_service.dart';

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
  double? _initX, _initY;

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _popularScrollController.addListener(_onPopularScroll);
    _provinceScrollController.addListener(_onProvinceScroll);
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    try {
      await _notificationService.initialize();
      // Lấy user ID từ UserService
      _currentUserId = await _userService.getCurrentUserId();
      print('Debug: Initialized notification service, User ID: $_currentUserId');
      
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
        final count = await _notificationService.getUnreadNotificationCount(_currentUserId!);
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
    // Logic mới: khi kéo tới đáy trang thì load thêm cho Inspiration
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final total = Provider.of<DestinationsViewModel>(context, listen: false).horizontalCardsData.length;
    if (currentScroll >= maxScroll - 100 && !_isLoadingInspiration && _visibleInspiration < total) {
      setState(() { _isLoadingInspiration = true; });
      Future.delayed(const Duration(milliseconds: 800)).then((_) {
        if (mounted) {
          setState(() {
            _visibleInspiration = (_visibleInspiration + _itemsPerPage).clamp(0, total);
            _isLoadingInspiration = false;
          });
        }
      });
    }
  }

  void _onPopularScroll() async {
    if (_popularScrollController.position.pixels >= _popularScrollController.position.maxScrollExtent - 100 && !_isLoadingPopular) {
      final total = Provider.of<DestinationsViewModel>(context, listen: false).horizontalCardsData.length;
      if (_visiblePopular < total) {
        setState(() { _isLoadingPopular = true; });
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _visiblePopular = (_visiblePopular + _itemsPerPage).clamp(0, total);
          _isLoadingPopular = false;
        });
      }
    }
  }
  void _onProvinceScroll() async {
    final total = _selectedProvince == AppLocalizations.of(context).translate('All')
        ? Provider.of<DestinationsViewModel>(context, listen: false).horizontalCardsData.length
        : Provider.of<DestinationsViewModel>(context, listen: false).getDestinationsByProvince(_selectedProvince).length;
    if (_provinceScrollController.position.pixels >= _provinceScrollController.position.maxScrollExtent - 100 && !_isLoadingProvince) {
      if (_visibleProvince < total) {
        setState(() { _isLoadingProvince = true; });
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _visibleProvince = (_visibleProvince + _itemsPerPage).clamp(0, total);
          _isLoadingProvince = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);

    // Lấy danh sách phân trang cho từng section
    List<HomeCardData> popularList = destinationsViewModel.horizontalCardsData;
    List<HomeCardData> pagedPopularList = popularList.take(_visiblePopular).toList();

    List<HomeCardData> provinceList = _selectedProvince == AppLocalizations.of(context).translate('All')
        ? destinationsViewModel.horizontalCardsData
        : destinationsViewModel.getDestinationsByProvince(_selectedProvince);
    List<HomeCardData> pagedProvinceList = provinceList.take(_visibleProvince).toList();

    List<HomeCardData> inspirationList = destinationsViewModel.horizontalCardsData;
    List<HomeCardData> pagedInspirationList = inspirationList.take(_visibleInspiration).toList();

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
                    pagedPopularList,
                    scrollController: _popularScrollController,
                    isLoading: _isLoadingPopular,
                    hasMore: _visiblePopular < popularList.length,
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
                  scrollController: _provinceScrollController,
                  isLoading: _isLoadingProvince,
                  hasMore: _visibleProvince < provinceList.length,
                ),
                SizedBox(height: 32.h),
                // Inspiration Section
                InspirationSection(
                  cardDataList: pagedInspirationList,
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
                  isLoading: _isLoadingInspiration,
                  hasMore: _visibleInspiration < inspirationList.length,
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
                      // Notification button with badge
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_currentUserId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationScreen(
                                      userId: _currentUserId!,
                                    ),
                                  ),
                                ).then((_) {
                                  // Reload notification count when returning from notification screen
                                  _loadUnreadNotificationCount();
                                });
                              }
                            },
                            child: Icon(
                              Icons.notifications_none,
                              color: AppColors.white,
                              size: 28.sp,
                            ),
                          ),
                          if (_unreadNotificationCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 20.w,
                                  minHeight: 20.h,
                                ),
                                child: Text(
                                  _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminScreen(),
                            ),
                          );
                        },
                        child: Icon(Icons.payment, size: 28.sp, color: AppColors.white)
                      ),
                      SizedBox(width: 12.w),
                      // Test notification button
                      GestureDetector(
                        onTap: () async {
                          try {
                            if (_currentUserId != null) {
                              await _notificationService.sendNotificationToUser(
                                userId: _currentUserId!,
                                title: 'Test Notification',
                                body: 'This is a test notification to check if the system works!',
                                serviceType: 'test',
                                serviceId: 'test_001',
                                serviceName: 'Test Service',
                                additionalData: {'test': true},
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Test notification sent!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Reload notification count
                              _loadUnreadNotificationCount();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No user ID found!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Test notification failed: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Icon(Icons.bug_report, size: 28.sp, color: AppColors.white)
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
                _initX = details.globalPosition.dx;
                _initY = details.globalPosition.dy;
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
                child: SizedBox(width: 300.w, height: 300.h, child: Image.asset('assets/img/floating.gif')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeadline(BuildContext context, String title, String subtitle, List<HomeCardData> cardDataList, {ScrollController? scrollController, bool isLoading = false, bool hasMore = false}) {
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
                    scrollController: scrollController,
                    isLoading: isLoading,
                    hasMore: hasMore,
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
