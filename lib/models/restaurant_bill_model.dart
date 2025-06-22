import 'package:flutter/material.dart';

class RestaurantBillModel {
  final String billId;
  final String userId;
  final String restaurantId;
  final String tableId;
  final String customerName;
  final String customerPhone;
  final DateTime checkInDate;
  final TimeOfDay checkInTime;
  final int numberOfPeople;
  final double totalPrice;
  final String status; // pending, confirmed, cancelled
  final DateTime createdDate;
  final String? notes;

  RestaurantBillModel({
    required this.billId,
    required this.userId,
    required this.restaurantId,
    required this.tableId,
    required this.customerName,
    required this.customerPhone,
    required this.checkInDate,
    required this.checkInTime,
    required this.numberOfPeople,
    required this.totalPrice,
    required this.status,
    required this.createdDate,
    this.notes,
  });

  factory RestaurantBillModel.fromMap(Map<String, dynamic> map) {
    return RestaurantBillModel(
      billId: map['billId'] ?? '',
      userId: map['userId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      tableId: map['tableId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      checkInDate: DateTime.parse(
          map['checkInDate'] ?? DateTime.now().toIso8601String()),
      checkInTime: _parseTimeOfDay(map['checkInTime'] ?? '12:00'),
      numberOfPeople: map['numberOfPeople'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdDate: DateTime.parse(
          map['createdDate'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'userId': userId,
      'restaurantId': restaurantId,
      'tableId': tableId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'checkInDate': checkInDate.toIso8601String(),
      'checkInTime':
          '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}',
      'numberOfPeople': numberOfPeople,
      'totalPrice': totalPrice,
      'status': status,
      'createdDate': createdDate.toIso8601String(),
      'notes': notes,
    };
  }

  RestaurantBillModel copyWith({
    String? billId,
    String? userId,
    String? restaurantId,
    String? tableId,
    String? customerName,
    String? customerPhone,
    DateTime? checkInDate,
    TimeOfDay? checkInTime,
    int? numberOfPeople,
    double? totalPrice,
    String? status,
    DateTime? createdDate,
    String? notes,
  }) {
    return RestaurantBillModel(
      billId: billId ?? this.billId,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      tableId: tableId ?? this.tableId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      checkInDate: checkInDate ?? this.checkInDate,
      checkInTime: checkInTime ?? this.checkInTime,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      notes: notes ?? this.notes,
    );
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Format ngày giờ cho hiển thị
  String get formattedCheckInDate {
    return '${checkInDate.day.toString().padLeft(2, '0')}/${checkInDate.month.toString().padLeft(2, '0')}/${checkInDate.year}';
  }

  String get formattedCheckInTime {
    return '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}';
  }

  // Kiểm tra trạng thái
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
}
