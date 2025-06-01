import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/widgets/home_card.dart';

class ViewAllDestinationsScreen extends StatefulWidget {
  final String sectionTitle;
  final List<HomeCardData> cardDataList;

  const ViewAllDestinationsScreen({
    super.key,
    required this.sectionTitle,
    required this.cardDataList,
  });

  @override
  _ViewAllDestinationsScreenState createState() => _ViewAllDestinationsScreenState();
}

class _ViewAllDestinationsScreenState extends State<ViewAllDestinationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HomeCardData> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = widget.cardDataList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeString(String text) {
    var output = text.toLowerCase();
    var vietnameseMap = {
      'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ|Â|À|Á|Ạ|Ả|Ã|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ằ|Ắ|Ặ|Ẳ|Ẵ': 'a',
      'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ|È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ': 'e',
      'ì|í|ị|ỉ|ĩ|Ì|Í|Ị|Ỉ|Ĩ': 'i',
      'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ|Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ': 'o',
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
    setState(() {
      if (query.isEmpty) {
        _filteredList = widget.cardDataList;
      } else {
        final normalizedQuery = _normalizeString(query);
        final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty).toList();

        _filteredList = widget.cardDataList.where((card) {
          final normalizedName = _normalizeString(card.placeName);
          final normalizedDescription = _normalizeString(card.description);
          
          return queryWords.every((word) {
            return normalizedName.split(' ').any((nameWord) => nameWord.startsWith(word)) ||
                   normalizedDescription.split(' ').any((descWord) => descWord.startsWith(word));
          });
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: CustomAppBar(
          title: widget.sectionTitle,
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(top: 10.h, right: 10.w, left: 10.w, bottom: 20.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 161.w / 185.h,
                mainAxisSpacing: 20.h,
                crossAxisSpacing: 0,
              ),
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final cardData = _filteredList[index];
                final destination = destinationsViewModel.destinations.firstWhere(
                  (dest) => dest.destinationName == cardData.placeName,
                );
                return GestureDetector(
                  onTap: () {
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
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: AppLocalizations.of(context).translate('Search'),
        onChanged: _onSearchChanged,
      ),
    );
  }
} 