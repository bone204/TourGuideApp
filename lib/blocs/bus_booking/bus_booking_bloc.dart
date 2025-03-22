import 'package:flutter_bloc/flutter_bloc.dart';
import 'bus_booking_event.dart';
import 'bus_booking_state.dart';

class BusBookingBloc extends Bloc<BusBookingEvent, BusBookingState> {
  BusBookingBloc() : super(BusBookingState()) {
    on<SetFromLocation>(_onSetFromLocation);
    on<SetToLocation>(_onSetToLocation);
    on<SearchBuses>(_onSearchBuses);
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

  void _onSearchBuses(SearchBuses event, Emitter<BusBookingState> emit) {
    try {
      // Here you can add your bus search logic
      // For now, we'll just emit the current state with the search parameters
      emit(state.copyWith(
        fromLocation: event.fromLocation,
        toLocation: event.toLocation,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}