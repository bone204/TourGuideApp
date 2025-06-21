class RouteDestinationModel {
  final String destinationId;
  final String uniqueId;
  final String startTime;
  final String endTime;
  final List<String> images;
  final List<String> videos;
  final String notes;

  RouteDestinationModel({
    required this.destinationId,
    required this.uniqueId,
    required this.startTime,
    required this.endTime,
    this.images = const [],
    this.videos = const [],
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'uniqueId': uniqueId,
      'startTime': startTime,
      'endTime': endTime,
      'images': images,
      'videos': videos,
      'notes': notes,
    };
  }

  factory RouteDestinationModel.fromMap(Map<String, dynamic> map) {
    return RouteDestinationModel(
      destinationId: map['destinationId']?.toString() ?? '',
      uniqueId: map['uniqueId']?.toString() ?? '',
      startTime: map['startTime']?.toString() ?? '08:00',
      endTime: map['endTime']?.toString() ?? '09:00',
      images: (map['images'] as List<dynamic>?)?.cast<String>() ?? [],
      videos: (map['videos'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: map['notes']?.toString() ?? '',
    );
  }

  RouteDestinationModel copyWith({
    String? destinationId,
    String? uniqueId,
    String? startTime,
    String? endTime,
    List<String>? images,
    List<String>? videos,
    String? notes,
  }) {
    return RouteDestinationModel(
      destinationId: destinationId ?? this.destinationId,
      uniqueId: uniqueId ?? this.uniqueId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      notes: notes ?? this.notes,
    );
  }
} 