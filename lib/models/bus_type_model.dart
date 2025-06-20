class BusTypeModel {
  final String busTypeId;
  final String busId;
  final String busTypeName;
  final int numberOfSeats;
  final double price;
  final String route;
  final int numberOfBuses;
  final String photo;

  BusTypeModel({
    required this.busTypeId,
    required this.busId,
    required this.busTypeName,
    required this.numberOfSeats,
    required this.price,
    required this.route,
    required this.numberOfBuses,
    required this.photo,
  });

  Map<String, dynamic> toMap() {
    return {
      'busTypeId': busTypeId,
      'busId': busId,
      'busTypeName': busTypeName,
      'numberOfSeats': numberOfSeats,
      'price': price,
      'route': route,
      'numberOfBuses': numberOfBuses,
      'photo': photo,
    };
  }

  factory BusTypeModel.fromMap(Map<String, dynamic> map) {
    return BusTypeModel(
      busTypeId: map['busTypeId'] ?? '',
      busId: map['busId'] ?? '',
      busTypeName: map['busTypeName'] ?? '',
      numberOfSeats: map['numberOfSeats'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      route: map['route'] ?? '',
      numberOfBuses: map['numberOfBuses'] ?? 0,
      photo: map['photo'] ?? '',
    );
  }
}
