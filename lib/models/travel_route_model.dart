import 'package:cloud_firestore/cloud_firestore.dart';

class TravelRouteModel {
  final String travelRouteId;
  final String userId;
  final String routeName;
  final String province;
  final DateTime createdDate;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, List<Map<String, String?>>> destinationsByDay;

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
        (value as List<dynamic>).map((e) {
          if (e is Map<String, dynamic>) {
            return {
              'destinationId': e['destinationId']?.toString() ?? '',
              'uniqueId': e['uniqueId']?.toString() ?? '',
              'startTime': e['startTime']?.toString() ?? '08:00',
              'endTime': e['endTime']?.toString() ?? '09:00',
            };
          } else {
            return {
              'destinationId': e.toString(),
              'uniqueId': '${e.toString()}_${DateTime.now().millisecondsSinceEpoch}',
              'startTime': '08:00',
              'endTime': '09:00',
            };
          }
        }).toList(),
      );
    });

    return TravelRouteModel(
      travelRouteId: map['travelRouteId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      routeName: map['routeName']?.toString() ?? '',
      province: map['province']?.toString() ?? '',
      createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      destinationsByDay: destinationsByDay,
    );
  }
}
