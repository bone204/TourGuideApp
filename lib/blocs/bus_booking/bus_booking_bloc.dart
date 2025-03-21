import 'package:flutter_bloc/flutter_bloc.dart';
import 'bus_booking_event.dart';
import 'bus_booking_state.dart';

class BusBookingBloc extends Bloc<BusBookingEvent, BusBookingState> {
  BusBookingBloc() : super(BusBookingState()) {
    on<SetFromLocation>(_onSetFromLocation);
    on<SetToLocation>(_onSetToLocation);
  }

  void _onSetFromLocation(SetFromLocation event, Emitter<BusBookingState> emit) {
    try {
      emit(state.copyWith(
        fromLocation: event.location,
        fromLocationDetails: event.details,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onSetToLocation(SetToLocation event, Emitter<BusBookingState> emit) {
    try {
      emit(state.copyWith(
        toLocation: event.location,
        toLocationDetails: event.details,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}