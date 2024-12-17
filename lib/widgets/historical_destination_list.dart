import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/historical_destination_card.dart';

class HistoricalDestinationList extends StatelessWidget {
  final List<DestinationModel> destinations;
  final List<String> visitDates;

  const HistoricalDestinationList({
    required this.destinations,
    required this.visitDates,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 335.w,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 3,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        return HistoricalDestinationCard(
          destination: destinations[index],
          visitDate: visitDates[index],
        );
      },
    );
  }
}
