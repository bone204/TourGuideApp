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
  Map<String, List<Map<String, String?>>> _tempDestinationsByDay = {};
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
        print('Adding destination to existing route: ${event.existingRouteId}');
        final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.existingRouteId);
        
        // Load lại current route từ Firestore
        final doc = await docRef.get();
        if (!doc.exists) {
          print('Route not found');
          emit(TravelError("Route not found"));
          return;
        }
        
        // Cập nhật _currentRoute với dữ liệu mới nhất
        _currentRoute = TravelRouteModel.fromMap(doc.data()!);
        print('Current route loaded: ${_currentRoute?.routeName}');
        
        // Lấy destinations của ngày hiện tại
        final currentDayDestinations = _currentRoute!.destinationsByDay[_currentDay] ?? [];
        print('Current day destinations: $currentDayDestinations');
        
        // Tạo ID duy nhất cho lần thêm mới này
        final uniqueId = '${event.destination.destinationId}_${DateTime.now().millisecondsSinceEpoch}';
        
        // Tính thời gian dựa trên số lượng destinations hiện tại
        final startHour = 8 + (currentDayDestinations.length * 2);
        final endHour = startHour + 1;
        final startTime = '${startHour.toString().padLeft(2, '0')}:00';
        final endTime = '${endHour.toString().padLeft(2, '0')}:00';
        
        print('Adding destination with time: $startTime - $endTime');
        
        // Tạo danh sách destinations mới
        final updatedDestinations = List<Map<String, String>>.from(currentDayDestinations);
        updatedDestinations.add({
          'destinationId': event.destination.destinationId,
          'uniqueId': uniqueId,
          'startTime': startTime,
          'endTime': endTime
        });
        
        // Update destinations cho ngày hiện tại
        await docRef.update({
          'destinationsByDay.$_currentDay': updatedDestinations
        });
        
        // Load lại toàn bộ destinations với thời gian đã lưu
        final updatedDoc = await docRef.get();
        _currentRoute = TravelRouteModel.fromMap(updatedDoc.data()!);
        
        // Load tất cả destinations của ngày hiện tại
        final destinationIds = updatedDestinations.map((entry) => 
          entry['destinationId'] as String
        ).toList();
        
        print('Loading destinations with IDs: $destinationIds');
        final destinations = await _loadDestinationsFromIds(destinationIds);
        print('Loaded ${destinations.length} destinations');
        
        // Tạo map time slots từ dữ liệu đã lưu
        final timeSlots = Map<String, String>.fromEntries(
          updatedDestinations.map((entry) => 
            MapEntry(
              entry['uniqueId'] as String,
              TimeSlotManager.formatTimeRange(
                entry['startTime'] as String,
                entry['endTime'] as String
              )
            )
          )
        );
        
        print('Updated timeSlots: $timeSlots');
        emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots));
      } else {
        // Xử lý cho route tạm thời
        final currentDayDestinations = _tempDestinationsByDay[_currentDay] ?? [];
        
        // Tạo ID duy nhất cho lần thêm mới này
        final uniqueId = '${event.destination.destinationId}_${DateTime.now().millisecondsSinceEpoch}';
        
        // Tính thời gian dựa trên số lượng destinations hiện tại
        final startHour = 8 + (currentDayDestinations.length * 2);
        final endHour = startHour + 1;
        final startTime = '${startHour.toString().padLeft(2, '0')}:00';
        final endTime = '${endHour.toString().padLeft(2, '0')}:00';
        
        print('Adding temporary destination with time: $startTime - $endTime');
        
        // Thêm destination mới vào cuối danh sách
        currentDayDestinations.add({
          'destinationId': event.destination.destinationId,
          'uniqueId': uniqueId,
          'startTime': startTime,
          'endTime': endTime
        });
        
        _tempDestinationsByDay[_currentDay] = currentDayDestinations;

        // Load destinations của ngày hiện tại
        final destinationIds = currentDayDestinations.map((entry) => 
          entry['destinationId'] as String
        ).toList();
        
        final destinations = await _loadDestinationsFromIds(destinationIds);
        
        // Tạo map time slots cho destinations
        final timeSlots = Map<String, String>.fromEntries(
          currentDayDestinations.map((entry) => 
            MapEntry(
              entry['uniqueId'] as String,
              TimeSlotManager.formatTimeRange(
                entry['startTime'] as String,
                entry['endTime'] as String
              )
            )
          )
        );
        
        print('Updated temporary timeSlots: $timeSlots');
        emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots));
      }
    } catch (e) {
      print('Error adding destination: $e');
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onLoadRouteDestinations(LoadRouteDestinations event, Emitter<TravelState> emit) async {
    try {
      print('Loading route destinations for route ID: ${event.routeId}');
      
      final List<TravelRouteModel> currentRoutes = (state is TravelLoaded) 
          ? (state as TravelLoaded).routes 
          : (state is RouteDetailState) 
              ? (state as RouteDetailState).routes 
              : <TravelRouteModel>[];

      emit(RouteDetailLoading(currentRoutes));

      final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.routeId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        print('Route not found in Firestore');
        emit(TravelError("Route not found"));
        return;
      }

      final data = doc.data();
      if (data == null) {
        print('Route data is null');
        emit(TravelError("Route data is null"));
        return;
      }

      _currentRoute = TravelRouteModel.fromMap(data);
      print('Current route loaded: ${_currentRoute?.routeName}');
      
      // Load destinations cho ngày hiện tại
      final currentDayDestinations = _currentRoute!.destinationsByDay[_currentDay] ?? [];
      print('Current day destinations: $currentDayDestinations');
      
      if (currentDayDestinations.isEmpty) {
        print('No destinations found for current day');
        emit(RouteDetailLoaded(currentRoutes, [], timeSlots: {}));
        return;
      }
      
      // Load tất cả destinations, kể cả trùng lặp
      final destinationIds = currentDayDestinations.map((entry) => 
        entry['destinationId'] as String
      ).toList();
      
      print('Loading destinations with IDs: $destinationIds');
      final destinations = await _loadDestinationsFromIds(destinationIds);
      print('Loaded ${destinations.length} destinations');
      
      // Tạo map time slots cho destinations
      final timeSlots = Map<String, String>.fromEntries(
        currentDayDestinations.map((entry) {
          final uniqueId = entry['uniqueId'] as String? ?? 
            '${entry['destinationId']}_${DateTime.now().millisecondsSinceEpoch}';
          final startTime = entry['startTime'] as String? ?? '08:00';
          final endTime = entry['endTime'] as String? ?? '09:00';
          
          return MapEntry(
            uniqueId,
            TimeSlotManager.formatTimeRange(startTime, endTime)
          );
        })
      );
      
      print('Generated timeSlots: $timeSlots');
      
      emit(RouteDetailLoaded(currentRoutes, destinations, timeSlots: timeSlots));
    } catch (e) {
      print('Error loading route destinations: $e');
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
    final currentDayDestinations = _tempDestinationsByDay[event.day] ?? [];
    
    // Load tất cả destinations, kể cả trùng lặp
    final destinationIds = currentDayDestinations.map((entry) => 
      entry['destinationId'] as String
    ).toList();
        
    final destinations = await _loadDestinationsFromIds(destinationIds);
    
    final timeSlots = Map<String, String>.fromEntries(
      currentDayDestinations.map((entry) => 
        MapEntry(
          entry['uniqueId'] as String, // Sử dụng uniqueId thay vì destinationId
          TimeSlotManager.formatTimeRange(
            entry['startTime'] as String,
            entry['endTime'] as String
          )
        )
      )
    );
    
    emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots));
  }
} 