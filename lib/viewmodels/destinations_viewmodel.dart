import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourguideapp/models/destination_model.dart';
import 'package:tourguideapp/widgets/home_card.dart';
import 'package:flutter/foundation.dart';

class DestinationsViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DestinationModel> _destinations = [];
  bool _isLoading = false;
  String _error = '';
  StreamSubscription<QuerySnapshot>? _destinationSubscription;

  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String get error => _error;

  DestinationsViewModel() {
    // Tự động fetch khi khởi tạo
    fetchDestinations();
  }

  Future<void> fetchDestinations() async {
    if (_isLoading) return; // Tránh fetch nhiều lần

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      if (kDebugMode) {
        print('Đang tải destinations...');
      }

      // Hủy subscription cũ nếu có
      await _destinationSubscription?.cancel();

      // Lắng nghe thay đổi từ collection DESTINATION
      _destinationSubscription = _firestore
          .collection('DESTINATION')
          .snapshots()
          .listen((snapshot) {
        _destinations = snapshot.docs.map((doc) {
          if (kDebugMode) {
            print('Đã tải destination: ${doc.data()}');
          }
          return DestinationModel.fromMap(doc.data());
        }).toList();

        _isLoading = false;
        _error = '';
        notifyListeners();
        
        if (kDebugMode) {
          print('Đã tải ${_destinations.length} destinations');
        }
      }, onError: (error) {
        if (kDebugMode) {
          print('Lỗi khi tải destinations: $error');
        }
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });

    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi thiết lập lắng nghe: $e');
      }
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<HomeCardData> get horizontalCardsData => _destinations.map((destination) {
    return HomeCardData(
      imageUrl: destination.photo.isNotEmpty ? destination.photo[0] : '',
      placeName: destination.destinationName,
      description: destination.province,
      rating: 4.5, // Có thể thay đổi theo logic của bạn
    );
  }).toList();

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