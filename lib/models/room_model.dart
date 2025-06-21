class RoomModel {
  final String roomId;
  final String hotelId;
  final String roomName;
  final int numberOfBeds;
  final int maxPeople;
  final double area;
  final double price;
  final int numberOfRooms;
  final String photo;
  final String description;
  final String roomType;
  final bool isAvailable;
  final List<String> amenities;
  final String priceType; // per night, per hour, etc.

  RoomModel({
    required this.roomId,
    required this.hotelId,
    required this.roomName,
    required this.numberOfBeds,
    required this.maxPeople,
    required this.area,
    required this.price,
    required this.numberOfRooms,
    required this.photo,
    required this.description,
    required this.roomType,
    required this.isAvailable,
    required this.amenities,
    required this.priceType,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      roomId: map['roomId'] ?? '',
      hotelId: map['hotelId'] ?? '',
      roomName: map['roomName'] ?? '',
      numberOfBeds: map['numberOfBeds'] ?? 0,
      maxPeople: map['maxPeople'] ?? 0,
      area: (map['area'] ?? 0.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
      numberOfRooms: map['numberOfRooms'] ?? 0,
      photo: map['photo'] ?? '',
      description: map['description'] ?? '',
      roomType: map['roomType'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      amenities: List<String>.from(map['amenities'] ?? []),
      priceType: map['priceType'] ?? 'per night',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'hotelId': hotelId,
      'roomName': roomName,
      'numberOfBeds': numberOfBeds,
      'maxPeople': maxPeople,
      'area': area,
      'price': price,
      'numberOfRooms': numberOfRooms,
      'photo': photo,
      'description': description,
      'roomType': roomType,
      'isAvailable': isAvailable,
      'amenities': amenities,
      'priceType': priceType,
    };
  }

  RoomModel copyWith({
    String? roomId,
    String? hotelId,
    String? roomName,
    int? numberOfBeds,
    int? maxPeople,
    double? area,
    double? price,
    int? numberOfRooms,
    String? photo,
    String? description,
    String? roomType,
    bool? isAvailable,
    List<String>? amenities,
    String? priceType,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      hotelId: hotelId ?? this.hotelId,
      roomName: roomName ?? this.roomName,
      numberOfBeds: numberOfBeds ?? this.numberOfBeds,
      maxPeople: maxPeople ?? this.maxPeople,
      area: area ?? this.area,
      price: price ?? this.price,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      roomType: roomType ?? this.roomType,
      isAvailable: isAvailable ?? this.isAvailable,
      amenities: amenities ?? this.amenities,
      priceType: priceType ?? this.priceType,
    );
  }
}
