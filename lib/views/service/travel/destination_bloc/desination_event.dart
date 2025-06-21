import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class DestinationEvent {}

class LoadDestinationsByProvince extends DestinationEvent {
  final String province;
  LoadDestinationsByProvince(this.province);
}

class LoadDestinationsByProvinceWithLimit extends DestinationEvent {
  final String province;
  final int limit;
  LoadDestinationsByProvinceWithLimit(this.province, this.limit);
}

class LoadMoreDestinations extends DestinationEvent {
  final String province;
  final int limit;
  final DocumentSnapshot? lastDocument;
  LoadMoreDestinations(this.province, this.limit, {this.lastDocument});
}

class RefreshDestinations extends DestinationEvent {
  final String province;
  final int? limit;
  RefreshDestinations(this.province, {this.limit});
}