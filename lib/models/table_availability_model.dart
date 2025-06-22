class TableAvailabilityModel {
  final String tableId;
  final String tableName;
  final String tableType;
  final int capacity;
  final double price;
  final int availableTables;
  final int totalTables;
  final String photo;
  final List<String> amenities;
  final String description;
  final String location; // Vị trí bàn: window, garden, indoor, etc.

  TableAvailabilityModel({
    required this.tableId,
    required this.tableName,
    required this.tableType,
    required this.capacity,
    required this.price,
    required this.availableTables,
    required this.totalTables,
    required this.photo,
    required this.amenities,
    required this.description,
    required this.location,
  });

  factory TableAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return TableAvailabilityModel(
      tableId: map['tableId'] ?? '',
      tableName: map['tableName'] ?? '',
      tableType: map['tableType'] ?? '',
      capacity: map['capacity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      availableTables: map['availableTables'] ?? 0,
      totalTables: map['totalTables'] ?? 0,
      photo: map['photo'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      description: map['description'] ?? '',
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tableId': tableId,
      'tableName': tableName,
      'tableType': tableType,
      'capacity': capacity,
      'price': price,
      'availableTables': availableTables,
      'totalTables': totalTables,
      'photo': photo,
      'amenities': amenities,
      'description': description,
      'location': location,
    };
  }

  TableAvailabilityModel copyWith({
    String? tableId,
    String? tableName,
    String? tableType,
    int? capacity,
    double? price,
    int? availableTables,
    int? totalTables,
    String? photo,
    List<String>? amenities,
    String? description,
    String? location,
  }) {
    return TableAvailabilityModel(
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      tableType: tableType ?? this.tableType,
      capacity: capacity ?? this.capacity,
      price: price ?? this.price,
      availableTables: availableTables ?? this.availableTables,
      totalTables: totalTables ?? this.totalTables,
      photo: photo ?? this.photo,
      amenities: amenities ?? this.amenities,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }

  // Tính tỷ lệ bàn trống
  double get occupancyRate {
    if (totalTables == 0) return 0.0;
    return (totalTables - availableTables) / totalTables;
  }

  // Kiểm tra xem có bàn trống không
  bool get hasAvailability => availableTables > 0;

  // Lấy trạng thái bàn
  String get status {
    if (availableTables == 0) return 'Hết bàn';
    if (availableTables <= 2) return 'Sắp hết';
    return 'Còn bàn';
  }
} 