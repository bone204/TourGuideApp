class UserModel {
  final String userId;
  final String name;
  final String email;
  final String address;
  final String gender; // Thêm giới tính
  final String citizenId; // Thêm ID công dân
  final String phoneNumber; // Thêm số điện thoại
  final String nationality; // Thêm quốc tịch
  final String birthday; // Thêm ngày sinh

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.address,
    required this.gender,
    required this.citizenId,
    required this.phoneNumber,
    required this.nationality,
    required this.birthday,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'address': address,
      'gender': gender,
      'citizenId': citizenId,
      'phoneNumber': phoneNumber,
      'nationality': nationality,
      'birthday': birthday,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      citizenId: map['citizenId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      nationality: map['nationality'] ?? '',
      birthday: map['birthday'] ?? '',
    );
  }
}
