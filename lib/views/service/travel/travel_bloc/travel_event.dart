import 'package:equatable/equatable.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/models/travel_route_model.dart';

abstract class TravelEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTravelRoutes extends TravelEvent {}

class AddTravelRoute extends TravelEvent {
  final TravelRouteModel route;
  
  AddTravelRoute(this.route);
  
  @override
  List<Object?> get props => [route];
}

class UpdateTravelRoute extends TravelEvent {
  final String travelRouteId;
  final int numberOfDays;
  final String? dayToDelete;
  final DateTime? startDate;
  final DateTime? endDate;

  UpdateTravelRoute({required this.travelRouteId, required this.numberOfDays, this.dayToDelete, this.startDate, this.endDate});

  @override
  List<Object?> get props => [travelRouteId, numberOfDays, dayToDelete, startDate, endDate];
}

class DeleteTravelRoute extends TravelEvent {
  final String routeId;
  
  DeleteTravelRoute(this.routeId);
  
  @override
  List<Object?> get props => [routeId];
}

class CreateTravelRoute extends TravelEvent {
  final String routeName;
  final String province;
  final int numberOfDays;
  final DateTime startDate;
  final DateTime endDate;

  CreateTravelRoute({
    required this.routeName,
    required this.province,
    required this.numberOfDays,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [routeName, province, numberOfDays, startDate, endDate];
}

class StartTravelRoute extends TravelEvent {
  final String routeId;
  
  StartTravelRoute(this.routeId);
  
  @override
  List<Object?> get props => [routeId];
}

class LoadDestinations extends TravelEvent {
  final String province;
  
  LoadDestinations(this.province);
  
  @override
  List<Object?> get props => [province];
}

class AddDestinationToRoute extends TravelEvent {
  final DestinationModel destination;
  final String? existingRouteId;
  
  AddDestinationToRoute(this.destination, {this.existingRouteId});
  
  @override
  List<Object?> get props => [destination, existingRouteId];
}

class LoadRouteDestinations extends TravelEvent {
  final String routeId;
  LoadRouteDestinations(this.routeId);
}

class LoadTemporaryDestinations extends TravelEvent {
  final String day;
  LoadTemporaryDestinations(this.day);
  
  @override
  List<Object?> get props => [day];
}

class UpdateDestinationTime extends TravelEvent {
  final String uniqueId;
  final String startTime;
  final String endTime;
  final String? routeId;
  final String currentDay;

  UpdateDestinationTime({
    required this.uniqueId,
    required this.startTime,
    required this.endTime,
    this.routeId,
    required this.currentDay,
  });
}

class UpdateDestinationDetails extends TravelEvent {
  final String uniqueId;
  final String? routeId;
  final String currentDay;
  final List<String>? images;
  final List<String>? videos;
  final String? notes;

  UpdateDestinationDetails({
    required this.uniqueId,
    this.routeId,
    required this.currentDay,
    this.images,
    this.videos,
    this.notes,
  });

  @override
  List<Object?> get props => [uniqueId, routeId, currentDay, images, videos, notes];
}

class DeleteDestinationFromRoute extends TravelEvent {
  final String uniqueId;
  final String? routeId;
  final String currentDay;

  DeleteDestinationFromRoute({
    required this.uniqueId,
    this.routeId,
    required this.currentDay,
  });

  @override
  List<Object?> get props => [uniqueId, routeId, currentDay];
}

// Các event mới cho việc xử lý xung đột thời gian
class ValidateTimeSlots extends TravelEvent {
  final String? routeId;
  final String currentDay;

  ValidateTimeSlots({
    this.routeId,
    required this.currentDay,
  });

  @override
  List<Object?> get props => [routeId, currentDay];
}

class AutoAdjustTimeSlots extends TravelEvent {
  final String? routeId;
  final String currentDay;
  final String startTime; // Thời gian bắt đầu của ngày
  final int durationPerDestination; // Thời gian cho mỗi địa điểm (phút)

  AutoAdjustTimeSlots({
    this.routeId,
    required this.currentDay,
    this.startTime = '08:00',
    this.durationPerDestination = 120, // 2 giờ mặc định
  });

  @override
  List<Object?> get props => [routeId, currentDay, startTime, durationPerDestination];
}

class SuggestTimeAdjustment extends TravelEvent {
  final String uniqueId;
  final String? routeId;
  final String currentDay;
  final String desiredStartTime;
  final String desiredEndTime;

  SuggestTimeAdjustment({
    required this.uniqueId,
    this.routeId,
    required this.currentDay,
    required this.desiredStartTime,
    required this.desiredEndTime,
  });

  @override
  List<Object?> get props => [uniqueId, routeId, currentDay, desiredStartTime, desiredEndTime];
} 