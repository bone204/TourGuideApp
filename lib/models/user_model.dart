class UserModel {
  final String userId;
  final String name;
  final String fullName;
  final String email;
  final String address;
  final String gender;  
  final String citizenId; 
  final String phoneNumber;
  final String nationality;
  final String birthday; 

  UserModel({
    required this.userId,
    required this.name,
    required this.fullName,
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
      'fullName': fullName,
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
      fullName: map['fullName'] ?? '',
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
