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

  Future<void> fetchDestinations() async {
    if (_isLoading) {
      developer.log('Đang trong quá trình loading, bỏ qua fetch mới');
      return;
    }

    try {
      developer.log('Bắt đầu fetch destinations');
      _isLoading = true;
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore.collection('DESTINATION').get();
      developer.log('Đã nhận được ${snapshot.docs.length} documents từ Firebase');

      _destinations = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DestinationModel.fromMap(data);
      }).toList();

      developer.log('Đã chuyển đổi thành công ${_destinations.length} destinations');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      developer.log('Lỗi khi fetch destinations: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDestinations() async {
    _error = '';
    await fetchDestinations();
  }
} 