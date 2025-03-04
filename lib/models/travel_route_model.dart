import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/models/destination_model.dart';

class TravelRouteModel {
  final String travelRouteId;
  final String userId;
  final String routeName;
  final String province;
  final DateTime createdDate;
  final DateTime startDate;
  final DateTime endDate;
  final List<DestinationModel> destinations;

  TravelRouteModel({
    required this.travelRouteId,
    required this.userId,
    required this.routeName,
    required this.province,
    required this.createdDate,
    required this.startDate,
    required this.endDate,
    required this.destinations,
  });

  Map<String, dynamic> toMap() {
    return {
      'travelRouteId': travelRouteId,
      'userId': userId,
      'routeName': routeName,
      'province': province,
      'createdDate': createdDate,
      'startDate': startDate,
      'endDate': endDate,
      'destinations': destinations.map((dest) => dest.toMap()).toList(),
    };
  }

  factory TravelRouteModel.fromMap(Map<String, dynamic> map) {
    return TravelRouteModel(
      travelRouteId: map['travelRouteId'] ?? '',
      userId: map['userId'] ?? '',
      routeName: map['routeName'] ?? '',
      province: map['province'] ?? '',
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      destinations: List<DestinationModel>.from(
        (map['destinations'] ?? []).map((x) => DestinationModel.fromMap(x)),
      ),
    );
  }
}
