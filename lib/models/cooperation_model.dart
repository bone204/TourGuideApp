class CooperationModel {
  final String cooperationId;
  final String name;
  final String type; // hotel, restaurant, eatery, delivery, bus
  final int numberOfObjects;
  final int numberOfObjectTypes;
  final double latitude;
  final double longitude;
  final String bossName;
  final String bossPhone;
  final String bossEmail;
  final String address;
  final String district;
  final String city;
  final String province;
  final String photo;
  final String extension;
  final String introduction;
  final String contractDate;
  final String contractTerm;
  final String bankAccountNumber;
  final String bankAccountName;
  final String bankName;
  final int bookingTimes;
  final double revenue;
  final double averageRating;

  CooperationModel({
    required this.cooperationId,
    required this.name,
    required this.type,
    required this.numberOfObjects,
    required this.numberOfObjectTypes,
    required this.latitude,
    required this.longitude,
    required this.bossName,
    required this.bossPhone,
    required this.bossEmail,
    required this.address,
    required this.district,
    required this.city,
    required this.province,
    required this.photo,
    required this.extension,
    required this.introduction,
    required this.contractDate,
    required this.contractTerm,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.bankName,
    required this.bookingTimes,
    required this.revenue,
    required this.averageRating,
  });
}
