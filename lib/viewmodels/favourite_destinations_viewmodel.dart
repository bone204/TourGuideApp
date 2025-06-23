import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourguideapp/models/destination_model.dart';
//import 'package:tourguideapp/models/room_model.dart';
//import 'package:tourguideapp/models/table_model.dart';
import 'dart:math' as math;
import 'package:tourguideapp/models/cooperation_model.dart';

class FavouriteDestinationsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DestinationModel> _favouriteDestinations = [];
  List<CooperationModel> _favouriteHotels = [];
  List<CooperationModel> _favouriteRestaurants = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<DestinationModel> get favouriteDestinations => _favouriteDestinations;
  List<CooperationModel> get favouriteHotels => _favouriteHotels;
  List<CooperationModel> get favouriteRestaurants => _favouriteRestaurants;

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
      final favoriteIds =
          List<String>.from(userData['favoriteDestinationIds'] ?? []);
      final favoriteHotelIds =
          List<String>.from(userData['favoriteHotelIds'] ?? []);
      final favoriteRestaurantIds =
          List<String>.from(userData['favoriteRestaurantIds'] ?? []);

      // Load destinations
      _favouriteDestinations = await Future.wait(favoriteIds.map((id) async {
        final doc = await _firestore.collection('DESTINATION').doc(id).get();
        return DestinationModel.fromMap(doc.data() ?? {});
      }));

      // Load hotels
      final hotelFutures = favoriteHotelIds.map((id) async {
        final doc = await _firestore.collection('COOPERATION').doc(id).get();
        final data = doc.data() ?? {};
        if (data['type'] == 'hotel') {
          return CooperationModel(
            cooperationId: data['cooperationId'] ?? '',
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            numberOfObjects: data['numberOfObjects'] ?? 0,
            numberOfObjectTypes: data['numberOfObjectTypes'] ?? 0,
            latitude: (data['latitude'] ?? 0.0).toDouble(),
            longitude: (data['longitude'] ?? 0.0).toDouble(),
            bossName: data['bossName'] ?? '',
            bossPhone: data['bossPhone'] ?? '',
            bossEmail: data['bossEmail'] ?? '',
            address: data['address'] ?? '',
            district: data['district'] ?? '',
            city: data['city'] ?? '',
            province: data['province'] ?? '',
            photo: data['photo'] ?? '',
            extension: data['extension'] ?? '',
            introduction: data['introduction'] ?? '',
            contractDate: data['contractDate'] ?? '',
            contractTerm: data['contractTerm'] ?? '',
            bankAccountNumber: data['bankAccountNumber'] ?? '',
            bankAccountName: data['bankAccountName'] ?? '',
            bankName: data['bankName'] ?? '',
            bookingTimes: data['bookingTimes'] ?? 0,
            revenue: (data['revenue'] ?? 0.0).toDouble(),
            averageRating: (data['averageRating'] ?? 0.0).toDouble(),
            priceLevel: (data['priceLevel'] ?? 0).toInt(),
          );
        }
        return null;
      });
      final hotelResults = await Future.wait(hotelFutures);
      _favouriteHotels = hotelResults
          .whereType<CooperationModel>()
          .where((h) => h.type == 'hotel')
          .toList();

      // Load restaurants
      final restaurantFutures = favoriteRestaurantIds.map((id) async {
        final doc = await _firestore.collection('COOPERATION').doc(id).get();
        final data = doc.data() ?? {};
        if (data['type'] == 'restaurant') {
          return CooperationModel(
            cooperationId: data['cooperationId'] ?? '',
            name: data['name'] ?? '',
            type: data['type'] ?? '',
            numberOfObjects: data['numberOfObjects'] ?? 0,
            numberOfObjectTypes: data['numberOfObjectTypes'] ?? 0,
            latitude: (data['latitude'] ?? 0.0).toDouble(),
            longitude: (data['longitude'] ?? 0.0).toDouble(),
            bossName: data['bossName'] ?? '',
            bossPhone: data['bossPhone'] ?? '',
            bossEmail: data['bossEmail'] ?? '',
            address: data['address'] ?? '',
            district: data['district'] ?? '',
            city: data['city'] ?? '',
            province: data['province'] ?? '',
            photo: data['photo'] ?? '',
            extension: data['extension'] ?? '',
            introduction: data['introduction'] ?? '',
            contractDate: data['contractDate'] ?? '',
            contractTerm: data['contractTerm'] ?? '',
            bankAccountNumber: data['bankAccountNumber'] ?? '',
            bankAccountName: data['bankAccountName'] ?? '',
            bankName: data['bankName'] ?? '',
            bookingTimes: data['bookingTimes'] ?? 0,
            revenue: (data['revenue'] ?? 0.0).toDouble(),
            averageRating: (data['averageRating'] ?? 0.0).toDouble(),
            priceLevel: (data['priceLevel'] ?? 0).toInt(),
          );
        }
        return null;
      });
      final restaurantResults = await Future.wait(restaurantFutures);
      _favouriteRestaurants = restaurantResults
          .whereType<CooperationModel>()
          .where((r) => r.type == 'restaurant')
          .toList();
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
    final destinationRef =
        _firestore.collection('DESTINATION').doc(destination.destinationId);

    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final destinationDoc = await transaction.get(destinationRef);

        List<String> favoriteIds =
            List<String>.from(userDoc.data()?['favoriteDestinationIds'] ?? []);
        int currentFavourite = destinationDoc.data()?['favouriteTimes'] ?? 0;

        if (favoriteIds.contains(destination.destinationId)) {
          favoriteIds.remove(destination.destinationId);
          _favouriteDestinations
              .removeWhere((d) => d.destinationId == destination.destinationId);
          currentFavourite = math.max(0, currentFavourite - 1);
        } else {
          favoriteIds.add(destination.destinationId);
          _favouriteDestinations
              .add(destination.copyWith(favourite: currentFavourite + 1));
          currentFavourite += 1;
        }

        transaction.update(userRef, {'favoriteDestinationIds': favoriteIds});
        transaction
            .update(destinationRef, {'favouriteTimes': currentFavourite});
      });

      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  bool isFavourite(DestinationModel destination) {
    return _favouriteDestinations
        .any((d) => d.destinationId == destination.destinationId);
  }

  void toggleFavouriteHotel(CooperationModel hotel) {
    if (_favouriteHotels.any((h) => h.cooperationId == hotel.cooperationId)) {
      _favouriteHotels
          .removeWhere((h) => h.cooperationId == hotel.cooperationId);
    } else {
      _favouriteHotels.add(hotel);
    }
    notifyListeners();
  }

  bool isHotelFavourite(CooperationModel hotel) {
    return _favouriteHotels.any((h) => h.cooperationId == hotel.cooperationId);
  }

  void toggleFavouriteRestaurant(CooperationModel restaurant) {
    if (_favouriteRestaurants
        .any((r) => r.cooperationId == restaurant.cooperationId)) {
      _favouriteRestaurants
          .removeWhere((r) => r.cooperationId == restaurant.cooperationId);
    } else {
      _favouriteRestaurants.add(restaurant);
    }
    notifyListeners();
  }

  bool isRestaurantFavourite(CooperationModel restaurant) {
    return _favouriteRestaurants
        .any((r) => r.cooperationId == restaurant.cooperationId);
  }
}
