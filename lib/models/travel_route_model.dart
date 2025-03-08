import 'package:cloud_firestore/cloud_firestore.dart';

class TravelRouteModel {
  final String travelRouteId;
  final String userId;
  final String routeName;
  final String province;
  final DateTime createdDate;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> destinationIds;

  TravelRouteModel({
    required this.travelRouteId,
    required this.userId,
    required this.routeName,
    required this.province,
    required this.createdDate,
    required this.startDate,
    required this.endDate,
    required this.destinationIds,
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
      'destinationIds': destinationIds,
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
      destinationIds: List<String>.from(map['destinationIds'] ?? []),
    );
  }
}
