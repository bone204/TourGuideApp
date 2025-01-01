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
  final int favouriteTimes;

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
    this.favouriteTimes = 0,
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
      favouriteTimes: map['favouriteTimes']?.toInt() ?? 0,
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
      'favouriteTimes': favouriteTimes,
    };
  }

  DestinationModel copyWith({
    String? destinationId,
    String? destinationName,
    double? latitude,
    double? longitude,
    String? province,
    String? district,
    String? specificAddress,
    String? descriptionEng,
    String? descriptionViet,
    List<String>? photo,
    List<String>? video,
    String? createdDate,
    int? favourite,
  }) {
    return DestinationModel(
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      province: province ?? this.province,
      district: district ?? this.district,
      specificAddress: specificAddress ?? this.specificAddress,
      descriptionEng: descriptionEng ?? this.descriptionEng,
      descriptionViet: descriptionViet ?? this.descriptionViet,
      photo: photo ?? this.photo,
      video: video ?? this.video,
      createdDate: createdDate ?? this.createdDate,
      favouriteTimes: favourite ?? this.favouriteTimes,
    );
  }
}