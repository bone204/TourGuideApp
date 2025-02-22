import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tourguideapp/models/destination_model.dart';

// Events
abstract class TravelRouteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTravelRoutes extends TravelRouteEvent {
  final String? provinceName;
  LoadTravelRoutes({this.provinceName});
}

class SaveCustomRoute extends TravelRouteEvent {
  final String routeTitle;
  final List<DestinationModel> destinations;
  final DateTime startDate;
  final DateTime endDate;
  final String provinceName;
  final List<Map<String, dynamic>> routes;

  SaveCustomRoute({
    required this.routeTitle,
    required this.destinations,
    required this.startDate,
    required this.endDate,
    required this.provinceName,
    required this.routes,
  });

  @override
  List<Object?> get props => [routeTitle, destinations, startDate, endDate, provinceName, routes];
}

class DeleteTravelRoute extends TravelRouteEvent {
  final String routeTitle;
  DeleteTravelRoute({required this.routeTitle});

  @override
  List<Object?> get props => [routeTitle];
}

class AddDestinationToRoute extends TravelRouteEvent {
  final String routeTitle;
  final DestinationModel destination;
  
  AddDestinationToRoute({
    required this.routeTitle,
    required this.destination,
  });
  
  @override
  List<Object?> get props => [routeTitle, destination];
}

// States
abstract class TravelRouteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TravelRouteInitial extends TravelRouteState {}
class TravelRouteLoading extends TravelRouteState {}
class TravelRouteLoaded extends TravelRouteState {
  final List<Map<String, dynamic>> userRoutes;
  final List<Map<String, dynamic>> suggestedRoutes;
  
  TravelRouteLoaded({
    required this.userRoutes,
    required this.suggestedRoutes,
  });
  
  @override
  List<Object?> get props => [userRoutes, suggestedRoutes];
}
class TravelRouteError extends TravelRouteState {
  final String message;
  TravelRouteError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Bloc
class TravelRouteBloc extends Bloc<TravelRouteEvent, TravelRouteState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TravelRouteBloc({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth,
       super(TravelRouteInitial()) {
    on<LoadTravelRoutes>(_onLoadTravelRoutes);
    on<SaveCustomRoute>(_onSaveCustomRoute);
    on<DeleteTravelRoute>(_onDeleteTravelRoute);
    on<AddDestinationToRoute>(_onAddDestinationToRoute);
  }

  Future<void> _onLoadTravelRoutes(LoadTravelRoutes event, Emitter<TravelRouteState> emit) async {
    try {
      emit(TravelRouteLoading());
      
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      final currentUserId = userDoc.data()?['userId'] as String?;
      if (currentUserId == null) throw Exception('User information not found');

      // Load user routes
      final userRoutesSnapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .where('userId', isEqualTo: currentUserId)
          .get();

      final userRoutes = await _processRoutes(userRoutesSnapshot);

      // Load suggested routes if provinceName is provided
      List<Map<String, dynamic>> suggestedRoutes = [];
      if (event.provinceName != null) {
        final suggestedSnapshot = await _firestore
            .collection('TRAVEL_ROUTE')
            .where('province', isEqualTo: event.provinceName)
            .get();

        for (var doc in suggestedSnapshot.docs) {
          final data = doc.data();
          final routeUserId = data['userId'] as String;
          final isCustom = data['isCustom'] == true;

          if (!isCustom || (isCustom && routeUserId == currentUserId)) {
            final processedRoute = await _processRoute(doc);
            suggestedRoutes.add(processedRoute);
          }
        }
      }

      emit(TravelRouteLoaded(
        userRoutes: userRoutes,
        suggestedRoutes: suggestedRoutes,
      ));
    } catch (e) {
      emit(TravelRouteError(message: e.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _processRoutes(QuerySnapshot snapshot) async {
    final routes = <Map<String, dynamic>>[];
    for (var doc in snapshot.docs) {
      final processedRoute = await _processRoute(doc);
      routes.add(processedRoute);
    }
    return routes;
  }

  Future<Map<String, dynamic>> _processRoute(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final List<DestinationModel> destinations = [];
    
    for (var route in (data['routes'] as List? ?? [])) {
      final destDoc = await _firestore
          .collection('DESTINATION')
          .doc(route['destinationId'])
          .get();
      
      if (destDoc.exists) {
        destinations.add(DestinationModel.fromMap(destDoc.data()!));
      }
    }

    return {
      'routeTitle': data['routeTitle'],
      'rating': data['averageRating'] ?? 0.0,
      'travelRouteId': data['travelRouteId'],
      'province': data['province'],
      'routes': data['routes'] ?? [],
      'destinations': destinations,
      'createdDate': data['createdDate'],
      'isCustom': data['isCustom'] ?? false,
      'userId': data['userId'],
    };
  }

  Future<void> _onSaveCustomRoute(SaveCustomRoute event, Emitter<TravelRouteState> emit) async {
    // Implementation needed
  }

  Future<void> _onDeleteTravelRoute(DeleteTravelRoute event, Emitter<TravelRouteState> emit) async {
    // Implementation needed
  }

  Future<void> _onAddDestinationToRoute(AddDestinationToRoute event, Emitter<TravelRouteState> emit) async {
    // Implementation needed
  }
} 