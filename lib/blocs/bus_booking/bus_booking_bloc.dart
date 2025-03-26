import 'package:flutter_bloc/flutter_bloc.dart';
import 'bus_booking_event.dart';
import 'bus_booking_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/models/user_model.dart';

class BusBookingBloc extends Bloc<BusBookingEvent, BusBookingState> {
  BusBookingBloc() : super(BusBookingState()) {
    on<SetFromLocation>(_onSetFromLocation);
    on<SetToLocation>(_onSetToLocation);
    on<SearchBuses>(_onSearchBuses);
    on<LoadUserData>(_onLoadUserData);
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
      emit(state.copyWith(
        fromLocation: event.fromLocation,
        toLocation: event.toLocation,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLoadUserData(
    LoadUserData event,
    Emitter<BusBookingState> emit,
  ) async {
    try {
      print('Loading user data...');
      emit(state.copyWith(isLoadingUserData: true));
      
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        print('Firebase user found: ${firebaseUser.uid}');
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('USER')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          print('User document found');
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          print('Raw user data: $userData');
          
          UserModel currentUser = UserModel.fromMap(userData);
          print('Parsed user data: ${currentUser.fullName}, ${currentUser.email}, ${currentUser.phoneNumber}');

          final newState = state.copyWith(
            fullName: currentUser.fullName,
            email: currentUser.email,
            phoneNumber: currentUser.phoneNumber,
            isLoadingUserData: false,
            error: null,
          );
          print('New state: $newState');
          emit(newState);
        } else {
          print('User document does not exist');
          emit(state.copyWith(
            isLoadingUserData: false,
            error: 'User document does not exist',
          ));
        }
      } else {
        print('No firebase user found');
        emit(state.copyWith(
          isLoadingUserData: false,
          error: 'No user is currently signed in',
        ));
      }
    } catch (e) {
      print('Error loading user data: $e');
      emit(state.copyWith(
        isLoadingUserData: false,
        error: e.toString(),
      ));
    }
  }
}