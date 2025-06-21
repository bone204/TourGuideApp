class TableModel {
  final String tableId;
  final String restaurantId;
  final String tableName;
  final int numberOfTables;
  final String dishType;
  final String priceRange;
  final int maxPeople;
  final String note;
  final double price;
  final String photo;
  final String description;
  final bool isAvailable;

  TableModel({
    required this.tableId,
    required this.restaurantId,
    required this.tableName,
    required this.numberOfTables,
    required this.dishType,
    required this.priceRange,
    required this.maxPeople,
    required this.note,
    required this.price,
    required this.photo,
    required this.description,
    required this.isAvailable,
  });

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      tableId: map['tableId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      tableName: map['tableName'] ?? '',
      numberOfTables: map['numberOfTables'] ?? 0,
      dishType: map['dishType'] ?? '',
      priceRange: map['priceRange'] ?? '',
      maxPeople: map['maxPeople'] ?? 0,
      note: map['note'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      photo: map['photo'] ?? '',
      description: map['description'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tableId': tableId,
      'restaurantId': restaurantId,
      'tableName': tableName,
      'numberOfTables': numberOfTables,
      'dishType': dishType,
      'priceRange': priceRange,
      'maxPeople': maxPeople,
      'note': note,
      'price': price,
      'photo': photo,
      'description': description,
      'isAvailable': isAvailable,
    };
  }

  TableModel copyWith({
    String? tableId,
    String? restaurantId,
    String? tableName,
    int? numberOfTables,
    String? dishType,
    String? priceRange,
    int? maxPeople,
    String? note,
    double? price,
    String? photo,
    String? description,
    bool? isAvailable,
  }) {
    return TableModel(
      tableId: tableId ?? this.tableId,
      restaurantId: restaurantId ?? this.restaurantId,
      tableName: tableName ?? this.tableName,
      numberOfTables: numberOfTables ?? this.numberOfTables,
      dishType: dishType ?? this.dishType,
      priceRange: priceRange ?? this.priceRange,
      maxPeople: maxPeople ?? this.maxPeople,
      note: note ?? this.note,
      price: price ?? this.price,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
