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

class DeleteTravelRoute extends TravelEvent {
  final String routeId;
  
  DeleteTravelRoute(this.routeId);
  
  @override
  List<Object?> get props => [routeId];
}

class CreateTravelRoute extends TravelEvent {
  final String routeName;
  final String province;
  final DateTime startDate;
  final DateTime endDate;

  CreateTravelRoute({
    required this.routeName,
    required this.province,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [routeName, province, startDate, endDate];
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