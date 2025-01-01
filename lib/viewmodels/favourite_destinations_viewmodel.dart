import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/models/hotel_model.dart';
import 'package:tourguideapp/models/restaurant_model.dart';
import 'dart:math' as math;

class FavouriteDestinationsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<DestinationModel> _favouriteDestinations = [];
  List<HotelModel> _favouriteHotels = [];
  List<RestaurantModel> _favouriteRestaurants = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<DestinationModel> get favouriteDestinations => _favouriteDestinations;
  List<HotelModel> get favouriteHotels => _favouriteHotels;
  List<RestaurantModel> get favouriteRestaurants => _favouriteRestaurants;

  FavouriteDestinationsViewModel() {
    initAuthListener();
    loadFavorites();
  }

  void initAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        clearData();
      } else {
        loadFavorites();
      }
    });
  }

  void clearData() {
    _favouriteDestinations = [];
    _favouriteHotels = [];
    _favouriteRestaurants = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        clearData();
        return;
      }

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final favoriteIds = List<String>.from(userData['favoriteDestinationIds'] ?? []);
      final favoriteHotelIds = List<String>.from(userData['favoriteHotelIds'] ?? []);
      final favoriteRestaurantIds = List<String>.from(userData['favoriteRestaurantIds'] ?? []);

      // Load destinations
      _favouriteDestinations = await Future.wait(
        favoriteIds.map((id) async {
          final doc = await _firestore.collection('DESTINATION').doc(id).get();
          return DestinationModel.fromMap(doc.data() ?? {});
        })
      );

      // Load hotels
      _favouriteHotels = await Future.wait(
        favoriteHotelIds.map((id) async {
          final doc = await _firestore.collection('HOTEL').doc(id).get();
          return HotelModel.fromMap(doc.data() ?? {});
        })
      );

      // Load restaurants
      _favouriteRestaurants = await Future.wait(
        favoriteRestaurantIds.map((id) async {
          final doc = await _firestore.collection('RESTAURANT').doc(id).get();
          return RestaurantModel.fromMap(doc.data() ?? {});
        })
      );

    } catch (e) {
      print('Error loading favorites: $e');
      clearData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavourite(DestinationModel destination) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('USER').doc(user.uid);
    final destinationRef = _firestore.collection('DESTINATION').doc(destination.destinationId);
    
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final destinationDoc = await transaction.get(destinationRef);
        
        List<String> favoriteIds = List<String>.from(userDoc.data()?['favoriteDestinationIds'] ?? []);
        int currentFavourite = destinationDoc.data()?['favouriteTimes'] ?? 0;
        
        if (favoriteIds.contains(destination.destinationId)) {
          favoriteIds.remove(destination.destinationId);
          _favouriteDestinations.removeWhere((d) => d.destinationId == destination.destinationId);
          currentFavourite = math.max(0, currentFavourite - 1);
        } else {
          favoriteIds.add(destination.destinationId);
          _favouriteDestinations.add(destination.copyWith(favourite: currentFavourite + 1));
          currentFavourite += 1;
        }
        
        transaction.update(userRef, {'favoriteDestinationIds': favoriteIds});
        transaction.update(destinationRef, {'favouriteTimes': currentFavourite});
      });
      
      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
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
