class RestaurantModel {
  final String restaurantId;
  final String restaurantName;
  final String imageUrl;
  final double rating;
  final double pricePerPerson;
  final String address;

  RestaurantModel({
    required this.restaurantId,
    required this.restaurantName,
    required this.imageUrl,
    required this.rating,
    required this.pricePerPerson,
    required this.address,
  });
} 