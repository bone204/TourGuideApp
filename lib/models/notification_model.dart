class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String serviceType;
  final String serviceId;
  final String serviceName;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? additionalData;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.serviceType,
    required this.serviceId,
    required this.serviceName,
    required this.createdAt,
    this.isRead = false,
    this.additionalData,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      serviceType: map['serviceType'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      additionalData: map['additionalData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'serviceType': serviceType,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'additionalData': additionalData,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? serviceType,
    String? serviceId,
    String? serviceName,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      serviceType: serviceType ?? this.serviceType,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      additionalData: additionalData ?? this.additionalData,
    );
  }
} 