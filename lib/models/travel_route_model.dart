import 'package:cloud_firestore/cloud_firestore.dart';

class RouteItinerary {
  final String destinationId;
  final String timeline;
  final bool isCompleted;
  final DateTime? completedTime;

  RouteItinerary({
    required this.destinationId,
    required this.timeline,
    this.isCompleted = false,
    this.completedTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'timeline': timeline,
      'isCompleted': isCompleted,
      'completedTime': completedTime,
    };
  }

  factory RouteItinerary.fromMap(Map<String, dynamic> map) {
    return RouteItinerary(
      destinationId: map['destinationId'] ?? '',
      timeline: map['timeline'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedTime: map['completedTime'] != null
          ? (map['completedTime'] as Timestamp).toDate()
          : null,
    );
  }
}

class TravelRouteModel {
  final String travelRouteId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdDate;
  final double averageRating;
  final String province;
  final String avatar;
  final int number;
  final List<RouteItinerary> routes;
  final bool isCustom;
  final String routeTitle;

  TravelRouteModel({
    required this.travelRouteId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.createdDate,
    this.averageRating = 0.0,
    required this.province,
    required this.avatar,
    required this.number,
    required this.routes,
    this.isCustom = false,
    required this.routeTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'travelRouteId': travelRouteId,
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
      'createdDate': createdDate,
      'averageRating': averageRating,
      'province': province,
      'avatar': avatar,
      'number': number,
      'routes': routes.map((route) => route.toMap()).toList(),
      'isCustom': isCustom,
      'routeTitle': routeTitle,
    };
  }

  factory TravelRouteModel.fromMap(Map<String, dynamic> map) {
    return TravelRouteModel(
      travelRouteId: map['travelRouteId'] ?? '',
      userId: map['userId'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      province: map['province'] ?? '',
      avatar: map['avatar'] ?? '',
      number: map['number']?.toInt() ?? 0,
      routes: List<RouteItinerary>.from(
          (map['routes'] ?? []).map((x) => RouteItinerary.fromMap(x))),
      isCustom: map['isCustom'] ?? false,
      routeTitle: map['routeTitle'] ?? '',
    );
  }

  factory TravelRouteModel.empty() {
    return TravelRouteModel(
      travelRouteId: '',
      userId: '',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      createdDate: DateTime.now(),
      province: '',
      avatar: '',
      number: 0,
      routes: [],
      isCustom: false,
      routeTitle: '',
    );
  }
}
