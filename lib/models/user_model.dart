class UserModel {
  final String userId;
  final String uid;
  final String name;
  final String fullName;
  final String email;
  final String address;
  final String gender;
  final String citizenId;
  final String idCardImageUrl;
  final String phoneNumber;
  final String nationality;
  final String birthday;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final List<String> hobbies;
  final String avatar;
  final List<String> favoriteDestinationIds;
  final List<String> favoriteHotelIds;
  final List<String> favoriteRestaurantIds;
  final int travelPoint;
  final int travelTrip;
  final int feedbackTimes;
  final int dayParticipation;

  UserModel({
    required this.userId,
    required this.uid,
    required this.name,
    required this.fullName,
    required this.email,
    required this.address,
    required this.gender,
    required this.citizenId,
    required this.idCardImageUrl,
    required this.phoneNumber,
    required this.nationality,
    required this.birthday,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    required this.hobbies,
    required this.avatar,
    this.favoriteDestinationIds = const [],
    this.favoriteHotelIds = const [],
    this.favoriteRestaurantIds = const [],
    this.travelPoint = 0,
    this.travelTrip = 0,
    this.feedbackTimes = 0,
    this.dayParticipation = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'uid': uid,
      'name': name,
      'fullName': fullName,
      'email': email,
      'address': address,
      'gender': gender,
      'citizenId': citizenId,
      'idCardImageUrl': idCardImageUrl,
      'phoneNumber': phoneNumber,
      'nationality': nationality,
      'birthday': birthday,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountName': bankAccountName,
      'hobbies': hobbies,
      'avatar': avatar,
      'favoriteDestinationIds': favoriteDestinationIds,
      'favoriteHotelIds': favoriteHotelIds,
      'favoriteRestaurantIds': favoriteRestaurantIds,
      'travelPoint': travelPoint,
      'travelTrip': travelTrip,
      'feedbackTimes': feedbackTimes,
      'dayParticipation': dayParticipation,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      citizenId: map['citizenId'] ?? '',
      idCardImageUrl: map['idCardImageUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      nationality: map['nationality'] ?? '',
      birthday: map['birthday'] ?? '',
      avatar: map['avatar'] ?? '',
      bankName: map['bankName'],
      bankAccountNumber: map['bankAccountNumber'],
      bankAccountName: map['bankAccountName'],
      hobbies: List<String>.from(map['hobbies'] ?? []),
      favoriteDestinationIds: List<String>.from(map['favoriteDestinationIds'] ?? []),
      favoriteHotelIds: List<String>.from(map['favoriteHotelIds'] ?? []),
      favoriteRestaurantIds: List<String>.from(map['favoriteRestaurantIds'] ?? []),
      travelPoint: map['travelPoint'] ?? 0,
      travelTrip: map['travelTrip'] ?? 0,
      feedbackTimes: map['feedbackTimes'] ?? 0,
      dayParticipation: map['dayParticipation'] ?? 0,
    );
  }
}
