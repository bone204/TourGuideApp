import 'package:flutter/material.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/destination_detail_page.dart';
import 'package:tourguideapp/widgets/home_card.dart';

class DestinationDetailAddPage extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onAddPressed;

  const DestinationDetailAddPage({
    Key? key,
    required this.destination,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DestinationDetailPage(
        cardData: HomeCardData(
          imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : 'assets/images/default.jpg',
          placeName: destination.destinationName,
          description: destination.province,
          rating: 4.5,
        ),
        destinationData: destination,
        isFavourite: false,
        onFavouriteToggle: (_) {},
        hideActions: true,
        onSaveTrip: onAddPressed,
      ),
    );
  }
} 