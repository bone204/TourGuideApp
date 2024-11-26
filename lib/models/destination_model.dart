import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationModel {
  final String destinationId;
  final String destinationName;
  final double latitude;
  final double longitude;
  final String province;
  final String district;
  final String specificAddress;
  final String descriptionEng;
  final String descriptionViet;
  final List<String> photo;
  final List<String> video;
  final String createdDate;

  DestinationModel({
    required this.destinationId,
    required this.destinationName,
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.district,
    required this.specificAddress,
    required this.descriptionEng,
    required this.descriptionViet,
    required this.photo,
    required this.video,
    required this.createdDate,
  });

  factory DestinationModel.fromMap(Map<String, dynamic> map) {
    String convertTimestampToString(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate().toString();
      } else if (timestamp is String) {
        return timestamp;
      }
      return '';
    }

    return DestinationModel(
      destinationId: map['destinationId'] ?? '',
      destinationName: map['destinationName'] ?? '',
      latitude: (map['latitude'] is String) 
          ? double.tryParse(map['latitude']) ?? 0.0 
          : (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] is String) 
          ? double.tryParse(map['longitude']) ?? 0.0 
          : (map['longitude'] ?? 0.0).toDouble(),
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      specificAddress: map['specificAddress'] ?? '',
      descriptionEng: map['descriptionEng'] ?? '',
      descriptionViet: map['descriptionViet'] ?? '',
      photo: List<String>.from(map['photo'] ?? []),
      video: List<String>.from(map['video'] ?? []),
      createdDate: convertTimestampToString(map['createdDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'destinationName': destinationName,
      'latitude': latitude,
      'longitude': longitude,
      'province': province,
      'district': district,
      'specificAddress': specificAddress,
      'descriptionEng': descriptionEng,
      'descriptionViet': descriptionViet,
      'photo': photo,
      'video': video,
      'createdDate': createdDate,
    };
  }
}