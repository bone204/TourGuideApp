class DestinationModel {
  final String destinationId;
  final String destinationName;
  final double latitude;
  final double longitude;
  final String province;
  final String district;
  final String specificAddress;
  final String description;
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
    required this.description,
    required this.photo,
    required this.video,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'destinationName': destinationName,
      'latitude': latitude,
      'longitude': longitude,
      'province': province,
      'district': district,
      'specificAddress': specificAddress,
      'description': description,
      'photo': photo, // Stored as a list in Firestore
      'video': video, // Stored as a list in Firestore
      'createdDate': createdDate,
    };
  }

  factory DestinationModel.fromMap(Map<String, dynamic> map) {
    return DestinationModel(
      destinationId: map['destinationId'] ?? '',
      destinationName: map['destinationName'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      specificAddress: map['specificAddress'] ?? '',
      description: map['description'] ?? '',
      photo: List<String>.from(map['photo'] ?? []), 
      video: List<String>.from(map['video'] ?? []),
      createdDate: map['createdDate'] ?? '',
    );
  }
}