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

      _destinationSubscription = _firestore
          .collection('DESTINATION')
          .snapshots()
          .listen(
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

  List<HomeCardData> get horizontalCardsData => _destinations.map((destination) {
    return HomeCardData(
      imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : '',
      placeName: destination.destinationName,
      description: destination.province,
      rating: 4.5,
      favouriteTimes: destination.favouriteTimes,
    );
  }).toList();

  List<String> get uniqueProvinces {
    return destinations
        .map((dest) => dest.province)
        .toSet()
        .toList();
  }

  List<HomeCardData> getDestinationsByProvince(String province) {
    return destinations
        .where((dest) => dest.province == province)
        .map((dest) => HomeCardData(
              imageUrl: dest.photo.isNotEmpty ? dest.photo[0] : '',
              placeName: dest.destinationName,
              description: dest.province,
              rating: 4.5,
              favouriteTimes: dest.favouriteTimes,
            ))
        .toList();
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