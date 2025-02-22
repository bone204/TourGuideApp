import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tourguideapp/models/destination_model.dart';

// Events
abstract class DestinationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDestinations extends DestinationEvent {
  final String province;
  
  LoadDestinations({required this.province});
  
  @override
  List<Object?> get props => [province];
}

// States
abstract class DestinationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DestinationInitial extends DestinationState {}
class DestinationLoading extends DestinationState {}
class DestinationLoaded extends DestinationState {
  final List<DestinationModel> destinations;
  
  DestinationLoaded({required this.destinations});
  
  @override
  List<Object?> get props => [destinations];
}
class DestinationError extends DestinationState {
  final String message;
  
  DestinationError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final FirebaseFirestore _firestore;

  DestinationBloc({required FirebaseFirestore firestore})
    : _firestore = firestore,
      super(DestinationInitial()) {
    on<LoadDestinations>(_onLoadDestinations);
  }

  Future<void> _onLoadDestinations(LoadDestinations event, Emitter<DestinationState> emit) async {
    try {
      emit(DestinationLoading());
      
      final destinationsSnapshot = await _firestore
        .collection('DESTINATION')
        .where('province', isEqualTo: event.province)
        .get();
        
      final destinations = destinationsSnapshot.docs
        .map((doc) => DestinationModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        }))
        .toList();
      
      emit(DestinationLoaded(destinations: destinations));
    } catch (e) {
      emit(DestinationError(message: e.toString()));
    }
  }
} 