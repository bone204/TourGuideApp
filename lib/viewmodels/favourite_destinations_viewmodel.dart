import 'package:flutter/material.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/models/hotel_model.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:tourguideapp/models/restaurant_model.dart';

class FavouriteDestinationsViewModel extends ChangeNotifier {
  List<DestinationModel> _favouriteDestinations = [];
  List<HotelModel> _favouriteHotels = [];
  List<RestaurantModel> _favouriteRestaurants = [];

  List<DestinationModel> get favouriteDestinations => _favouriteDestinations;
  List<HotelModel> get favouriteHotels => _favouriteHotels;
  List<RestaurantModel> get favouriteRestaurants => _favouriteRestaurants;

  List<HomeCardData> get favouriteCards => _favouriteDestinations.map((destination) {
    return HomeCardData(
      imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : '',
      placeName: destination.destinationName,
      description: destination.province,
      rating: 4.5,
    );
  }).toList();

  void toggleFavourite(DestinationModel destination) {
    if (_favouriteDestinations.any((d) => d.destinationId == destination.destinationId)) {
      _favouriteDestinations.removeWhere((d) => d.destinationId == destination.destinationId);
    } else {
      _favouriteDestinations.add(destination);
    }
    notifyListeners();
  }

  bool isFavourite(DestinationModel destination) {
    return _favouriteDestinations.any((d) => d.destinationId == destination.destinationId);
  }

  void toggleFavouriteHotel(HotelModel hotel) {
    if (_favouriteHotels.any((h) => h.hotelId == hotel.hotelId)) {
      _favouriteHotels.removeWhere((h) => h.hotelId == hotel.hotelId);
    } else {
      _favouriteHotels.add(hotel);
    }
    notifyListeners();
  }

  bool isHotelFavourite(HotelModel hotel) {
    return _favouriteHotels.any((h) => h.hotelId == hotel.hotelId);
  }

  void toggleFavouriteRestaurant(RestaurantModel restaurant) {
    if (_favouriteRestaurants.any((r) => r.restaurantId == restaurant.restaurantId)) {
      _favouriteRestaurants.removeWhere((r) => r.restaurantId == restaurant.restaurantId);
    } else {
      _favouriteRestaurants.add(restaurant);
    }
    notifyListeners();
  }

  bool isRestaurantFavourite(RestaurantModel restaurant) {
    return _favouriteRestaurants.any((r) => r.restaurantId == restaurant.restaurantId);
  }
}
