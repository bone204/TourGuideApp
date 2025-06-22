import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_event.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_state.dart';
import 'package:tourguideapp/models/travel_route_model.dart';
import 'package:tourguideapp/models/user_model.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/core/utils/time_slot_manager.dart';
import 'package:collection/collection.dart';

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
    
    // Thêm các event handlers mới
    on<ValidateTimeSlots>(_onValidateTimeSlots);
    on<AutoAdjustTimeSlots>(_onAutoAdjustTimeSlots);
    on<SuggestTimeAdjustment>(_onSuggestTimeAdjustment);
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
      if (event.endDate != null) {
        updates['endDate'] = event.endDate;
      }
      if (event.startDate != null) {
        updates['startDate'] = event.startDate;
      }
      await docRef.update(updates);

      // Sau khi xóa, cập nhật lại key các ngày còn lại cho liên tục (Day 1, Day 2, ...)
      if (event.dayToDelete != null) {
        final doc = await docRef.get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final destinationsByDay = Map<String, dynamic>.from(data['destinationsByDay'] ?? {});
          // Lấy danh sách ngày, sort theo số thứ tự
          final sortedDays = destinationsByDay.keys.toList()
            ..sort((a, b) {
              final aNum = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              final bNum = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              return aNum.compareTo(bNum);
            });
          final newDestinationsByDay = <String, dynamic>{};
          for (int i = 0; i < sortedDays.length; i++) {
            newDestinationsByDay['Day ${i + 1}'] = destinationsByDay[sortedDays[i]];
          }
          await docRef.update({'destinationsByDay': newDestinationsByDay});
        }
      }
      add(LoadRouteDestinations(event.travelRouteId));
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onAddDestinationToRoute(AddDestinationToRoute event, Emitter<TravelState> emit) async {
    try {
      const int durationMinutes = 60; // Thời lượng mỗi địa điểm (có thể cho user chọn)
      if (event.existingRouteId != null) {
        final docRef = _firestore.collection('TRAVEL_ROUTE').doc(event.existingRouteId);
        final doc = await docRef.get();
        if (!doc.exists) {
          emit(TravelError("Route not found"));
          return;
        }
        _currentRoute = TravelRouteModel.fromMap(doc.data()!);
        final currentDayDestinations = _currentRoute!.destinationsByDay[_currentDay] ?? [];
        // Sắp xếp theo startTime
        final updatedDestinations = List<Map<String, dynamic>>.from(currentDayDestinations);
        updatedDestinations.sort((a, b) => _compareTime(a['startTime'], b['startTime']));
        // Tìm khoảng trống
        String? insertStartTime;
        String? insertEndTime;
        int insertIndex = 0;
        String prevEnd = '08:00';
        for (int i = 0; i <= updatedDestinations.length; i++) {
          String nextStart;
          if (i < updatedDestinations.length) {
            nextStart = updatedDestinations[i]['startTime'];
          } else {
            nextStart = '23:59';
          }
          int prevEndMinutes = _timeToMinutes(prevEnd);
          int nextStartMinutes = _timeToMinutes(nextStart);
          if (nextStartMinutes - prevEndMinutes >= durationMinutes) {
            insertStartTime = _minutesToTime(prevEndMinutes);
            insertEndTime = _minutesToTime(prevEndMinutes + durationMinutes);
            insertIndex = i;
            break;
          }
          if (i < updatedDestinations.length) {
            prevEnd = updatedDestinations[i]['endTime'];
          }
        }
        if (insertStartTime == null || insertEndTime == null) {
          emit(TravelError("Không còn khoảng thời gian trống trong ngày để thêm địa điểm mới!"));
          return;
        }
        final uniqueId = '${event.destination.destinationId}_${DateTime.now().millisecondsSinceEpoch}';
        final newDestination = {
          'destinationId': event.destination.destinationId,
          'uniqueId': uniqueId,
          'startTime': insertStartTime,
          'endTime': insertEndTime,
          'images': <String>[],
          'videos': <String>[],
          'notes': '',
        };
        updatedDestinations.insert(insertIndex, newDestination);
        updatedDestinations.sort((a, b) => _compareTime(a['startTime'], b['startTime']));
        await docRef.update({
          'destinationsByDay.$_currentDay': updatedDestinations
        });
        // Sau khi thêm mới, luôn reload lại từ Firestore để UI cập nhật ngay
        add(LoadRouteDestinations(event.existingRouteId!));
        return;
      } else {
        final currentDayDestinations = _tempDestinationsByDay[_currentDay] ?? [];
        final updatedDestinations = List<Map<String, dynamic>>.from(currentDayDestinations);
        updatedDestinations.sort((a, b) => _compareTime(a['startTime'], b['startTime']));
        String? insertStartTime;
        String? insertEndTime;
        int insertIndex = 0;
        String prevEnd = '08:00';
        for (int i = 0; i <= updatedDestinations.length; i++) {
          String nextStart;
          if (i < updatedDestinations.length) {
            nextStart = updatedDestinations[i]['startTime'];
          } else {
            nextStart = '23:59';
          }
          int prevEndMinutes = _timeToMinutes(prevEnd);
          int nextStartMinutes = _timeToMinutes(nextStart);
          if (nextStartMinutes - prevEndMinutes >= durationMinutes) {
            insertStartTime = _minutesToTime(prevEndMinutes);
            insertEndTime = _minutesToTime(prevEndMinutes + durationMinutes);
            insertIndex = i;
            break;
          }
          if (i < updatedDestinations.length) {
            prevEnd = updatedDestinations[i]['endTime'];
          }
        }
        if (insertStartTime == null || insertEndTime == null) {
          emit(TravelError("Không còn khoảng thời gian trống trong ngày để thêm địa điểm mới!"));
          return;
        }
        final uniqueId = '${event.destination.destinationId}_${DateTime.now().millisecondsSinceEpoch}';
        final newDestination = {
          'destinationId': event.destination.destinationId,
          'uniqueId': uniqueId,
          'startTime': insertStartTime,
          'endTime': insertEndTime,
          'images': <String>[],
          'videos': <String>[],
          'notes': '',
        };
        updatedDestinations.insert(insertIndex, newDestination);
        updatedDestinations.sort((a, b) => _compareTime(a['startTime'], b['startTime']));
        _tempDestinationsByDay[_currentDay] = updatedDestinations;
        final destinationIds = updatedDestinations.map((entry) => entry['destinationId'] as String).toList();
        final destinations = await _loadDestinationsFromIds(destinationIds);
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
        final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
          updatedDestinations.map((entry) =>
            MapEntry(entry['uniqueId'] as String, Map<String, dynamic>.from(entry))
          )
        );
        // Mapping destinationWithIds đúng thứ tự xuất hiện trong updatedDestinations
        final List<Map<String, dynamic>> destinationWithIds = [];
        for (final entry in updatedDestinations) {
          if (entry['uniqueId'] != null && entry['destinationId'] != null) {
            final dest = destinations.firstWhereOrNull(
              (d) => d.destinationId == entry['destinationId'],
            );
            if (dest != null) {
              destinationWithIds.add({
                'destination': dest,
                'uniqueId': entry['uniqueId'],
                'startTime': entry['startTime'],
                'endTime': entry['endTime'],
              });
            }
          }
        }
        // Sort theo startTime tăng dần
        destinationWithIds.sort((a, b) {
          final t1 = (a['startTime'] ?? '') as String;
          final t2 = (b['startTime'] ?? '') as String;
          return t1.compareTo(t2);
        });
        print('destinationWithIds: ' + destinationWithIds.map((e) => e['uniqueId']).toList().toString());
        emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots, destinationDetails: destinationDetails, destinationWithIds: destinationWithIds));
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
        currentDayDestinations.where((entry) {
          if (entry['startTime'] == null || entry['endTime'] == null) {
            print('LỖI: Địa điểm thiếu trường startTime hoặc endTime: $entry');
            return false;
          }
          if (entry['uniqueId'] == null) {
            print('LỖI: Địa điểm thiếu uniqueId: $entry');
            return false;
          }
          return true;
        }).map((entry) {
          final uniqueId = entry['uniqueId'] as String;
          final startTime = entry['startTime'];
          final endTime = entry['endTime'];
          return MapEntry(
            uniqueId,
            TimeSlotManager.formatTimeRange(startTime, endTime)
          );
        })
      );
      
      // Tạo map destination details
      final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
        currentDayDestinations.where((entry) {
          if (entry['startTime'] == null || entry['endTime'] == null) {
            print('LỖI: Địa điểm thiếu trường startTime hoặc endTime: $entry');
            return false;
          }
          if (entry['uniqueId'] == null) {
            print('LỖI: Địa điểm thiếu uniqueId: $entry');
            return false;
          }
          return true;
        }).map((entry) {
          final uniqueId = entry['uniqueId'] as String;
          return MapEntry(uniqueId, Map<String, dynamic>.from(entry));
        })
      );
      
      print('Destination details: $destinationDetails');
      print('Time slots: $timeSlots');
      
      // Mapping destinationWithIds đúng thứ tự xuất hiện trong currentDayDestinations
      final List<Map<String, dynamic>> destinationWithIds = [];
      for (final entry in currentDayDestinations) {
        if (entry['uniqueId'] != null && entry['destinationId'] != null) {
          final dest = destinations.firstWhereOrNull(
            (d) => d.destinationId == entry['destinationId'],
          );
          if (dest != null) {
            destinationWithIds.add({
              'destination': dest,
              'uniqueId': entry['uniqueId'],
              'startTime': entry['startTime'],
              'endTime': entry['endTime'],
            });
          }
        }
      }
      // Sort theo startTime tăng dần
      destinationWithIds.sort((a, b) {
        final t1 = (a['startTime'] ?? '') as String;
        final t2 = (b['startTime'] ?? '') as String;
        return t1.compareTo(t2);
      });
      print('destinationWithIds: ' + destinationWithIds.map((e) => e['uniqueId']).toList().toString());
      emit(RouteDetailLoaded(
        currentRoutes, 
        destinations, 
        timeSlots: timeSlots,
        destinationDetails: destinationDetails,
        destinationWithIds: destinationWithIds,
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
      print('Creating new route with ID: $routeId');
      print('Temporary destinations: $_tempDestinationsByDay');
      final newRoute = TravelRouteModel(
        travelRouteId: routeId,
        userId: userData.userId,
        routeName: event.routeName,
        province: event.province,
        createdDate: DateTime.now(),
        numberOfDays: event.numberOfDays,
        destinationsByDay: _tempDestinationsByDay,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      print('Saving route to Firebase with destinations: [38;5;2m${newRoute.destinationsByDay}[0m');
      await _firestore
          .collection('TRAVEL_ROUTE')
          .doc(routeId)
          .set(newRoute.toMap());
      print('Route saved successfully to Firebase');
      // Clear temporary data after successful save
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
      // Luôn clone list để tránh reference bug
      final currentDayDestinations = List<Map<String, dynamic>>.from(_tempDestinationsByDay[event.day] ?? []);
      print('Found [38;5;2m${currentDayDestinations.length}[0m destinations for day ${event.day}');
      // Load tất cả destinations, kể cả trùng lặp
      final destinationIds = currentDayDestinations.map((entry) => entry['destinationId'] as String).toList();
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
      // Tạo map destination details từ dữ liệu tạm thời
      final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
        currentDayDestinations.map((entry) {
          final uniqueId = entry['uniqueId'] as String;
          print('Creating destination details for $uniqueId: $entry');
          return MapEntry(uniqueId, Map<String, dynamic>.from(entry));
        })
      );
      print('Temporary destinations loaded successfully');
      print('Time slots: $timeSlots');
      print('Destination details: $destinationDetails');
      // Mapping destinationWithIds đúng thứ tự xuất hiện trong currentDayDestinations
      final List<Map<String, dynamic>> destinationWithIds = [];
      for (final entry in currentDayDestinations) {
        if (entry['uniqueId'] != null && entry['destinationId'] != null) {
          final dest = destinations.firstWhereOrNull(
            (d) => d.destinationId == entry['destinationId'],
          );
          if (dest != null) {
            destinationWithIds.add({
              'destination': dest,
              'uniqueId': entry['uniqueId'],
              'startTime': entry['startTime'],
              'endTime': entry['endTime'],
            });
          }
        }
      }
      // Sort theo startTime tăng dần
      destinationWithIds.sort((a, b) {
        final t1 = (a['startTime'] ?? '') as String;
        final t2 = (b['startTime'] ?? '') as String;
        return t1.compareTo(t2);
      });
      emit(RouteDetailLoaded(<TravelRouteModel>[], destinations, timeSlots: timeSlots, destinationDetails: destinationDetails, destinationWithIds: destinationWithIds));
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
        // Luôn lấy lại dữ liệu mới nhất từ Firestore
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
        destinations = List<Map<String, dynamic>>.from(
          _tempDestinationsByDay[event.currentDay] ?? []
        );
      }
      final index = destinations.indexWhere(
        (d) => d['uniqueId'] == event.uniqueId
      );
      if (index != -1) {
        final hasConflict = _checkTimeConflict(destinations, index, event.startTime, event.endTime);
        if (hasConflict) {
          emit(TravelError("Thời gian bị xung đột với địa điểm khác. Vui lòng chọn thời gian khác."));
          // Không update gì local, chỉ báo lỗi
          if (event.routeId != null) {
            add(LoadRouteDestinations(event.routeId!));
          }
          return;
        }
        final updatedDestination = Map<String, dynamic>.from(destinations[index]);
        updatedDestination['startTime'] = event.startTime;
        updatedDestination['endTime'] = event.endTime;
        destinations[index] = updatedDestination;
        destinations.sort((a, b) => _compareTime(a['startTime'], b['startTime']));
        if (event.routeId != null) {
          await _firestore.collection('TRAVEL_ROUTE').doc(event.routeId).update({
            'destinationsByDay.${event.currentDay}': destinations,
          });
          // Luôn reload lại từ Firestore
          add(LoadRouteDestinations(event.routeId!));
        } else {
          _tempDestinationsByDay[event.currentDay] = destinations;
          final destinationIds = destinations.map((d) => d['destinationId'] as String).toList();
          final updatedDestinations = await _loadDestinationsFromIds(destinationIds);
          final timeSlots = Map<String, String>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String,
              TimeSlotManager.formatTimeRange(
                entry['startTime'] as String,
                entry['endTime'] as String
              )
            ))
          );
          final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String, 
              Map<String, dynamic>.from(entry)
            ))
          );
          // Mapping destinationWithIds đúng thứ tự xuất hiện trong destinations
          final List<Map<String, dynamic>> destinationWithIds = [];
          for (final entry in destinations) {
            if (entry['uniqueId'] != null && entry['destinationId'] != null) {
              final dest = updatedDestinations.firstWhereOrNull(
                (d) => d.destinationId == entry['destinationId'],
              );
              if (dest != null) {
                destinationWithIds.add({
                  'destination': dest,
                  'uniqueId': entry['uniqueId'],
                  'startTime': entry['startTime'],
                  'endTime': entry['endTime'],
                });
              }
            }
          }
          // Sort theo startTime tăng dần
          destinationWithIds.sort((a, b) {
            final t1 = (a['startTime'] ?? '') as String;
            final t2 = (b['startTime'] ?? '') as String;
            return t1.compareTo(t2);
          });
          emit(RouteDetailLoaded(<TravelRouteModel>[], updatedDestinations, timeSlots: timeSlots, destinationDetails: destinationDetails, destinationWithIds: destinationWithIds));
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

        // Mapping destinationWithIds đúng thứ tự xuất hiện trong destinations
        final List<Map<String, dynamic>> destinationWithIds = [];
        for (final entry in destinations) {
          if (entry['uniqueId'] != null && entry['destinationId'] != null) {
            final dest = updatedDestinations.firstWhereOrNull(
              (d) => d.destinationId == entry['destinationId'],
            );
            if (dest != null) {
              destinationWithIds.add({
                'destination': dest,
                'uniqueId': entry['uniqueId'],
                'startTime': entry['startTime'],
                'endTime': entry['endTime'],
              });
            }
          }
        }
        // Sort theo startTime tăng dần
        destinationWithIds.sort((a, b) {
          final t1 = (a['startTime'] ?? '') as String;
          final t2 = (b['startTime'] ?? '') as String;
          return t1.compareTo(t2);
        });
        emit(RouteDetailLoaded(<TravelRouteModel>[], updatedDestinations, timeSlots: timeSlots, destinationDetails: destinationDetails, destinationWithIds: destinationWithIds));
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
        // Luôn lấy lại dữ liệu mới nhất từ Firestore
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
        destinations = List<Map<String, dynamic>>.from(
          _tempDestinationsByDay[event.currentDay] ?? []
        );
      }
      print('Found ${destinations.length} destinations for day: ${event.currentDay}');
      final index = destinations.indexWhere(
        (d) => d['uniqueId'] == event.uniqueId
      );
      print('Found destination at index: $index');
      if (index != -1) {
        final updatedDestination = Map<String, dynamic>.from(destinations[index]);
        print('Current destination data: $updatedDestination');
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
          print('Will update Firestore routeId=${event.routeId}, day=${event.currentDay}, data=${destinations}');
          await _firestore.collection('TRAVEL_ROUTE').doc(event.routeId).update({
            'destinationsByDay.${event.currentDay}': destinations,
          });
          print('Firestore update completed for routeId=${event.routeId}, day=${event.currentDay}');
          // Luôn reload lại từ Firestore
          add(LoadRouteDestinations(event.routeId!));
        } else {
          _tempDestinationsByDay[event.currentDay] = destinations;
          print('Updated temporary destinations for day ${event.currentDay}: ${_tempDestinationsByDay[event.currentDay]}');
          final destinationIds = destinations.map((d) => d['destinationId'] as String).toList();
          final updatedDestinations = await _loadDestinationsFromIds(destinationIds);
          final timeSlots = Map<String, String>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String,
              TimeSlotManager.formatTimeRange(
                entry['startTime'] as String,
                entry['endTime'] as String
              )
            ))
          );
          final destinationDetails = Map<String, Map<String, dynamic>>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String, 
              Map<String, dynamic>.from(entry)
            ))
          );
          // Mapping destinationWithIds đúng thứ tự xuất hiện trong destinations
          final List<Map<String, dynamic>> destinationWithIds = [];
          for (final entry in destinations) {
            if (entry['uniqueId'] != null && entry['destinationId'] != null) {
              final dest = updatedDestinations.firstWhereOrNull(
                (d) => d.destinationId == entry['destinationId'],
              );
              if (dest != null) {
                destinationWithIds.add({
                  'destination': dest,
                  'uniqueId': entry['uniqueId'],
                  'startTime': entry['startTime'],
                  'endTime': entry['endTime'],
                });
              }
            }
          }
          // Sort theo startTime tăng dần
          destinationWithIds.sort((a, b) {
            final t1 = (a['startTime'] ?? '') as String;
            final t2 = (b['startTime'] ?? '') as String;
            return t1.compareTo(t2);
          });
          emit(RouteDetailLoaded(<TravelRouteModel>[], updatedDestinations, timeSlots: timeSlots, destinationDetails: destinationDetails, destinationWithIds: destinationWithIds));
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

  // Method để kiểm tra xung đột thời gian khi cập nhật
  bool _checkTimeConflict(List<Map<String, dynamic>> destinations, int currentIndex, String newStartTime, String newEndTime) {
    for (int i = 0; i < destinations.length; i++) {
      if (i == currentIndex) continue; // Bỏ qua địa điểm hiện tại
      
      final otherDestination = destinations[i];
      final otherStartTime = otherDestination['startTime'] as String;
      final otherEndTime = otherDestination['endTime'] as String;
      
      if (_hasTimeConflict(newStartTime, newEndTime, otherStartTime, otherEndTime)) {
        return true; // Có xung đột
      }
    }
    return false; // Không có xung đột
  }

  // Event handlers mới cho việc xử lý xung đột thời gian
  Future<void> _onValidateTimeSlots(ValidateTimeSlots event, Emitter<TravelState> emit) async {
    try {
      List<Map<String, dynamic>> destinations;
      
      if (event.routeId != null) {
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
        destinations = List<Map<String, dynamic>>.from(
          _tempDestinationsByDay[event.currentDay] ?? []
        );
      }

      // Kiểm tra xung đột thời gian
      final conflicts = _findTimeConflicts(destinations);
      
      if (conflicts.isNotEmpty) {
        emit(TravelError("Có xung đột thời gian: ${conflicts.join(', ')}"));
      } else {
        emit(TravelLoaded(<TravelRouteModel>[])); // Emit success state
      }
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  Future<void> _onAutoAdjustTimeSlots(AutoAdjustTimeSlots event, Emitter<TravelState> emit) async {
    try {
      List<Map<String, dynamic>> destinations;
      
      if (event.routeId != null) {
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
        destinations = List<Map<String, dynamic>>.from(
          _tempDestinationsByDay[event.currentDay] ?? []
        );
      }

      if (destinations.isNotEmpty) {
        // Tự động điều chỉnh thời gian
        _autoAdjustTimeSlots(destinations, event.startTime, event.durationPerDestination);

        if (event.routeId != null) {
          await _firestore.collection('TRAVEL_ROUTE').doc(event.routeId).update({
            'destinationsByDay.${event.currentDay}': destinations,
          });
          
          add(LoadRouteDestinations(event.routeId!));
        } else {
          _tempDestinationsByDay[event.currentDay] = destinations;
          
          final destinationIds = destinations.map((d) => d['destinationId'] as String).toList();
          final updatedDestinations = await _loadDestinationsFromIds(destinationIds);
          
          final timeSlots = Map<String, String>.fromEntries(
            destinations.map((entry) => MapEntry(
              entry['uniqueId'] as String,
              TimeSlotManager.formatTimeRange(
                entry['startTime'] as String,
                entry['endTime'] as String
              )
            ))
          );
          
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

  Future<void> _onSuggestTimeAdjustment(SuggestTimeAdjustment event, Emitter<TravelState> emit) async {
    try {
      List<Map<String, dynamic>> destinations;
      
      if (event.routeId != null) {
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
        destinations = List<Map<String, dynamic>>.from(
          _tempDestinationsByDay[event.currentDay] ?? []
        );
      }

      // Tìm index của destination
      final index = destinations.indexWhere(
        (d) => d['uniqueId'] == event.uniqueId
      );
      
      if (index != -1) {
        // Tạo gợi ý thời gian
        final suggestions = _suggestTimeAdjustment(
          destinations, 
          index, 
          event.desiredStartTime, 
          event.desiredEndTime
        );
        
        if (suggestions.isNotEmpty) {
          emit(TravelError("Gợi ý thời gian: ${suggestions['startTime']} - ${suggestions['endTime']}"));
        } else {
          emit(TravelError("Không thể tìm thấy thời gian phù hợp. Vui lòng thử lại."));
        }
      } else {
        emit(TravelError("Không tìm thấy địa điểm"));
      }
    } catch (e) {
      emit(TravelError(e.toString()));
    }
  }

  // Helper methods cho việc xử lý xung đột thời gian
  List<String> _findTimeConflicts(List<Map<String, dynamic>> destinations) {
    final conflicts = <String>[];
    
    for (int i = 0; i < destinations.length; i++) {
      for (int j = i + 1; j < destinations.length; j++) {
        final dest1 = destinations[i];
        final dest2 = destinations[j];
        
        final start1 = dest1['startTime'] as String;
        final end1 = dest1['endTime'] as String;
        final start2 = dest2['startTime'] as String;
        final end2 = dest2['endTime'] as String;
        
        if (_hasTimeConflict(start1, end1, start2, end2)) {
          conflicts.add("${dest1['destinationId']} vs ${dest2['destinationId']}");
        }
      }
    }
    
    return conflicts;
  }

  bool _hasTimeConflict(String start1, String end1, String start2, String end2) {
    // Chuyển đổi thời gian thành phút để dễ so sánh
    final start1Minutes = _timeToMinutes(start1);
    final end1Minutes = _timeToMinutes(end1);
    final start2Minutes = _timeToMinutes(start2);
    final end2Minutes = _timeToMinutes(end2);
    
    // Kiểm tra xung đột: khoảng thời gian 1 và 2 có giao nhau
    return !(end1Minutes <= start2Minutes || end2Minutes <= start1Minutes);
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  String _minutesToTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  Map<String, String> _suggestTimeAdjustment(List<Map<String, dynamic>> destinations, int currentIndex, String desiredStartTime, String desiredEndTime) {
    final suggestions = <String, String>{};
    
    // Tính thời gian mong muốn
    final desiredStartMinutes = _timeToMinutes(desiredStartTime);
    final desiredEndMinutes = _timeToMinutes(desiredEndTime);
    final desiredDuration = desiredEndMinutes - desiredStartMinutes;
    
    // Tìm khoảng thời gian trống
    final occupiedSlots = <MapEntry<int, int>>[];
    
    for (int i = 0; i < destinations.length; i++) {
      if (i == currentIndex) continue;
      
      final destination = destinations[i];
      final startTime = _timeToMinutes(destination['startTime'] as String);
      final endTime = _timeToMinutes(destination['endTime'] as String);
      
      occupiedSlots.add(MapEntry(startTime, endTime));
    }
    
    // Sắp xếp theo thời gian bắt đầu
    occupiedSlots.sort((a, b) => a.key.compareTo(b.key));
    
    // Tìm khoảng trống đầu tiên đủ lớn
    int currentTime = 6 * 60; // Bắt đầu từ 6:00
    
    for (final slot in occupiedSlots) {
      if (slot.key - currentTime >= desiredDuration) {
        // Tìm thấy khoảng trống đủ lớn
        final suggestedStartTime = _minutesToTime(currentTime);
        final suggestedEndTime = _minutesToTime(currentTime + desiredDuration);
        
        suggestions['startTime'] = suggestedStartTime;
        suggestions['endTime'] = suggestedEndTime;
        break;
      }
      currentTime = slot.value;
    }
    
    // Nếu không tìm thấy khoảng trống, gợi ý thời gian cuối ngày
    if (suggestions.isEmpty && currentTime + desiredDuration <= 23 * 60) {
      final suggestedStartTime = _minutesToTime(currentTime);
      final suggestedEndTime = _minutesToTime(currentTime + desiredDuration);
      
      suggestions['startTime'] = suggestedStartTime;
      suggestions['endTime'] = suggestedEndTime;
    }
    
    return suggestions;
  }

  void _autoAdjustTimeSlots(List<Map<String, dynamic>> destinations, String startTime, int durationPerDestination) {
    if (destinations.isEmpty) return;
    
    final startDateTime = DateTime.parse('2024-01-01 $startTime:00');
    var currentTime = startDateTime;
    
    for (int i = 0; i < destinations.length; i++) {
      final destination = destinations[i];
      
      // Kiểm tra xem có vượt quá 23:59 không
      if (currentTime.hour >= 23 && currentTime.minute >= 59) {
        // Nếu vượt quá, dừng lại ở 23:59
        currentTime = DateTime.parse('2024-01-01 23:59:00');
      }
      
      // Đặt thời gian bắt đầu
      final startTimeStr = '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
      
      // Thêm thời gian cho địa điểm
      currentTime = currentTime.add(Duration(minutes: durationPerDestination));
      
      // Kiểm tra và giới hạn end time tối đa là 23:59
      if (currentTime.hour >= 24) {
        currentTime = DateTime.parse('2024-01-01 23:59:00');
      }
      
      // Đặt thời gian kết thúc
      final endTimeStr = '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
      
      destination['startTime'] = startTimeStr;
      destination['endTime'] = endTimeStr;
      
      // Thêm thời gian di chuyển đến địa điểm tiếp theo
      if (i < destinations.length - 1) {
        currentTime = currentTime.add(const Duration(minutes: 30));
        
        // Kiểm tra lại sau khi thêm thời gian di chuyển
        if (currentTime.hour >= 24) {
          currentTime = DateTime.parse('2024-01-01 23:59:00');
        }
      }
    }
  }
} 