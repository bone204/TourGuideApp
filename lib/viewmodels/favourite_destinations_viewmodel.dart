import 'package:flutter/material.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';

class FavouriteDestinationsViewModel extends ChangeNotifier {
  List<DestinationModel> _favouriteDestinations = [];

  List<DestinationModel> get favouriteDestinations => _favouriteDestinations;

  List<HorizontalCardData> get favouriteCards => _favouriteDestinations.map((destination) {
    return HorizontalCardData(
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
}
