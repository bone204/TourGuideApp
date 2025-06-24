import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/category_selector.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/core/services/cooperation_service.dart';
import 'package:tourguideapp/models/cooperation_model.dart';
import 'package:tourguideapp/widgets/shimmer_cards.dart';
import 'dart:math';

class EateryScreen extends StatefulWidget {
  @override
  State<EateryScreen> createState() => _EateryScreenState();
}

class _EateryScreenState extends State<EateryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedProvince = 'All';
  List<HomeCardData> _filteredEateries = [];
  List<String> _provinces = ['All'];
  bool _isLoading = true;
  bool _isLoadingData = false;
  final CooperationService _cooperationService = CooperationService();
  List<HomeCardData> _allEateries = [];
  String _sortBy = 'rating'; // 'rating' hoặc 'name'
  String _selectedPriceLevel = 'All'; // 'All', '<500k', '500k-1tr', '>1tr'

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    _loadEateryData();
  }

  Future<void> _loadEateryData() async {
    setState(() => _isLoadingData = true);
    try {
      List<CooperationModel> eateryCooperations;

      // Lọc theo tỉnh nếu không phải "All"
      if (_selectedProvince != 'All') {
        eateryCooperations =
            await _cooperationService.getEateriesByProvince(_selectedProvince);
      } else {
        // Lấy tất cả eatery từ COOPERATION
        final cooperations = await _cooperationService.getAllCooperations();
        eateryCooperations =
            cooperations.where((coop) => coop.type == 'eatery').toList();
      }

      // Thêm priceLevel ngẫu nhiên cho các eatery
      final priceLevels = ['<500k', '500k-1tr', '>1tr'];
      final random = Random();

      // Chuyển đổi thành HomeCardData
      _allEateries = eateryCooperations.map((coop) {
        // Gán priceLevel ngẫu nhiên
        final randomPriceLevel =
            priceLevels[random.nextInt(priceLevels.length)];
        final coopWithPrice = coop.copyWith(priceLevel: randomPriceLevel);

        return HomeCardData(
          imageUrl: coopWithPrice.photo.isNotEmpty ? coopWithPrice.photo : '',
          placeName: coopWithPrice.name,
          description: coopWithPrice.province,
          rating: coopWithPrice.averageRating,
          favouriteTimes: coopWithPrice.bookingTimes,
          userRatingsTotal: 0,
          priceLevel: coopWithPrice.priceLevel,
        );
      }).toList();

      // Sắp xếp theo rating cao đến thấp (mặc định)
      _sortEateries();
      _filterEateries(_searchController.text);
    } catch (e) {
      print('Error loading eatery data: $e');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  void _sortEateries() {
    if (_sortBy == 'rating') {
      _allEateries.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'name') {
      _allEateries.sort((a, b) => a.placeName.compareTo(b.placeName));
    }
  }

  Future<void> _fetchProvinces() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('PROVINCE').get();
      final provinceNames =
          snapshot.docs.map((doc) => doc['provinceName'] as String).toList();
      setState(() {
        _provinces = ['All', ...provinceNames];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching provinces: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterEateries(String query) {
    setState(() {
      if (query.isEmpty && _selectedPriceLevel == 'All') {
        _filteredEateries = List.from(_allEateries);
      } else {
        _filteredEateries = _allEateries.where((eatery) {
          final matchesQuery = query.isEmpty ||
              eatery.placeName.toLowerCase().contains(query.toLowerCase()) ||
              eatery.description.toLowerCase().contains(query.toLowerCase());

          final matchesPriceLevel = _selectedPriceLevel == 'All' ||
              eatery.priceLevel == _selectedPriceLevel;

          return matchesQuery && matchesPriceLevel;
        }).toList();
      }
    });
  }

  void _onPriceLevelChanged(String priceLevel) {
    setState(() {
      _selectedPriceLevel = priceLevel;
      _filterEateries(_searchController.text);
    });
  }

  void _onProvinceChanged(String province) {
    setState(() {
      _selectedProvince = province;
    });
    _loadEateryData(); // Reload data khi thay đổi tỉnh
  }

  DestinationModel _convertToDestinationModel(HomeCardData eateryData) {
    return DestinationModel(
      destinationId: 'eatery-${eateryData.placeName}',
      destinationName: eateryData.placeName,
      province: eateryData.description,
      specificAddress: eateryData.description,
      photo: [eateryData.imageUrl],
      video: [],
      createdDate: DateTime.now().toString(),
      descriptionViet: '''
${eateryData.placeName} là một địa điểm ẩm thực nổi tiếng.

Địa chỉ: ${eateryData.description}
Đánh giá: ${eateryData.rating}/5.0
Số lượt yêu thích: ${eateryData.favouriteTimes}
    ''',
      descriptionEng: '''
${eateryData.placeName} is a famous restaurant.

Address: ${eateryData.description}
Rating: ${eateryData.rating}/5.0
Favourite times: ${eateryData.favouriteTimes}
    ''',
      latitude: 0.0,
      longitude: 0.0,
      categories: ['eatery'],
    );
  }

  Widget _buildSortButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context).translate('Price Range:'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () => _onPriceLevelChanged('All'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _selectedPriceLevel == 'All'
                    ? Colors.blue
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                AppLocalizations.of(context).translate('All'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _selectedPriceLevel == 'All'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _onPriceLevelChanged('<500k'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _selectedPriceLevel == '<500k'
                    ? Colors.blue
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                '<500k',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _selectedPriceLevel == '<500k'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _onPriceLevelChanged('500k-1tr'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _selectedPriceLevel == '500k-1tr'
                    ? Colors.blue
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                '500k-1tr',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _selectedPriceLevel == '500k-1tr'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _onPriceLevelChanged('>1tr'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _selectedPriceLevel == '>1tr'
                    ? Colors.blue
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                '>1tr',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _selectedPriceLevel == '>1tr'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding:
          EdgeInsets.only(top: 10.w, right: 20.h, left: 20.h, bottom: 20.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 161.w / 190.h,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerFavoriteCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        AppLocalizations.of(context).translate('No eatery found'),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
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
                        AppLocalizations.of(context).translate("Find Eatery"),
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
      body: Column(
        children: [
          SizedBox(height: 10.h),
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: AppLocalizations.of(context).translate('Search'),
              onChanged: _filterEateries,
            ),
          ),
          SizedBox(height: 10.h),
          // Province Selector
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CategorySelector(
                    selectedCategory: _selectedProvince,
                    categories: _provinces,
                    onCategorySelected: _onProvinceChanged,
                  ),
                ),
          SizedBox(height: 20.h),
          // Sort Button
          _buildSortButton(),
          SizedBox(height: 20.h),
          // Eatery Grid
          Expanded(
            child: _isLoadingData
                ? _buildShimmerGrid()
                : _filteredEateries.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: EdgeInsets.only(
                            top: 10.w, right: 20.h, left: 20.h, bottom: 20.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 161.w / 190.h,
                          mainAxisSpacing: 10.h,
                          crossAxisSpacing: 10.w,
                        ),
                        itemCount: _filteredEateries.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Tạo HomeCardData từ dữ liệu
                              final eateryData = _filteredEateries[index];

                              // Chuyển đổi sang DestinationModel
                              final destinationData =
                                  _convertToDestinationModel(eateryData);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DestinationDetailPage(
                                    cardData: eateryData,
                                    destinationData: destinationData,
                                    isFavourite: false,
                                    onFavouriteToggle: (isFavourite) {
                                      // Xử lý khi toggle favourite
                                    },
                                  ),
                                ),
                              );
                            },
                            child: FavouriteCard(
                              data: FavouriteCardData(
                                placeName: _filteredEateries[index].placeName,
                                imageUrl: _filteredEateries[index].imageUrl,
                                description:
                                    _filteredEateries[index].description,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
