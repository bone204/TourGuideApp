import 'package:equatable/equatable.dart';
import 'package:tourguideapp/models/travel_route_model.dart';
import 'package:tourguideapp/models/destination_model.dart';

abstract class TravelState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TravelInitial extends TravelState {}

class TravelLoading extends TravelState {}

class TravelEmpty extends TravelState {}

class TravelLoaded extends TravelState {
  final List<TravelRouteModel> routes;
  
  TravelLoaded(this.routes);
  
  @override
  List<Object?> get props => [routes];
}

class TravelError extends TravelState {
  final String message;
  
  TravelError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class TravelRouteCreated extends TravelState {
  final String routeId;
  
  TravelRouteCreated(this.routeId);
  
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