class RoomModel {
  final String roomId;
  final String hotelId;
  final String roomName;
  final int numberOfBeds;
  final int capacity; // Số người tối đa có thể ở
  final double area;
  final double basePrice; // Giá cơ bản
  final String photo;
  final String description;
  final String roomType; // single, double, suite, etc.
  final List<String> amenities; // Tiện nghi: wifi, ac, tv, etc.

  RoomModel({
    required this.roomId,
    required this.hotelId,
    required this.roomName,
    required this.numberOfBeds,
    required this.capacity,
    required this.area,
    required this.basePrice,
    required this.photo,
    required this.description,
    required this.roomType,
    required this.amenities,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      roomId: map['roomId'] ?? '',
      hotelId: map['hotelId'] ?? '',
      roomName: map['roomName'] ?? '',
      numberOfBeds: map['numberOfBeds'] ?? 0,
      capacity: map['capacity'] ?? 0,
      area: (map['area'] ?? 0.0).toDouble(),
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      photo: map['photo'] ?? '',
      description: map['description'] ?? '',
      roomType: map['roomType'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'hotelId': hotelId,
      'roomName': roomName,
      'numberOfBeds': numberOfBeds,
      'capacity': capacity,
      'area': area,
      'basePrice': basePrice,
      'photo': photo,
      'description': description,
      'roomType': roomType,
      'amenities': amenities,
    };
  }

  RoomModel copyWith({
    String? roomId,
    String? hotelId,
    String? roomName,
    int? numberOfBeds,
    int? capacity,
    double? area,
    double? basePrice,
    String? photo,
    String? description,
    String? roomType,
    List<String>? amenities,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      hotelId: hotelId ?? this.hotelId,
      roomName: roomName ?? this.roomName,
      numberOfBeds: numberOfBeds ?? this.numberOfBeds,
      capacity: capacity ?? this.capacity,
      area: area ?? this.area,
      basePrice: basePrice ?? this.basePrice,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      roomType: roomType ?? this.roomType,
      amenities: amenities ?? this.amenities,
    );
  }
}
