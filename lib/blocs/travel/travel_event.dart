import 'package:equatable/equatable.dart';
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