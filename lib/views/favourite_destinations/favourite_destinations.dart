import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/widgets/favourite_card_list.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import '../../widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';

class FavouriteDestinationsScreen extends StatefulWidget {
  const FavouriteDestinationsScreen({super.key});

  @override
  _FavouriteDestinationsState createState() => _FavouriteDestinationsState();
}

class _FavouriteDestinationsState extends State<FavouriteDestinationsScreen> {
  @override
  Widget build(BuildContext context) {
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);

    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
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
                          AppLocalizations.of(context).translate('Favourite Destinations'),
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
        body: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Column(
            children: [
              _buildSearchBar(),
              SizedBox(height: 10.h),
              FavouriteCardListView(
                cardDataList: favouriteViewModel.favouriteDestinations.map((destination) {
                  return FavouriteCardData(
                    placeName: destination.destinationName,
                    imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : '',
                    description: destination.province,
                  );
                }).toList(),
                onCardTap: (favouriteCardData) {
                  final destination = favouriteViewModel.favouriteDestinations.firstWhere(
                    (d) => d.destinationName == favouriteCardData.placeName,
                  );

                  final homeCardData = HomeCardData(
                    placeName: favouriteCardData.placeName,
                    imageUrl: favouriteCardData.imageUrl,
                    description: favouriteCardData.description,
                    rating: 4.5,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DestinationDetailPage(
                        cardData: homeCardData,
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
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.h, horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('Search'),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
