abstract class BusBookingEvent {}

class SetFromLocation extends BusBookingEvent {
  final String location;
  final Map<String, dynamic> details;

  SetFromLocation(this.location, this.details);
}

class SetToLocation extends BusBookingEvent {
  final String location;
  final Map<String, dynamic> details;

  SetToLocation(this.location, this.details);
}
