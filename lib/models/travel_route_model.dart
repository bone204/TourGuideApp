import 'package:cloud_firestore/cloud_firestore.dart';

class TravelRouteModel {
  final String travelRouteId;
  final String userId;
  final String routeName;
  final String province;
  final DateTime createdDate;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, List<String>> destinationsByDay;

  TravelRouteModel({
    required this.travelRouteId,
    required this.userId,
    required this.routeName,
    required this.province,
    required this.createdDate,
    required this.startDate,
    required this.endDate,
    required this.destinationsByDay,
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
      'destinationsByDay': destinationsByDay,
    };
  }

  factory TravelRouteModel.fromMap(Map<String, dynamic> map) {
    final rawDestinationsByDay = map['destinationsByDay'] as Map<String, dynamic>? ?? {};
    final destinationsByDay = rawDestinationsByDay.map((key, value) {
      return MapEntry(
        key, 
        (value as List<dynamic>).map((e) => e.toString()).toList()
      );
    });

    return TravelRouteModel(
      travelRouteId: map['travelRouteId'] ?? '',
      userId: map['userId'] ?? '',
      routeName: map['routeName'] ?? '',
      province: map['province'] ?? '',
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      destinationsByDay: destinationsByDay,
    );
  }
}
