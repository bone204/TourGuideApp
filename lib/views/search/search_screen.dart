import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/widgets/home_card.dart';

class SearchScreen extends StatefulWidget {
  final String initialHint;

  const SearchScreen({
    super.key,
    required this.initialHint,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HomeCardData> _searchResults = [];

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

  void _onSearchChanged(String query) {
    final destinationsViewModel =
        Provider.of<DestinationsViewModel>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _searchResults = destinationsViewModel.horizontalCardsData;
      });
    } else {
      final normalizedQuery = _normalizeString(query);
      final queryWords =
          normalizedQuery.split(' ').where((word) => word.isNotEmpty).toList();

      setState(() {
        _searchResults =
            destinationsViewModel.horizontalCardsData.where((card) {
          final normalizedName = _normalizeString(card.placeName);
          final normalizedDescription = _normalizeString(card.description);

          return queryWords.every((word) {
            return normalizedName.contains(word) ||
                normalizedDescription.contains(word);
          });
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final destinationsViewModel =
        Provider.of<DestinationsViewModel>(context, listen: false);
    setState(() {
      _searchResults = destinationsViewModel.horizontalCardsData;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primaryColor,
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.grey,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.initialHint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14.sp,
                ),
              ),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14.sp,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favouriteViewModel =
        Provider.of<FavouriteDestinationsViewModel>(context);
    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Row(
                children: [
                  CustomIconButton(
                    icon: Icons.chevron_left,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 20.w),
                      child: _buildSearchBar(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'Không tìm thấy kết quả',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 16.sp,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(10.w, 0.h, 10.w, 20.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 161.w / 190.h,
                        mainAxisSpacing: 20.h,
                        crossAxisSpacing: 10.w,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final cardData = _searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            final destination =
                                destinationsViewModel.destinations.firstWhere(
                              (dest) =>
                                  dest.destinationName == cardData.placeName,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DestinationDetailPage(
                                  cardData: cardData,
                                  destinationData: destination,
                                  isFavourite: favouriteViewModel
                                      .isFavourite(destination),
                                  onFavouriteToggle: (isFavourite) {
                                    favouriteViewModel
                                        .toggleFavourite(destination);
                                  },
                                ),
                              ),
                            );
                          },
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
            ),
          ],
        ),
      ),
    );
  }
}
