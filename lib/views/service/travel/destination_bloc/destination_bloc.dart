import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourguideapp/views/service/travel/destination_bloc/desination_event.dart';
import 'package:tourguideapp/views/service/travel/destination_bloc/destination_state.dart';
import 'package:tourguideapp/models/destination_model.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final FirebaseFirestore _firestore;
  static const int defaultLimit = 20; // Giới hạn mặc định

  DestinationBloc({required FirebaseFirestore firestore})
      : _firestore = firestore,
        super(DestinationInitial()) {
    on<LoadDestinationsByProvince>(_onLoadDestinations);
    on<LoadDestinationsByProvinceWithLimit>(_onLoadDestinationsWithLimit);
    on<LoadMoreDestinations>(_onLoadMoreDestinations);
    on<RefreshDestinations>(_onRefreshDestinations);
  }

  Future<void> _onLoadDestinations(
    LoadDestinationsByProvince event,
    Emitter<DestinationState> emit,
  ) async {
    await _onLoadDestinationsWithLimit(
      LoadDestinationsByProvinceWithLimit(event.province, defaultLimit),
      emit,
    );
  }

  Future<void> _onLoadDestinationsWithLimit(
    LoadDestinationsByProvinceWithLimit event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      emit(DestinationLoading());
      
      final snapshot = await _firestore
          .collection('DESTINATION')
          .where('province', isEqualTo: event.province)
          .limit(event.limit)
          .get();

      final destinations = snapshot.docs
          .map((doc) => DestinationModel.fromMap(doc.data()))
          .toList();

      // Kiểm tra xem còn dữ liệu không
      final hasMore = destinations.length == event.limit;
      final lastDocument = destinations.isNotEmpty ? snapshot.docs.last : null;

      emit(DestinationLoaded(
        destinations,
        limit: event.limit,
        hasMore: hasMore,
        lastDocument: lastDocument,
      ));
    } catch (e) {
      emit(DestinationError(e.toString()));
    }
  }

  Future<void> _onLoadMoreDestinations(
    LoadMoreDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      // Nếu đang ở state loaded, set isLoadingMore = true
      if (state is DestinationLoaded) {
        final currentState = state as DestinationLoaded;
        emit(DestinationLoaded(
          currentState.destinations,
          limit: currentState.limit,
          hasMore: currentState.hasMore,
          lastDocument: currentState.lastDocument,
          isLoadingMore: true,
        ));
      }

      Query query = _firestore
          .collection('DESTINATION')
          .where('province', isEqualTo: event.province);

      // Nếu có lastDocument, thêm startAfter
      if (event.lastDocument != null) {
        query = query.startAfterDocument(event.lastDocument!);
      }

      final snapshot = await query.limit(event.limit).get();

      final newDestinations = snapshot.docs
          .map((doc) => DestinationModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Nếu đang ở state loaded, thêm destinations mới vào danh sách hiện tại
      if (state is DestinationLoaded) {
        final currentState = state as DestinationLoaded;
        final allDestinations = [...currentState.destinations, ...newDestinations];
        
        final hasMore = newDestinations.length == event.limit;
        final lastDocument = newDestinations.isNotEmpty ? snapshot.docs.last : currentState.lastDocument;

        emit(DestinationLoaded(
          allDestinations,
          limit: event.limit,
          hasMore: hasMore,
          lastDocument: lastDocument,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      // Nếu có lỗi, quay lại state trước đó
      if (state is DestinationLoaded) {
        final currentState = state as DestinationLoaded;
        emit(DestinationLoaded(
          currentState.destinations,
          limit: currentState.limit,
          hasMore: currentState.hasMore,
          lastDocument: currentState.lastDocument,
          isLoadingMore: false,
        ));
      }
      emit(DestinationError(e.toString()));
    }
  }

  Future<void> _onRefreshDestinations(
    RefreshDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    try {
      // Nếu đang ở state loaded, giữ nguyên danh sách hiện tại và chỉ set refreshing
      if (state is DestinationLoaded) {
        final currentState = state as DestinationLoaded;
        emit(DestinationLoaded(
          currentState.destinations,
          limit: currentState.limit,
          hasMore: currentState.hasMore,
          lastDocument: currentState.lastDocument,
          isRefreshing: true,
        ));
      }

      final limit = event.limit ?? defaultLimit;
      
      final snapshot = await _firestore
          .collection('DESTINATION')
          .where('province', isEqualTo: event.province)
          .limit(limit)
          .get();

      final destinations = snapshot.docs
          .map((doc) => DestinationModel.fromMap(doc.data()))
          .toList();

      final hasMore = destinations.length == limit;
      final lastDocument = destinations.isNotEmpty ? snapshot.docs.last : null;

      emit(DestinationLoaded(
        destinations,
        limit: limit,
        hasMore: hasMore,
        lastDocument: lastDocument,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(DestinationError(e.toString(), isRefreshing: false));
    }
  }
} 