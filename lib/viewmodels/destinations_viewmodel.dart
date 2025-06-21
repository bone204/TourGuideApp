import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:flutter/foundation.dart';

class DestinationsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DestinationModel> _destinations = [];
  bool _isLoading = false;
  String _error = '';
  StreamSubscription<QuerySnapshot>? _destinationSubscription;
  bool _isInitialized = false;

  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String get error => _error;

  void initialize() {
    if (!_isInitialized) {
      _isInitialized = true;
      fetchDestinations();
    }
  }

  Future<void> fetchDestinations() async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      await _destinationSubscription?.cancel();

      _destinationSubscription =
          _firestore.collection('DESTINATION').snapshots().listen(
        (snapshot) {
          _destinations = snapshot.docs
              .map((doc) => DestinationModel.fromMap(doc.data()))
              .toList();
          _isLoading = false;
          _error = '';
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<HomeCardData> get horizontalCardsData {
    final list = _destinations.map((destination) {
      return HomeCardData(
        imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : '',
        placeName: destination.destinationName,
        description: destination.province,
        rating: destination.rating,
        favouriteTimes: destination.favouriteTimes,
        userRatingsTotal: destination.userRatingsTotal,
      );
    }).toList();

    list.sort((a, b) => b.userRatingsTotal.compareTo(a.userRatingsTotal));
    return list;
  }

  List<String> get uniqueProvinces {
    return destinations.map((dest) => dest.province).toSet().toList();
  }

  List<HomeCardData> getDestinationsByProvince(String province) {
    final list = destinations
        .where((dest) => dest.province == province)
        .map((dest) => HomeCardData(
              imageUrl: dest.photo.isNotEmpty ? dest.photo[0] : '',
              placeName: dest.destinationName,
              description: dest.province,
              rating: dest.rating,
              favouriteTimes: dest.favouriteTimes,
              userRatingsTotal: dest.userRatingsTotal,
            ))
        .toList();

    list.sort((a, b) => b.userRatingsTotal.compareTo(a.userRatingsTotal));
    return list;
  }

  @override
  void dispose() {
    _destinationSubscription?.cancel();
    super.dispose();
  }

  Future<void> refreshDestinations() async {
    _error = '';
    await fetchDestinations();
  }
}
