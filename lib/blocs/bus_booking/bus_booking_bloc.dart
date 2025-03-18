import 'package:flutter_bloc/flutter_bloc.dart';
import 'bus_booking_event.dart';
import 'bus_booking_state.dart';

class BusBookingBloc extends Bloc<BusBookingEvent, BusBookingState> {
  BusBookingBloc() : super(BusBookingState()) {
    on<SetFromLocation>(_onSetFromLocation);
    on<SetToLocation>(_onSetToLocation);
    on<SearchBusTickets>(_onSearchBusTickets);
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

  Future<void> _onSearchBusTickets(SearchBusTickets event, Emitter<BusBookingState> emit) async {
    try {
      if (state.fromLocation.isEmpty || state.toLocation.isEmpty) {
        emit(state.copyWith(error: 'Please select both from and to locations'));
        return;
      }

      emit(state.copyWith(isSearching: true, error: null));

      // TODO: Add API call to fetch bus tickets
      await Future.delayed(Duration(seconds: 2)); // Simulating API call
      
      // Dummy data for demonstration
      final dummyResults = [
        {
          'busCompany': 'Express Bus',
          'departureTime': '08:00',
          'arrivalTime': '10:00',
          'price': '100.000 VND',
          'availableSeats': 30,
        },
        {
          'busCompany': 'VIP Bus',
          'departureTime': '09:30',
          'arrivalTime': '11:30',
          'price': '150.000 VND',
          'availableSeats': 25,
        },
      ];

      emit(state.copyWith(
        isSearching: false,
        searchResults: dummyResults,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSearching: false,
        error: e.toString(),
      ));
    }
  }
} 