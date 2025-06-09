import 'package:tourguideapp/models/destination_model.dart';

abstract class DestinationState {}

class DestinationInitial extends DestinationState {}

class DestinationLoading extends DestinationState {}

class DestinationLoaded extends DestinationState {
  final List<DestinationModel> destinations;
  DestinationLoaded(this.destinations);
}

class DestinationError extends DestinationState {
  final String message;
  DestinationError(this.message);
}
