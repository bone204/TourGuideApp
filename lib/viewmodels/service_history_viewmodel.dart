import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ServiceHistoryViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _historicalProvinces = [];
  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> get historicalProvinces => _historicalProvinces;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> getHistoricalProvinces() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final bills = await _firestore
          .collection('BILL')
          .where('status', isEqualTo: 'Đã trả xe')
          .get();

      Map<String, Map<String, dynamic>> provinces = {};

      for (var bill in bills.docs) {
        final data = bill.data();
        final province = data['province'] as String;
        final startDate = data['startDate'] as String;
        final endDate = data['endDate'] as String;

        if (!provinces.containsKey(province)) {
          provinces[province] = {
            'province': province,
            'startDate': startDate,
            'endDate': endDate,
            'services': [],
          };
        }
        provinces[province]!['services']!.add({
          ...data,
          'billId': bill.id,
        });
      }

      _historicalProvinces = provinces.values.toList();
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tải lịch sử dịch vụ: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getServicesByDateRange(
    String startDate,
    String endDate,
    String province,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('BILL')
          .where('status', isEqualTo: 'Đã trả xe')
          .where('startDate', isGreaterThanOrEqualTo: startDate)
          .where('endDate', isLessThanOrEqualTo: endDate)
          .where('province', isEqualTo: province)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'billId': doc.id,
              })
          .toList();
    } catch (e) {
      _error = 'Không thể tải dịch vụ: $e';
      notifyListeners();
      return [];
    }
  }
}
