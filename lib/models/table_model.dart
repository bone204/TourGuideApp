class TableModel {
  final String tableId;
  final String restaurantId;
  final String tableName;
  final int numberOfTables;
  final String dishType;
  final String priceRange;
  final int maxPeople;
  final String note;

  TableModel({
    required this.tableId,
    required this.restaurantId,
    required this.tableName,
    required this.numberOfTables,
    required this.dishType,
    required this.priceRange,
    required this.maxPeople,
    required this.note,
  });
}

