abstract class BusBookingEvent {}

class SetFromLocation extends BusBookingEvent {
  final String location;
  final Map<String, String> details;

  SetFromLocation(this.location, this.details);
}

class SetToLocation extends BusBookingEvent {
  final String location;
  final Map<String, String> details;

  SetToLocation(this.location, this.details);
}

class SearchBuses extends BusBookingEvent {
  final DateTime arrivalDate;
  final DateTime? returnDate;
  final String fromLocation;
  final String toLocation;

  SearchBuses({
    required this.arrivalDate,
    this.returnDate,
    required this.fromLocation,
    required this.toLocation,
  });
}
