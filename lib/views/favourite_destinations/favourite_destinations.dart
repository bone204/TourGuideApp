import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/favourite_card.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:tourguideapp/widgets/restaurant_card.dart';
import '../../widgets/custom_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/widgets/hotel_card.dart';
import 'package:tourguideapp/views/service/hotel/hotel_detail_screen.dart';
import 'package:tourguideapp/views/service/restaurant/restaurant_detail_screen.dart';

class FavouriteDestinationsScreen extends StatefulWidget {
  const FavouriteDestinationsScreen({super.key});

  @override
  _FavouriteDestinationsState createState() => _FavouriteDestinationsState();
}

class _FavouriteDestinationsState extends State<FavouriteDestinationsScreen> {
  @override
  Widget build(BuildContext context) {
    final favouriteViewModel = Provider.of<FavouriteDestinationsViewModel>(context);

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
                          AppLocalizations.of(context).translate('Favourites'),
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
            _buildSearchBar(),
            SizedBox(height: 10.h),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 161.w / 190.h,
                  mainAxisSpacing: 20.h,
                  crossAxisSpacing: 0,
                ),
                itemCount: favouriteViewModel.favouriteDestinations.length + 
                          favouriteViewModel.favouriteHotels.length +
                          favouriteViewModel.favouriteRestaurants.length,
                itemBuilder: (context, index) {
                  if (index < favouriteViewModel.favouriteDestinations.length) {
                    // Build Destination Card
                    final destination = favouriteViewModel.favouriteDestinations[index];
                    return GestureDetector(
                      onTap: () {
                        final homeCardData = HomeCardData(
                          placeName: destination.destinationName,
                          imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : '',
                          description: destination.province,
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
                      child: FavouriteCard(
                        data: FavouriteCardData(
                          placeName: destination.destinationName,
                          imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : '',
                          description: destination.province,
                        ),
                      ),
                    );
                  } else if (index < favouriteViewModel.favouriteDestinations.length + 
                            favouriteViewModel.favouriteHotels.length) {
                    // Build Hotel Card using FavouriteCard
                    final hotelIndex = index - favouriteViewModel.favouriteDestinations.length;
                    final hotel = favouriteViewModel.favouriteHotels[hotelIndex];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelDetailScreen(
                              data: HotelCardData(
                                imageUrl: hotel.imageUrl,
                                hotelName: hotel.hotelName,
                                rating: hotel.rating,
                                pricePerDay: hotel.pricePerDay,
                                address: hotel.address,
                              ),
                            ),
                          ),
                        );
                      },
                      child: FavouriteCard(
                        data: FavouriteCardData(
                          placeName: hotel.hotelName,
                          imageUrl: hotel.imageUrl,
                          description: hotel.address,
                        ),
                      ),
                    );
                  } else {
                    // Build Restaurant Card
                    final restaurantIndex = index - favouriteViewModel.favouriteDestinations.length - 
                                          favouriteViewModel.favouriteHotels.length;
                    final restaurant = favouriteViewModel.favouriteRestaurants[restaurantIndex];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailScreen(
                              data: RestaurantCardData(
                                imageUrl: restaurant.imageUrl,
                                restaurantName: restaurant.restaurantName,
                                rating: restaurant.rating,
                                pricePerPerson: restaurant.pricePerPerson,
                                address: restaurant.address,
                              ),
                            ),
                          ),
                        );
                      },
                      child: FavouriteCard(
                        data: FavouriteCardData(
                          placeName: restaurant.restaurantName,
                          imageUrl: restaurant.imageUrl,
                          description: restaurant.address,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
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
