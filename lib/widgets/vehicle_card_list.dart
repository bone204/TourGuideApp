import 'package:flutter/material.dart';
import 'package:tourguideapp/widgets/vehicle_card.dart';

class VehicleList extends StatelessWidget {
  final List<VehicleCardData> vehiclesDataList;

  const VehicleList({Key? key, required this.vehiclesDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: vehiclesDataList.length,
      itemBuilder: (context, index) {
        return VehicleCard(data: vehiclesDataList[index]);
      },
    );
  }
}
