import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/views/service/travel/destination_bloc/desination_event.dart';
import 'package:tourguideapp/views/service/travel/destination_bloc/destination_state.dart';
import 'package:tourguideapp/models/destination_model.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final FirebaseFirestore _firestore;

  DestinationBloc({required FirebaseFirestore firestore})
      : _firestore = firestore,
        super(DestinationInitial()) {
    on<LoadDestinationsByProvince>(_onLoadDestinations);
  }

  Future<void> _onLoadDestinations(
    LoadDestinationsByProvince event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      emit(DestinationLoading());
      
      final snapshot = await _firestore
          .collection('DESTINATION')
          .where('province', isEqualTo: event.province)
          .get();

      final destinations = snapshot.docs
          .map((doc) => DestinationModel.fromMap(doc.data()))
          .toList();

      emit(DestinationLoaded(destinations));
    } catch (e) {
      emit(DestinationError(e.toString()));
    }
  }
} 