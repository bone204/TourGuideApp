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
    };
  }
}
