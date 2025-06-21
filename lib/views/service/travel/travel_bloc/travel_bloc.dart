import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_event.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_state.dart';
import 'package:tourguideapp/models/travel_route_model.dart';
import 'package:tourguideapp/models/user_model.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/models/route_destination_model.dart';
import 'package:tourguideapp/core/utils/time_slot_manager.dart';

class TravelBloc extends Bloc<TravelEvent, TravelState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  Map<String, List<Map<String, dynamic>>> _tempDestinationsByDay = {};
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
    on<UpdateDestinationTime>(_onUpdateDestinationTime);
    on<UpdateDestinationDetails>(_onUpdateDestinationDetails);
    on<DeleteDestinationFromRoute>(_onDeleteDestinationFromRoute);
    on<UpdateTravelRoute>(_onUpdateTravelRoute);
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
      emit(TravelLoading()); 
      
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
        emit(TravelLoaded(routes));  
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

  Future<void> _onUpdateTravelRoute(UpdateTravelRoute event, Emitter<TravelState> emit) async {
    try {
      final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.travelRouteId);
      final updates = <String, dynamic>{
        'numberOfDays': event.numberOfDays
      };
      
      if (event.dayToDelete != null) {
        updates['destinationsByDay.${event.dayToDelete}'] = FieldValue.delete();
      }
      
      await docRef.update(updates);
      add(LoadRouteDestinations(event.travelRouteId));
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onAddDestinationToRoute(AddDestinationToRoute event, Emitter<TravelState> emit) async {
    try {
      if (event.existingRouteId != null) {
        final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.existingRouteId);
        
        // Load lại current route từ Firestore
        final doc = await docRef.get();
        if (!doc.exists) {
          emit(TravelError("Route not found"));
          return;
        }
        
        // Cập nhật _currentRoute với dữ liệu mới nhất
        _currentRoute = TravelRouteModel.fromMap(doc.data()!);
        
        // Lấy destinations của ngày hiện tại
        final currentDayDestinations = _currentRoute!.destinationsByDay[_currentDay] ?? [];
        
        // Tạo ID duy nhất cho lần thêm mới này
        final uniqueId = '${event.destination.destinationId}_${DateTime.now().millisecondsSinceEpoch}';
        
        // Tính thời gian dựa trên số lượng destinations hiện tại
        final startHour = 8 + (currentDayDestinations.length * 2);
        final endHour = startHour + 1;
        final startTime = '${startHour.toString().padLeft(2, '0')}:00';
        final endTime = '${endHour.toString().padLeft(2, '0')}:00';
        
        // Tạo danh sách destinations mới với các trường mới
        final updatedDestinations = List<Map<String, dynamic>>.from(currentDayDestinations);
        updatedDestinations.add({
          'destinationId': event.destination.destinationId,
          'uniqueId': uniqueId,
          'startTime': startTime,
          'endTime': endTime,
          'images': <String>[],
          'videos': <String>[],
          'notes': '',
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
        
        final destinations = await _loadDestinationsFromIds(destinationIds);
        
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
        
        // Tạo map destination details
        final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
          updatedDestinations.map((entry) => 
            MapEntry(entry['uniqueId'] as String, Map<String, dynamic>.from(entry))
          )
        );
        
        emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots, destinationDetails: destinationDetails));
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
        
        // Thêm destination mới vào cuối danh sách với các trường mới
        currentDayDestinations.add({
          'destinationId': event.destination.destinationId,
          'uniqueId': uniqueId,
          'startTime': startTime,
          'endTime': endTime,
          'images': <String>[],
          'videos': <String>[],
          'notes': '',
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
        
        // Tạo map destination details
        final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
          currentDayDestinations.map((entry) => 
            MapEntry(entry['uniqueId'] as String, Map<String, dynamic>.from(entry))
          )
        );
        
        emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots, destinationDetails: destinationDetails));
      }
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onLoadRouteDestinations(LoadRouteDestinations event, Emitter<TravelState> emit) async {
    try {      
      print('Loading route destinations for routeId: ${event.routeId}');
      print('Current day: $_currentDay');
      
      // Lấy routes hiện tại từ state
      List<TravelRouteModel> currentRoutes = [];
      if (state is TravelLoaded) {
        currentRoutes = (state as TravelLoaded).routes;
      } else if (state is RouteDetailState) {
        currentRoutes = (state as RouteDetailState).routes;
      }

      emit(RouteDetailLoading(currentRoutes));

      final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.routeId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        print('Route not found: ${event.routeId}');
        emit(TravelError("Route not found"));
        return;
      }

      final data = doc.data();
      if (data == null) {
        print('Route data is null for: ${event.routeId}');
        emit(TravelError("Route data is null"));
        return;
      }

      print('Raw Firestore data: $data');
      _currentRoute = TravelRouteModel.fromMap(data);
      print('Parsed route: ${_currentRoute!.routeName}');
      print('Destinations by day: ${_currentRoute!.destinationsByDay}');
      
      // Load destinations cho ngày hiện tại
      final currentDayDestinations = _currentRoute!.destinationsByDay[_currentDay] ?? [];
      print('Current day destinations: $currentDayDestinations');
      
      if (currentDayDestinations.isEmpty) {
        print('No destinations found for day: $_currentDay');
        emit(RouteDetailLoaded(currentRoutes, [], timeSlots: {}, destinationDetails: {}));
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
          final uniqueId = entry['uniqueId'] ?? 
            '${entry['destinationId']}_${DateTime.now().millisecondsSinceEpoch}';
          final startTime = entry['startTime'] ?? '08:00';
          final endTime = entry['endTime'] ?? '09:00';
          
          print('Creating time slot for $uniqueId: $startTime - $endTime');
          return MapEntry(
            uniqueId,
            TimeSlotManager.formatTimeRange(startTime, endTime)
          );
        })
      );
      
      // Tạo map destination details
      final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
        currentDayDestinations.map((entry) {
          final uniqueId = entry['uniqueId'] ?? 
            '${entry['destinationId']}_${DateTime.now().millisecondsSinceEpoch}';
          
          return MapEntry(uniqueId, Map<String, dynamic>.from(entry));
        })
      );
      
      print('Destination details: $destinationDetails');
      print('Time slots: $timeSlots');
      
      emit(RouteDetailLoaded(
        currentRoutes, 
        destinations, 
        timeSlots: timeSlots,
        destinationDetails: destinationDetails,
      ));
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
        numberOfDays: event.numberOfDays,
        destinationsByDay: _tempDestinationsByDay,
      );

      await _firestore
          .collection('TRAVEL_ROUTE')
          .doc(routeId)
          .set(newRoute.toMap());
      
      _tempDestinationsByDay = {};
      emit(TravelRouteCreated(routeId));
      
      final snapshot = await _firestore
          .collection('TRAVEL_ROUTE')
          .where('userId', isEqualTo: userData.userId)
          .get();

      final routes = snapshot.docs
          .map((doc) => TravelRouteModel.fromMap(doc.data()))
          .toList();

      emit(TravelLoaded(routes));
    } catch (e) {
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

    try {
      print('Loading destinations from IDs: $ids');
      
      // Sử dụng batch để load hiệu quả hơn
      final futures = ids.map((id) => 
        _firestore.collection('DESTINATION').doc(id).get()
      );
      
      final snapshots = await Future.wait(futures);
      final destinations = snapshots
          .where((doc) => doc.exists)
          .map((doc) {
            try {
              final destination = DestinationModel.fromMap(doc.data()!);
              print('Loaded destination: ${destination.destinationName}');
              return destination;
            } catch (e) {
              print('Error parsing destination ${doc.id}: $e');
              return null;
            }
          })
          .where((dest) => dest != null)
          .cast<DestinationModel>()
          .toList();
      
      print('Successfully loaded ${destinations.length} destinations');
      return destinations;
    } catch (e) {
      print('Error in _loadDestinationsFromIds: $e');
      return [];
    }
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
    print('Setting current day from $_currentDay to $day');
    _currentDay = day;
    
    // Kiểm tra xem có route hiện tại không
    if (_currentRoute != null) {
      print('Current route exists, loading route destinations');
      add(LoadRouteDestinations(_currentRoute!.travelRouteId));
    } else {
      print('No current route, loading temporary destinations');
      add(LoadTemporaryDestinations(day));
    }
  }

  Future<void> _onLoadTemporaryDestinations(LoadTemporaryDestinations event, Emitter<TravelState> emit) async {
    try {
      print('Loading temporary destinations for day: ${event.day}');
      print('Current temp destinations: $_tempDestinationsByDay');
      
      final currentDayDestinations = _tempDestinationsByDay[event.day] ?? [];
      print('Found ${currentDayDestinations.length} destinations for day ${event.day}');
      
      if (currentDayDestinations.isEmpty) {
        print('No temporary destinations found for day: ${event.day}');
        emit(RouteDetailLoaded(<TravelRouteModel>[], [], timeSlots: {}, destinationDetails: {}));
        return;
      }
      
      // Load tất cả destinations, kể cả trùng lặp
      final destinationIds = currentDayDestinations.map((entry) => 
        entry['destinationId'] as String
      ).toList();
      
      print('Loading destinations with IDs: $destinationIds');
      final destinations = await _loadDestinationsFromIds(destinationIds);
      print('Loaded ${destinations.length} destinations');
      
      final timeSlots = Map<String, String>.fromEntries(
        currentDayDestinations.map((entry) {
          final uniqueId = entry['uniqueId'] as String;
          final startTime = entry['startTime'] as String;
          final endTime = entry['endTime'] as String;
          
          print('Creating time slot for $uniqueId: $startTime - $endTime');
          return MapEntry(
            uniqueId,
            TimeSlotManager.formatTimeRange(startTime, endTime)
          );
        })
      );
      
      // Tạo map destination details
      final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
        currentDayDestinations.map((entry) => 
          MapEntry(entry['uniqueId'] as String, Map<String, dynamic>.from(entry))
        )
      );
      
      print('Temporary destinations loaded successfully');
      print('Time slots: $timeSlots');
      print('Destination details: $destinationDetails');
      
      emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots, destinationDetails: destinationDetails));
    } catch (e) {
      print('Error loading temporary destinations: $e');
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onUpdateDestinationTime(
    UpdateDestinationTime event,
    Emitter<TravelState> emit,
  ) async {
    try {
      List<Map<String, dynamic>> destinations;
      
      if (event.routeId != null) {
        // Cập nhật cho route đã tồn tại
        final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.routeId);
        final doc = await docRef.get();
        if (!doc.exists) {
          emit(TravelError("Route not found"));
          return;
        }
        
        _currentRoute = TravelRouteModel.fromMap(doc.data()!);
        destinations = List<Map<String, dynamic>>.from(
          _currentRoute!.destinationsByDay[event.currentDay] ?? []
        );
      } else {
        // Cập nhật cho route tạm thời
        destinations = List<Map<String, dynamic>>.from(
          _tempDestinationsByDay[event.currentDay] ?? []
        );
      }

      // Tìm và cập nhật thời gian cho địa điểm
      final index = destinations.indexWhere(
        (d) => d['uniqueId'] == event.uniqueId
      );
      
      if (index != -1) {
        final updatedDestination = Map<String, dynamic>.from(destinations[index]);
        updatedDestination['startTime'] = event.startTime;
        updatedDestination['endTime'] = event.endTime;
        destinations.removeAt(index);
        
        // Tìm vị trí phù hợp để chèn dựa trên thời gian bắt đầu
        int insertIndex = 0;
        for (int i = 0; i < destinations.length; i++) {
          final currentStartTime = destinations[i]['startTime'] ?? '00:00';
          if (_compareTime(event.startTime, currentStartTime) <= 0) {
            break;
          }
          insertIndex = i + 1;
        }
        
        destinations.insert(insertIndex, updatedDestination);
        
        // Cập nhật thời gian cho các địa điểm sau
        _updateFollowingDestinationsTimes(destinations, insertIndex + 1);

        if (event.routeId != null) {
          // Cập nhật lên Firestore
          await _firestore.collection('TRAVEL_ROUTE').doc(event.routeId).update({
            'destinationsByDay.${event.currentDay}': destinations,
          });
          
          // Load lại route details
          add(LoadRouteDestinations(event.routeId!));
        } else {
          // Cập nhật route tạm thời
          _tempDestinationsByDay[event.currentDay] = destinations;
          
          // Load lại destinations
          final destinationIds = destinations.map((d) => d['destinationId'] as String).toList();
          final updatedDestinations = await _loadDestinationsFromIds(destinationIds);
          
          // Tạo time slots mới
          final timeSlots = Map<String, String>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String,
              TimeSlotManager.formatTimeRange(
                entry['startTime'] as String,
                entry['endTime'] as String
              )
            ))
          );
          
          // Tạo map destination details
          final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String, 
              Map<String, dynamic>.from(entry)
            ))
          );
          
          emit(RouteDetailLoaded(<TravelRouteModel>[], updatedDestinations, timeSlots: timeSlots, destinationDetails: destinationDetails));
        }
      }
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  int _compareTime(String time1, String time2) {
    final parts1 = time1.split(':');
    final parts2 = time2.split(':');
    
    final hours1 = int.parse(parts1[0]);
    final hours2 = int.parse(parts2[0]);
    
    if (hours1 != hours2) {
      return hours1.compareTo(hours2);
    }
    
    final minutes1 = int.parse(parts1[1]);
    final minutes2 = int.parse(parts2[1]);
    return minutes1.compareTo(minutes2);
  }

  void _updateFollowingDestinationsTimes(List<Map<String, dynamic>> destinations, int startIndex) {
    for (int i = startIndex; i < destinations.length; i++) {
      if (i == 0) continue;
      
      final previousEnd = destinations[i - 1]['endTime'] ?? '00:00';
      final previousEndParts = previousEnd.split(':');
      var nextStartHour = int.parse(previousEndParts[0]);
      
      // Đặt thời gian bắt đầu của địa điểm tiếp theo là 1 tiếng sau thời gian kết thúc của địa điểm trước
      final startTime = '${nextStartHour.toString().padLeft(2, '0')}:${previousEndParts[1]}';
      final endTime = '${(nextStartHour + 1).toString().padLeft(2, '0')}:${previousEndParts[1]}';
      
      destinations[i]['startTime'] = startTime;
      destinations[i]['endTime'] = endTime;
    }
  }

  Future<void> _onDeleteDestinationFromRoute(
    DeleteDestinationFromRoute event,
    Emitter<TravelState> emit,
  ) async {
    try {
      if (event.routeId != null) {
        // Xóa khỏi route đã tồn tại
        final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.routeId);
        final doc = await docRef.get();
        if (!doc.exists) {
          emit(TravelError("Route not found"));
          return;
        }
        
        _currentRoute = TravelRouteModel.fromMap(doc.data()!);
        final destinations = List<Map<String, dynamic>>.from(
          _currentRoute!.destinationsByDay[event.currentDay] ?? []
        );

        // Tìm và xóa địa điểm
        destinations.removeWhere((d) => d['uniqueId'] == event.uniqueId);

        // Cập nhật thời gian cho các địa điểm còn lại
        _updateFollowingDestinationsTimes(destinations, 0);

        // Cập nhật lên Firestore
        await docRef.update({
          'destinationsByDay.${event.currentDay}': destinations,
        });

        // Load lại route details
        add(LoadRouteDestinations(event.routeId!));
      } else {
        // Xóa khỏi route tạm thời
        final destinations = List<Map<String, dynamic>>.from(
          _tempDestinationsByDay[event.currentDay] ?? []
        );

        // Tìm và xóa địa điểm
        destinations.removeWhere((d) => d['uniqueId'] == event.uniqueId);

        // Cập nhật thời gian cho các địa điểm còn lại
        _updateFollowingDestinationsTimes(destinations, 0);

        // Cập nhật route tạm thời
        _tempDestinationsByDay[event.currentDay] = destinations;

        // Load lại destinations
        final destinationIds = destinations.map((d) => d['destinationId'] as String).toList();
        final updatedDestinations = await _loadDestinationsFromIds(destinationIds);

        // Tạo time slots mới
        final timeSlots = Map<String, String>.fromEntries(
          destinations.map((entry) => MapEntry(
            entry['uniqueId'] as String,
            TimeSlotManager.formatTimeRange(
              entry['startTime'] as String,
              entry['endTime'] as String
            )
          ))
        );

        // Tạo map destination details
        final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
          destinations.map((entry) => MapEntry(
            entry['uniqueId'] as String, 
            Map<String, dynamic>.from(entry)
          ))
        );

        emit(RouteDetailLoaded(<TravelRouteModel>[], updatedDestinations, timeSlots: timeSlots, destinationDetails: destinationDetails));
      }
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  void deleteTemporaryDay(String day) {
    _tempDestinationsByDay.remove(day);
  }

  bool hasDestinationsForDay(String day) {
    return _tempDestinationsByDay.containsKey(day);
  }

  void moveTemporaryDestinations(String fromDay, String toDay) {
    if (_tempDestinationsByDay.containsKey(fromDay)) {
      _tempDestinationsByDay[toDay] = _tempDestinationsByDay[fromDay]!;
      _tempDestinationsByDay.remove(fromDay);
    }
  }

  Future<void> _onUpdateDestinationDetails(
    UpdateDestinationDetails event,
    Emitter<TravelState> emit,
  ) async {
    try {
      
      List<Map<String, dynamic>> destinations;
      
      if (event.routeId != null) {
        // Cập nhật cho route đã tồn tại
        final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.routeId);
        final doc = await docRef.get();
        if (!doc.exists) {
          emit(const TravelError("Route not found"));
          return;
        }
        
        _currentRoute = TravelRouteModel.fromMap(doc.data()!);
        destinations = List<Map<String, dynamic>>.from(
          _currentRoute!.destinationsByDay[event.currentDay] ?? []
        );
      } else {
        // Cập nhật cho route tạm thời
        destinations = List<Map<String, dynamic>>.from(
          _tempDestinationsByDay[event.currentDay] ?? []
        );
      }

      print('Found ${destinations.length} destinations for day: ${event.currentDay}');

      // Tìm và cập nhật thông tin chi tiết cho địa điểm
      final index = destinations.indexWhere(
        (d) => d['uniqueId'] == event.uniqueId
      );
      
      print('Found destination at index: $index');
      
      if (index != -1) {
        final updatedDestination = Map<String, dynamic>.from(destinations[index]);
        print('Current destination data: $updatedDestination');
        
        // Cập nhật các trường mới nếu được cung cấp
        if (event.images != null) {
          updatedDestination['images'] = event.images;
          print('Updated images: ${updatedDestination['images']}');
        }
        if (event.videos != null) {
          updatedDestination['videos'] = event.videos;
          print('Updated videos: ${updatedDestination['videos']}');
        }
        if (event.notes != null) {
          updatedDestination['notes'] = event.notes;
          print('Updated notes: ${updatedDestination['notes']}');
        }
        
        destinations[index] = updatedDestination;
        print('Final destination data: ${destinations[index]}');

        if (event.routeId != null) {
          // Cập nhật lên Firestore
          print('Updating Firestore with data: $destinations');
          await _firestore.collection('TRAVEL_ROUTE').doc(event.routeId).update({
            'destinationsByDay.${event.currentDay}': destinations,
          });
          
          print('Firestore update completed');
          
          // Load lại route details
          add(LoadRouteDestinations(event.routeId!));
        } else {
          // Cập nhật route tạm thời
          _tempDestinationsByDay[event.currentDay] = destinations;
          
          // Load lại destinations
          final destinationIds = destinations.map((d) => d['destinationId'] as String).toList();
          final updatedDestinations = await _loadDestinationsFromIds(destinationIds);
          
          // Tạo time slots mới
          final timeSlots = Map<String, String>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String,
              TimeSlotManager.formatTimeRange(
                entry['startTime'] as String,
                entry['endTime'] as String
              )
            ))
          );
          
          // Tạo map destination details
          final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String, 
              Map<String, dynamic>.from(entry)
            ))
          );
          
          emit(RouteDetailLoaded(<TravelRouteModel>[], updatedDestinations, timeSlots: timeSlots, destinationDetails: destinationDetails));
        }
      } else {
        print('Destination not found with uniqueId: ${event.uniqueId}');
      }
    } catch (e) {
      print('Error updating destination details: $e');
      emit(TravelError(e.toString()));
    }
  }

  // Getter để truy cập current route từ bên ngoài
  TravelRouteModel? get currentRoute => _currentRoute;

  // Method để debug state hiện tại
  void debugCurrentState() {
    print('=== DEBUG CURRENT STATE ===');
    print('Current state type: ${state.runtimeType}');
    print('Current day: $_currentDay');
    print('Current route: ${_currentRoute?.routeName ?? 'null'}');
    print('Temp destinations: $_tempDestinationsByDay');
    
    if (state is RouteDetailState) {
      final routeState = state as RouteDetailState;
      print('Routes count: ${routeState.routes.length}');
      print('Destinations count: ${routeState.destinations.length}');
      print('Time slots count: ${routeState.timeSlots?.length ?? 0}');
      print('Destination details count: ${routeState.destinationDetails?.length ?? 0}');
    }
    print('=== END DEBUG ===');
  }

  // Method để reset state khi cần
  void resetState() {
    _currentRoute = null;
    _tempDestinationsByDay = {};
    _cachedDestinations = null;
    _currentDay = 'Day 1';
  }

  // Method để kiểm tra xem có dữ liệu không
  bool hasData() {
    if (state is RouteDetailState) {
      final routeState = state as RouteDetailState;
      return routeState.destinations.isNotEmpty;
    }
    return false;
  }

  // Method để force reload dữ liệu
  void forceReload() {
    print('Force reloading data...');
    debugCurrentState();
    
    if (_currentRoute != null) {
      print('Force reloading route destinations');
      add(LoadRouteDestinations(_currentRoute!.travelRouteId));
    } else {
      print('Force reloading temporary destinations');
      add(LoadTemporaryDestinations(_currentDay));
    }
  }

  // Method để kiểm tra và sửa lỗi dữ liệu
  void validateAndFixData() {
    print('Validating and fixing data...');
    
    if (_currentRoute != null) {
      final destinationsByDay = _currentRoute!.destinationsByDay;
      print('Route destinations by day: $destinationsByDay');
      
      // Kiểm tra xem ngày hiện tại có tồn tại không
      if (!destinationsByDay.containsKey(_currentDay)) {
        print('Current day $_currentDay not found in route, creating empty list');
        destinationsByDay[_currentDay] = [];
      }
    }
    
    // Kiểm tra temp destinations
    if (!_tempDestinationsByDay.containsKey(_currentDay)) {
      print('Current day $_currentDay not found in temp destinations, creating empty list');
      _tempDestinationsByDay[_currentDay] = [];
    }
  }
} 