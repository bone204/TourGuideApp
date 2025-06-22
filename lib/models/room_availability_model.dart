class RoomAvailabilityModel {
  final String roomId;
  final String roomName;
  final String roomType;
  final int capacity;
  final double price;
  final int availableRooms;
  final int totalRooms;
  final String photo;
  final List<String> amenities;
  final String description;

  RoomAvailabilityModel({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.capacity,
    required this.price,
    required this.availableRooms,
    required this.totalRooms,
    required this.photo,
    required this.amenities,
    required this.description,
  });

  factory RoomAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return RoomAvailabilityModel(
      roomId: map['roomId'] ?? '',
      roomName: map['roomName'] ?? '',
      roomType: map['roomType'] ?? '',
      capacity: map['capacity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      availableRooms: map['availableRooms'] ?? 0,
      totalRooms: map['totalRooms'] ?? 0,
      photo: map['photo'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'roomType': roomType,
      'capacity': capacity,
      'price': price,
      'availableRooms': availableRooms,
      'totalRooms': totalRooms,
      'photo': photo,
      'amenities': amenities,
      'description': description,
    };
  }

  RoomAvailabilityModel copyWith({
    String? roomId,
    String? roomName,
    String? roomType,
    int? capacity,
    double? price,
    int? availableRooms,
    int? totalRooms,
    String? photo,
    List<String>? amenities,
    String? description,
  }) {
    return RoomAvailabilityModel(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      roomType: roomType ?? this.roomType,
      capacity: capacity ?? this.capacity,
      price: price ?? this.price,
      availableRooms: availableRooms ?? this.availableRooms,
      totalRooms: totalRooms ?? this.totalRooms,
      photo: photo ?? this.photo,
      amenities: amenities ?? this.amenities,
      description: description ?? this.description,
    );
  }

  // Tính tỷ lệ phòng trống
  double get occupancyRate {
    if (totalRooms == 0) return 0.0;
    return (totalRooms - availableRooms) / totalRooms;
  }

  // Kiểm tra xem có phòng trống không
  bool get hasAvailability => availableRooms > 0;

  // Lấy trạng thái phòng
  String get status {
    if (availableRooms == 0) return 'Hết phòng';
    if (availableRooms <= 2) return 'Sắp hết';
    return 'Còn phòng';
  }
}
