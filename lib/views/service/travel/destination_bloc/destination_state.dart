import 'package:tourguideapp/models/destination_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DestinationState {}

class DestinationInitial extends DestinationState {}

class DestinationLoading extends DestinationState {}

class DestinationLoaded extends DestinationState {
  final List<DestinationModel> destinations;
  final int? limit;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final DocumentSnapshot? lastDocument;
  
  DestinationLoaded(
    this.destinations, {
    this.limit,
    this.hasMore = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.lastDocument,
  });
}

class DestinationError extends DestinationState {
  final String message;
  final bool isRefreshing;
  
  DestinationError(this.message, {this.isRefreshing = false});
}
