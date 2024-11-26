import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/horizontal_card.dart';

class DestinationsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DestinationModel> _destinations = [];
  bool _isLoading = false;
  String _error = '';
  StreamSubscription<QuerySnapshot>? _destinationSubscription;

  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<HorizontalCardData> get horizontalCardsData => _destinations.map((destination) {
    return HorizontalCardData(
      imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : '',
      placeName: destination.destinationName,
      description: destination.province,
      rating: 4.5,
    );
  }).toList();

  DestinationsViewModel() {
    fetchDestinations();
  }

  Future<void> fetchDestinations() async {
    try {
      developer.log('Bắt đầu lắng nghe destinations');
      _isLoading = true;
      notifyListeners();

      // Hủy subscription cũ nếu có
      await _destinationSubscription?.cancel();

      // Lắng nghe thay đổi từ collection DESTINATION
      _destinationSubscription = _firestore
          .collection('DESTINATION')
          .snapshots()
          .listen((snapshot) {
        _destinations = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DestinationModel.fromMap(data);
        }).toList();

        _isLoading = false;
        _error = '';
        notifyListeners();
        
        developer.log('Đã cập nhật ${_destinations.length} destinations');
      }, onError: (error) {
        developer.log('Lỗi khi lắng nghe destinations: $error');
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });

    } catch (e) {
      developer.log('Lỗi khi thiết lập lắng nghe: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _destinationSubscription?.cancel();
    super.dispose();
  }

  Future<void> refreshDestinations() async {
    _error = '';
    await fetchDestinations();
  }
} 