import 'package:equatable/equatable.dart';
import 'package:tourguideapp/models/travel_route_model.dart';
import 'package:tourguideapp/models/destination_model.dart';

abstract class TravelState extends Equatable {
  const TravelState();

  @override
  List<Object?> get props => [];
}

// States cho TravelScreen
class TravelInitial extends TravelState {}
class TravelLoading extends TravelState {}
class TravelEmpty extends TravelState {}
class TravelLoaded extends TravelState {
  final List<TravelRouteModel> routes;

  const TravelLoaded(this.routes);

  @override
  List<Object?> get props => [routes];
}

// States cho RouteDetailScreen
abstract class RouteDetailState extends TravelState {
  final List<TravelRouteModel> routes;
  final List<DestinationModel> destinations;
  final Map<String, String>? timeSlots;

  const RouteDetailState(this.routes, this.destinations, {this.timeSlots});

  @override
  List<Object?> get props => [routes, destinations, timeSlots];
}

class RouteDetailLoading extends RouteDetailState {
  RouteDetailLoading(List<TravelRouteModel> routes) : super(routes, []);
}

class RouteDetailLoaded extends RouteDetailState {
  const RouteDetailLoaded(
    List<TravelRouteModel> routes,
    List<DestinationModel> destinations, {
    Map<String, String>? timeSlots,
  }) : super(routes, destinations, timeSlots: timeSlots);
}

// Common states
class TravelError extends TravelState {
  final String message;

  const TravelError(this.message);

  @override
  List<Object?> get props => [message];
}

class TravelRouteCreated extends TravelState {
  final String routeId;

  const TravelRouteCreated(this.routeId);

  @override
  List<Object?> get props => [routeId];
}

class DestinationsLoaded extends TravelState {
  final List<DestinationModel> destinations;
  
  DestinationsLoaded(this.destinations);
  
  @override
  List<Object?> get props => [destinations];
}

class TravelRouteUpdated extends TravelState {
  final List<DestinationModel> destinations;
  
  TravelRouteUpdated(this.destinations);
  
  @override
  List<Object?> get props => [destinations];
}

class DestinationsLoading extends TravelState {} 