import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/blocs/travel/travel_event.dart';
import 'package:tourguideapp/blocs/travel/travel_state.dart';
import 'package:tourguideapp/models/travel_route_model.dart';
import 'package:tourguideapp/models/user_model.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/utils/time_slot_manager.dart';

class TravelBloc extends Bloc<TravelEvent, TravelState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  Map<String, List<String>> _tempDestinationsByDay = {};
  List<DestinationModel>? _cachedDestinations;
  TravelRouteModel? _currentRoute;
  String _currentDay = 'Day 1';

  TravelBloc({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth,
       super(TravelInitial()) {
    on<LoadTravelRoutes>(_onLoadRoutes);
    on<AddTravelRoute>(_onAddRoute);
    on<DeleteTravelRoute>(_onDeleteRoute);
    on<CreateTravelRoute>(_onCreateRoute);
    on<StartTravelRoute>(_onStartRoute);
    on<LoadDestinations>(_onLoadDestinations);
    on<AddDestinationToRoute>(_onAddDestinationToRoute);
    on<LoadRouteDestinations>(_onLoadRouteDestinations);
    on<LoadTemporaryDestinations>(_onLoadTemporaryDestinations);
  }

  Future<String> generateRouteName() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User's Route";

      final userDoc = await _firestore
          .collection('USER')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return "User's Route";

      final userData = UserModel.fromMap(userDoc.data()!);
      return "${userData.name}'s Route";
    } catch (e) {
      return "User's Route";
    }
  }

  Future<void> _onLoadRoutes(LoadTravelRoutes event, Emitter<TravelState> emit) async {
    try {
      emit(TravelLoading());  // Luôn emit TravelLoading khi load routes
      
      final user = _auth.currentUser;
      if (user == null) {
        emit(TravelEmpty());
        return;
      }

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      if (!userDoc.exists) {
        emit(TravelEmpty());
        return;
      }

      final userData = UserModel.fromMap(userDoc.data()!);
      final snapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .where('userId', isEqualTo: userData.userId)
          .get();

      final routes = snapshot.docs
          .map((doc) => TravelRouteModel.fromMap(doc.data()))
          .toList();

      if (routes.isEmpty) {
        emit(TravelEmpty());
      } else {
        emit(TravelLoaded(routes));  // Luôn emit TravelLoaded với routes
      }
    } catch (e) {
      emit(TravelEmpty());
    }
  }

  Future<void> _onAddRoute(AddTravelRoute event, Emitter<TravelState> emit) async {
    try {
      await _firestore
          .collection('TRAVEL_ROUTE')
          .doc(event.route.travelRouteId)
          .set(event.route.toMap());

      add(LoadTravelRoutes());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onDeleteRoute(DeleteTravelRoute event, Emitter<TravelState> emit) async {
    try {
      await _firestore
          .collection('TRAVEL_ROUTE')
          .doc(event.routeId)
          .delete();

      add(LoadTravelRoutes());
    } catch (e) {
      // Handle error
    }
  }

  Future<String> _generateRouteId() async {
    try {
      final snapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .orderBy('travelRouteId', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 'TR0001';
      }

      final lastRouteId = snapshot.docs.first['travelRouteId'] as String;
      final lastNumber = int.parse(lastRouteId.substring(2));
      final newNumber = lastNumber + 1;
      return 'TR${newNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      // Nếu có lỗi, tạo ID ngẫu nhiên
      return 'TR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  Future<void> _onAddDestinationToRoute(AddDestinationToRoute event, Emitter<TravelState> emit) async {
    try {
      if (event.existingRouteId != null) {
        final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.existingRouteId);
        
        // Lấy destinations của ngày hiện tại
        final currentDayDestinations = _currentRoute?.destinationsByDay[_currentDay] ?? [];
        
        // Update destinations cho ngày hiện tại
        await docRef.update({
          'destinationsByDay.$_currentDay': [...currentDayDestinations, event.destination.destinationId]
        });
        
        add(LoadRouteDestinations(event.existingRouteId!));
      } else {
        // Xử lý cho route tạm thời
        _tempDestinationsByDay[_currentDay] = [
          ...(_tempDestinationsByDay[_currentDay] ?? []),
          event.destination.destinationId
        ];

        // Load chỉ destinations của ngày hiện tại
        final destinations = await _loadDestinationsFromIds(
          _tempDestinationsByDay[_currentDay] ?? []
        );
        emit(RouteDetailLoaded(<TravelRouteModel>[], destinations));
      }
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onLoadRouteDestinations(LoadRouteDestinations event, Emitter<TravelState> emit) async {
    try {
      final List<TravelRouteModel> currentRoutes = (state is TravelLoaded) 
          ? (state as TravelLoaded).routes 
          : (state is RouteDetailState) 
              ? (state as RouteDetailState).routes 
              : <TravelRouteModel>[];

      emit(RouteDetailLoading(currentRoutes));

      final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.routeId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        emit(TravelError("Route not found"));
        return;
      }

      _currentRoute = TravelRouteModel.fromMap(doc.data()!);
      
      // Load destinations cho ngày hiện tại
      final currentDayDestinations = _currentRoute!.destinationsByDay[_currentDay] ?? [];
      final destinations = await _loadDestinationsFromIds(currentDayDestinations);
      
      emit(RouteDetailLoaded(currentRoutes, destinations));
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onCreateRoute(CreateTravelRoute event, Emitter<TravelState> emit) async {
    try {
      emit(TravelLoading());

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = await _firestore.collection('USER').doc(user.uid).get();
      if (!userDoc.exists) throw Exception('User data not found');
      
      final userData = UserModel.fromMap(userDoc.data()!);
      final routeId = await _generateRouteId();

      final newRoute = TravelRouteModel(
        travelRouteId: routeId,
        userId: userData.userId,
        routeName: event.routeName,
        province: event.province,
        createdDate: DateTime.now(),
        startDate: event.startDate,
        endDate: event.endDate,
        destinationsByDay: _tempDestinationsByDay,
      );

      print('Creating route with data: ${newRoute.toMap()}');

      // Đảm bảo ghi dữ liệu lên Firebase thành công
      await _firestore
          .collection('TRAVEL_ROUTE')
          .doc(routeId)
          .set(newRoute.toMap());

      print('Route created successfully with ID: $routeId');
      
      _tempDestinationsByDay = {};
      emit(TravelRouteCreated(routeId));
      
      // Load lại routes sau khi tạo thành công
      final snapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .where('userId', isEqualTo: userData.userId)
          .get();

      final routes = snapshot.docs
          .map((doc) => TravelRouteModel.fromMap(doc.data()))
          .toList();

      emit(TravelLoaded(routes));
    } catch (e) {
      print('Error creating route: $e');
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onStartRoute(StartTravelRoute event, Emitter<TravelState> emit) async {
    try {
      // Implement start route logic here
      // For example, update route status in Firebase
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onLoadDestinations(LoadDestinations event, Emitter<TravelState> emit) async {
    try {
      // Nếu đã có cache và cùng province, dùng lại
      if (_cachedDestinations != null) {
        emit(DestinationsLoaded(_cachedDestinations!));
        return;
      }

      emit(DestinationsLoading());
      
      final snapshot = await _firestore
          .collection('DESTINATION')
          .where('province', isEqualTo: event.province)
          .get();

      final destinations = snapshot.docs
          .map((doc) => DestinationModel.fromMap(doc.data()))
          .toList();

      _cachedDestinations = destinations; // Cache lại kết quả
      emit(DestinationsLoaded(destinations));
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  Future<List<DestinationModel>> _loadDestinationsFromIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final futures = ids.map((id) => 
      _firestore.collection('DESTINATION').doc(id).get()
    );
    
    final snapshots = await Future.wait(futures);
    final destinations = snapshots
        .where((doc) => doc.exists)
        .map((doc) {
          final destination = DestinationModel.fromMap(doc.data()!);
          print('Loaded destination: ${destination.destinationName}');
          return destination;
        })
        .toList();
    
    return destinations;
  }

  bool hasTemporaryData() {
    return _tempDestinationsByDay.isNotEmpty;
  }

  void clearTemporaryData() {
    _tempDestinationsByDay = {};
  }

  // Clear cache khi cần
  void clearDestinationsCache() {
    _cachedDestinations = null;
  }

  // Thêm method để reset route hiện tại
  void resetCurrentRoute() {
    _currentRoute = null;
  }

  void setCurrentDay(String day) {
    _currentDay = day;
    add(LoadTemporaryDestinations(day));
  }

  Future<void> _onLoadTemporaryDestinations(LoadTemporaryDestinations event, Emitter<TravelState> emit) async {
    final destinations = await _loadDestinationsFromIds(
      _tempDestinationsByDay[event.day] ?? []
    );
    
    final timeSlots = Map.fromEntries(
      destinations.asMap().entries.map((e) => 
        MapEntry(e.value.destinationId, TimeSlotManager.getTimeSlot(e.key))
      )
    );
    
    emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots));
  }
} 