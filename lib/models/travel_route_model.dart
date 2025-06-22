import 'package:cloud_firestore/cloud_firestore.dart';

class TravelRouteModel {
  final String travelRouteId;
  final String userId;
  final String routeName;
  final String province;
  final DateTime createdDate;
  final int numberOfDays;
  final Map<String, List<Map<String, dynamic>>> destinationsByDay;

  TravelRouteModel({
    required this.travelRouteId,
    required this.userId,
    required this.routeName,
    required this.province,
    required this.createdDate,
    required this.numberOfDays,
    required this.destinationsByDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'travelRouteId': travelRouteId,
      'userId': userId,
      'routeName': routeName,
      'province': province,
      'createdDate': createdDate,
      'numberOfDays': numberOfDays,
      'destinationsByDay': destinationsByDay,
    };
  }

  factory TravelRouteModel.fromMap(Map<String, dynamic> map) {
    print('Parsing TravelRouteModel from map: $map');
    
    final rawDestinationsByDay = map['destinationsByDay'] as Map<String, dynamic>? ?? {};
    print('Raw destinationsByDay: $rawDestinationsByDay');
    
    final destinationsByDay = rawDestinationsByDay.map((key, value) {
      print('Processing day: $key, value: $value');
      return MapEntry(
        key,
        (value as List<dynamic>)
            .map((e) {
              print('Processing destination: $e');
              if (e is Map<String, dynamic>) {
                if (e['startTime'] == null || e['endTime'] == null ||
                    e['startTime'].toString().isEmpty || e['endTime'].toString().isEmpty) {
                  print('LỖI: Địa điểm thiếu trường startTime hoặc endTime, bỏ qua: $e');
                  return null;
                }
                final result = <String, dynamic>{
                  'destinationId': e['destinationId']?.toString() ?? '',
                  'uniqueId': e['uniqueId']?.toString() ?? '',
                  'startTime': e['startTime'].toString(),
                  'endTime': e['endTime'].toString(),
                  'images': (e['images'] as List<dynamic>?)?.cast<String>() ?? [],
                  'videos': (e['videos'] as List<dynamic>?)?.cast<String>() ?? [],
                  'notes': e['notes']?.toString() ?? '',
                };
                print('Parsed destination: $result');
                return result;
              } else {
                print('LỖI: Địa điểm không phải map, bỏ qua: $e');
                return null;
              }
            })
            .where((e) => e != null)
            .cast<Map<String, dynamic>>()
            .toList(),
      );
    });

    final result = TravelRouteModel(
      travelRouteId: map['travelRouteId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      routeName: map['routeName']?.toString() ?? '',
      province: map['province']?.toString() ?? '',
      createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      numberOfDays: map['numberOfDays']?.toInt() ?? 1,
      destinationsByDay: destinationsByDay,
    );
    
    print('Final TravelRouteModel: ${result.routeName}, destinationsByDay: ${result.destinationsByDay}');
    return result;
  }
}
