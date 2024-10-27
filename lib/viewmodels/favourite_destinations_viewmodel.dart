import 'package:flutter/material.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';

class FavouriteDestinationsViewModel extends ChangeNotifier {
  List<HorizontalCardData> _favouriteCards = [];

  List<HorizontalCardData> get favouriteCards => _favouriteCards;

  void toggleFavourite(HorizontalCardData data) {
    if (_favouriteCards.any((card) => card.placeName == data.placeName)) {
      _favouriteCards.removeWhere((card) => card.placeName == data.placeName);
    } else {
      _favouriteCards.add(data);
    }
    notifyListeners();
  }

  bool isFavourite(HorizontalCardData data) {
    return _favouriteCards.any((card) => card.placeName == data.placeName);
  }
}
