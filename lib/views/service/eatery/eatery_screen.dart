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
import 'package:tourguideapp/models/eatery_model.dart';

class EateryScreen extends StatefulWidget {
  @override
  State<EateryScreen> createState() => _EateryScreenState();
}

class _EateryScreenState extends State<EateryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedProvince = 'All';
  List<FavouriteCardData> _filteredEateries = [];
  List<String> _provinces = ['All'];
  bool _isLoading = true;

  // Fake data cho danh sách eatery
  final List<FavouriteCardData> _eateries = [
    FavouriteCardData(
      imageUrl: 'https://vcdn1-dulich.vnecdn.net/2022/06/03/cauvang-1654247842-9403-1654247849.jpg?w=1200&h=0&q=100&dpr=1&fit=crop&s=Swd6JjpStebEzT6WARcoOA',
      placeName: 'Quán Ăn Ngon',
      description: 'Hà Nội',
    ),
    FavouriteCardData(
      imageUrl: 'https://vcdn1-dulich.vnecdn.net/2022/06/03/cauvang-1654247842-9403-1654247849.jpg?w=1200&h=0&q=100&dpr=1&fit=crop&s=Swd6JjpStebEzT6WARcoOA',
      placeName: 'Nhà Hàng Biển Đông',
      description: 'Hồ Chí Minh',
    ),
    FavouriteCardData(
      imageUrl: 'https://vcdn1-dulich.vnecdn.net/2022/06/03/cauvang-1654247842-9403-1654247849.jpg?w=1200&h=0&q=100&dpr=1&fit=crop&s=Swd6JjpStebEzT6WARcoOA',
      placeName: 'Phở 24',
      description: 'Đà Nẵng',
    ),
    FavouriteCardData(
      imageUrl: 'https://vcdn1-dulich.vnecdn.net/2022/06/03/cauvang-1654247842-9403-1654247849.jpg?w=1200&h=0&q=100&dpr=1&fit=crop&s=Swd6JjpStebEzT6WARcoOA',
      placeName: 'Bún Bò Huế Nam Giao',
      description: 'Thừa Thiên Huế',
    ),
    FavouriteCardData(
      imageUrl: 'https://vcdn1-dulich.vnecdn.net/2022/06/03/cauvang-1654247842-9403-1654247849.jpg?w=1200&h=0&q=100&dpr=1&fit=crop&s=Swd6JjpStebEzT6WARcoOA',
      placeName: 'Cơm Tấm Sài Gòn',
      description: 'Hồ Chí Minh',
    ),
    // Thêm nhiều nhà hàng khác...
  ];

  @override
  void initState() {
    super.initState();
    _filteredEateries = _eateries;
    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('PROVINCE').get();
      final provinceNames = snapshot.docs.map((doc) => doc['provinceName'] as String).toList();
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
      if (query.isEmpty && _selectedProvince == 'All') {
        _filteredEateries = _eateries;
      } else {
        _filteredEateries = _eateries.where((eatery) {
          final matchesQuery = query.isEmpty ||
              eatery.placeName.toLowerCase().contains(query.toLowerCase()) ||
              eatery.description.toLowerCase().contains(query.toLowerCase());
          
          final matchesProvince = _selectedProvince == 'All' ||
              eatery.description == _selectedProvince;
          
          return matchesQuery && matchesProvince;
        }).toList();
      }
    });
  }

  HomeCardData _convertToHomeCardData(FavouriteCardData eateryData) {
    return HomeCardData(
      placeName: eateryData.placeName,
      imageUrl: eateryData.imageUrl,
      description: eateryData.description,
      rating: 4.5,
      favouriteTimes: 0,
    );
  }

  DestinationModel _convertToDestinationModel(EateryModel eatery) {
    return DestinationModel(
      destinationId: eatery.eateryId,
      destinationName: eatery.eateryName,
      province: eatery.province,
      specificAddress: eatery.address,
      district: '',
      photo: eatery.photo,
      video: [],
      createdDate: DateTime.now().toString(),
      descriptionViet: '''
${eatery.descriptionViet}

Địa chỉ: ${eatery.address}
Số điện thoại: ${eatery.phoneNumber}
Giờ mở cửa: ${eatery.openTime} - ${eatery.closeTime}
    ''',
      descriptionEng: '''
${eatery.descriptionEng}

Address: ${eatery.address}
Phone: ${eatery.phoneNumber}
Opening hours: ${eatery.openTime} - ${eatery.closeTime}
    ''',
      latitude: eatery.latitude,
      longitude: eatery.longitude,
      categories: ['eatery'],
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
                          fontWeight: FontWeight.bold,
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
                    onCategorySelected: (province) {
                      setState(() {
                        _selectedProvince = province;
                        _filterEateries(_searchController.text);
                      });
                    },
                  ),
                ),
          SizedBox(height: 20.h),
          // Eatery Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(top: 10.w, right: 10.h, left: 10.h, bottom: 20.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 161.w / 190.h,
                mainAxisSpacing: 20.h,
                crossAxisSpacing: 0,
              ),
              itemCount: _filteredEateries.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Tạo EateryModel từ dữ liệu
                    final eatery = EateryModel(
                      eateryId: 'eatery-${index}',
                      eateryName: _filteredEateries[index].placeName,
                      address: _filteredEateries[index].description,
                      province: _filteredEateries[index].description,
                      photo: [_filteredEateries[index].imageUrl],
                      descriptionViet: 'Nhà hàng ${_filteredEateries[index].placeName} là một địa điểm ẩm thực nổi tiếng tại ${_filteredEateries[index].description}...',
                      descriptionEng: '${_filteredEateries[index].placeName} is a famous restaurant in ${_filteredEateries[index].description}...',
                      rating: 4.5,
                      phoneNumber: '0123456789',
                      openTime: '07:00',
                      closeTime: '22:00',
                    );

                    // Chuyển đổi sang DestinationModel
                    final destinationData = _convertToDestinationModel(eatery);
                    final homeCardData = HomeCardData(
                      placeName: eatery.eateryName,
                      imageUrl: eatery.photo[0],
                      description: eatery.province,
                      rating: eatery.rating,
                      favouriteTimes: 0,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DestinationDetailPage(
                          cardData: homeCardData,
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
                    data: _filteredEateries[index],
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
