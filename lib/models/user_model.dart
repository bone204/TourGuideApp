class UserModel {
  final String userId;
  final String name;
  final String email;
  final String address;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.address,
  });

  // Chuyển đổi từ UserModel thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'address': address,
    };
  }

  // Chuyển đổi từ Map thành UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
