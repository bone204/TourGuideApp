import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/widgets/home_card.dart';
//import 'package:tourguideapp/widgets/restaurant_card.dart';
import '../../../widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
//import 'package:tourguideapp/widgets/hotel_card.dart';
//import 'package:tourguideapp/views/service/hotel/hotel_detail_screen.dart';
//import 'package:tourguideapp/views/service/restaurant/restaurant_detail_screen.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';

class FavouriteDestinationsScreen extends StatefulWidget {
  const FavouriteDestinationsScreen({super.key});

  @override
  _FavouriteDestinationsState createState() => _FavouriteDestinationsState();
}

class _FavouriteDestinationsState extends State<FavouriteDestinationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];

  String _normalizeString(String text) {
    var output = text.toLowerCase();
    var vietnameseMap = {
      'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ|Â|À|Á|Ạ|Ả|Ã|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ằ|Ắ|Ặ|Ẳ|Ẵ': 'a',
      'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ|È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ': 'e',
      'ì|í|ị|ỉ|ĩ|Ì|Í|Ị|Ỉ|Ĩ': 'i',
      'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ|Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ':
          'o',
      'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ|Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ': 'u',
      'ỳ|ý|ỵ|ỷ|ỹ|Ỳ|Ý|Ỵ|Ỷ|Ỹ': 'y',
      'đ|Đ': 'd'
    };

    vietnameseMap.forEach((key, value) {
      output = output.replaceAll(RegExp(key), value);
    });
    return output;
  }

  void _updateFilteredList(String query) {
    final favouriteViewModel =
        Provider.of<FavouriteDestinationsViewModel>(context, listen: false);

    setState(() {
      if (query.isEmpty) {
        _filteredItems = [
          ...favouriteViewModel.favouriteDestinations,
          ...favouriteViewModel.favouriteHotels,
          ...favouriteViewModel.favouriteRestaurants,
        ];
      } else {
        final normalizedQuery = _normalizeString(query);
        final queryWords = normalizedQuery
            .split(' ')
            .where((word) => word.isNotEmpty)
            .toList();

        // Lọc destinations
        final filteredDestinations =
            favouriteViewModel.favouriteDestinations.where((dest) {
          final normalizedName = _normalizeString(dest.destinationName);
          final normalizedProvince = _normalizeString(dest.province);

          return queryWords.every((word) {
            return normalizedName
                    .split(' ')
                    .any((nameWord) => nameWord.startsWith(word)) ||
                normalizedProvince
                    .split(' ')
                    .any((provinceWord) => provinceWord.startsWith(word));
          });
        }).toList();

        // Lọc hotels
        final filteredHotels =
            favouriteViewModel.favouriteHotels.where((hotel) {
          final normalizedName = _normalizeString(hotel.name);
          final normalizedAddress = _normalizeString(hotel.address);

          return queryWords.every((word) {
            return normalizedName
                    .split(' ')
                    .any((nameWord) => nameWord.startsWith(word)) ||
                normalizedAddress
                    .split(' ')
                    .any((addressWord) => addressWord.startsWith(word));
          });
        }).toList();

        // Lọc restaurants
        final filteredRestaurants =
            favouriteViewModel.favouriteRestaurants.where((rest) {
          final normalizedName = _normalizeString(rest.name);
          final normalizedAddress = _normalizeString(rest.address);

          return queryWords.every((word) {
            return normalizedName
                    .split(' ')
                    .any((nameWord) => nameWord.startsWith(word)) ||
                normalizedAddress
                    .split(' ')
                    .any((addressWord) => addressWord.startsWith(word));
          });
        }).toList();

        _filteredItems = [
          ...filteredDestinations,
          ...filteredHotels,
          ...filteredRestaurants,
        ];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _updateFilteredList('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                        AppLocalizations.of(context).translate('Favourites'),
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
          _buildSearchBar(),
          Expanded(
            child: Consumer<FavouriteDestinationsViewModel>(
              builder: (context, favouriteViewModel, child) {
                // Chỉ cập nhật _filteredItems nếu không có search query
                if (_searchController.text.isEmpty) {
                  _filteredItems = [
                    ...favouriteViewModel.favouriteDestinations,
                    ...favouriteViewModel.favouriteHotels,
                    ...favouriteViewModel.favouriteRestaurants,
                  ];
                }

                return GridView.builder(
                  padding: EdgeInsets.only(
                      top: 10.h, right: 20.w, left: 20.w, bottom: 20.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 161.w / 190.h,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                  ),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];

                    if (item is DestinationModel) {
                      final homeCardData = HomeCardData(
                        placeName: item.destinationName,
                        imageUrl: item.photo.isNotEmpty ? item.photo[0] : '',
                        description: item.province,
                        rating: 4.5,
                        favouriteTimes: item.favouriteTimes,
                      );

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DestinationDetailPage(
                                cardData: homeCardData,
                                destinationData: item,
                                isFavourite: true,
                                onFavouriteToggle: (isFavourite) {
                                  final viewModel = Provider.of<
                                          FavouriteDestinationsViewModel>(
                                      context,
                                      listen: false);
                                  viewModel.toggleFavourite(item);
                                  // Cập nhật lại danh sách đã lọc
                                  _updateFilteredList(_searchController.text);
                                },
                              ),
                            ),
                          );
                          // Cập nhật lại danh sách khi quay về
                          _updateFilteredList(_searchController.text);
                        },
                        child: FavouriteCard(
                          data: FavouriteCardData(
                            placeName: item.destinationName,
                            imageUrl:
                                item.photo.isNotEmpty ? item.photo[0] : '',
                            description: item.province,
                          ),
                        ),
                      );
                    } 
                    // else if (item is HotelCardData) {
                    //   return GestureDetector(
                    //     onTap: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) =>
                    //               HotelDetailScreen(data: item),
                    //         ),
                    //       );
                    //     },
                    //     child: FavouriteCard(
                    //       data: FavouriteCardData(
                    //         placeName: item.hotelName,
                    //         imageUrl: item.imageUrl,
                    //         description: item.address,
                    //       ),
                    //     ),
                    //   );
                    // } else if (item is RestaurantCardData) {
                    //   return GestureDetector(
                    //     onTap: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) =>
                    //               RestaurantDetailScreen(data: item),
                    //         ),
                    //       );
                    //     },
                    //     child: FavouriteCard(
                    //       data: FavouriteCardData(
                    //         placeName: item.restaurantName,
                    //         imageUrl: item.imageUrl,
                    //         description: item.address,
                    //       ),
                    //     ),
                    //   );
                    // }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: AppLocalizations.of(context).translate('Search'),
        onChanged: _updateFilteredList,
      ),
    );
  }
}
