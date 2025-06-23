import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/used_services_service.dart';

class UsedServicesViewModel extends ChangeNotifier {
  final UsedServicesService _service = UsedServicesService();
  List<Map<String, dynamic>> _usedServices = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get usedServices => _usedServices;
  bool get isLoading => _isLoading;

  Future<void> fetchUsedServices([String? userId]) async {
    _isLoading = true;
    notifyListeners();
    final String? uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _usedServices = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _usedServices = await _service.getUsedServicesByUserId(uid);
    _isLoading = false;
    notifyListeners();
  }
} 