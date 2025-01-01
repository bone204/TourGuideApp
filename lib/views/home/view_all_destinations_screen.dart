import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';
import 'package:tourguideapp/widgets/custom_search_bar.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/widgets/home_card.dart';

class ViewAllDestinationsScreen extends StatelessWidget {
  final String sectionTitle;
  final List<HomeCardData> cardDataList;

  const ViewAllDestinationsScreen({
    super.key,
    required this.sectionTitle,
    required this.cardDataList,
  });

  @override
  Widget build(BuildContext context) {
    final destinationsViewModel = Provider.of<DestinationsViewModel>(context);
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);

    return SafeArea(
      child: Scaffold(
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
                          AppLocalizations.of(context).translate(sectionTitle),
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
            SizedBox(height: 20.h),
            _buildSearchBar(context),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.only(top: 10.h, right: 10.w, left: 10.w, bottom: 20.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 161.w / 190.h,
                  mainAxisSpacing: 20.h,
                  crossAxisSpacing: 0,
                ),
                itemCount: cardDataList.length,
                itemBuilder: (context, index) {
                  final cardData = cardDataList[index];
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
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: CustomSearchBar(
        controller: TextEditingController(),
        hintText: AppLocalizations.of(context).translate('Search'),
        onChanged: (value) {
          // Add search functionality here if needed
        },
      ),
    );
  }
} 