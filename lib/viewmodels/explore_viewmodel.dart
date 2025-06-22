import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination_model.dart';

class ExploreViewModel extends ChangeNotifier {
  List<DestinationModel> _destinations = [];
  bool _isLoading = false;
  String? _error;

  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDestinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('DESTINATION').get();
      _destinations = snapshot.docs
          .map((doc) => DestinationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
