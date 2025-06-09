// Events
abstract class DestinationEvent {}

class LoadDestinationsByProvince extends DestinationEvent {
  final String province;
  LoadDestinationsByProvince(this.province);
}