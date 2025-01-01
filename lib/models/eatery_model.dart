class EateryModel {
  final String eateryId;
  final String eateryName;
  final String address;
  final String province;
  final List<String> photo;
  final List<String> menu;
  final String descriptionViet;
  final String descriptionEng;
  final double rating;
  final String phoneNumber;
  final String openTime;
  final String closeTime;
  final double latitude;
  final double longitude;

  EateryModel({
    required this.eateryId,
    required this.eateryName,
    required this.address,
    required this.province,
    required this.photo,
    this.menu = const [],
    required this.descriptionViet,
    required this.descriptionEng,
    this.rating = 0,
    this.phoneNumber = '',
    this.openTime = '',
    this.closeTime = '',
    this.latitude = 0,
    this.longitude = 0,
  });
} 