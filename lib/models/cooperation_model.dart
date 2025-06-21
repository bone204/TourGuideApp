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

  Map<String, dynamic> toMap() {
    return {
      'cooperationId': cooperationId,
      'name': name,
      'type': type,
      'numberOfObjects': numberOfObjects,
      'numberOfObjectTypes': numberOfObjectTypes,
      'latitude': latitude,
      'longitude': longitude,
      'bossName': bossName,
      'bossPhone': bossPhone,
      'bossEmail': bossEmail,
      'address': address,
      'district': district,
      'city': city,
      'province': province,
      'photo': photo,
      'extension': extension,
      'introduction': introduction,
      'contractDate': contractDate,
      'contractTerm': contractTerm,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountName': bankAccountName,
      'bankName': bankName,
      'bookingTimes': bookingTimes,
      'revenue': revenue,
      'averageRating': averageRating,
    };
  }

  CooperationModel copyWith({
    String? cooperationId,
    String? name,
    String? type,
    int? numberOfObjects,
    int? numberOfObjectTypes,
    double? latitude,
    double? longitude,
    String? bossName,
    String? bossPhone,
    String? bossEmail,
    String? address,
    String? district,
    String? city,
    String? province,
    String? photo,
    String? extension,
    String? introduction,
    String? contractDate,
    String? contractTerm,
    String? bankAccountNumber,
    String? bankAccountName,
    String? bankName,
    int? bookingTimes,
    double? revenue,
    double? averageRating,
  }) {
    return CooperationModel(
      cooperationId: cooperationId ?? this.cooperationId,
      name: name ?? this.name,
      type: type ?? this.type,
      numberOfObjects: numberOfObjects ?? this.numberOfObjects,
      numberOfObjectTypes: numberOfObjectTypes ?? this.numberOfObjectTypes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bossName: bossName ?? this.bossName,
      bossPhone: bossPhone ?? this.bossPhone,
      bossEmail: bossEmail ?? this.bossEmail,
      address: address ?? this.address,
      district: district ?? this.district,
      city: city ?? this.city,
      province: province ?? this.province,
      photo: photo ?? this.photo,
      extension: extension ?? this.extension,
      introduction: introduction ?? this.introduction,
      contractDate: contractDate ?? this.contractDate,
      contractTerm: contractTerm ?? this.contractTerm,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankName: bankName ?? this.bankName,
      bookingTimes: bookingTimes ?? this.bookingTimes,
      revenue: revenue ?? this.revenue,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}
