import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tourguideapp/models/bank_model.dart';

class BankViewModel extends ChangeNotifier {
  List<BankModel> _banks = [];
  List<BankModel> get banks => _banks;

  Future<void> loadBanks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('BANK')
          .get();
      
      _banks = snapshot.docs
          .map((doc) => BankModel.fromMap({
                ...doc.data(),
                'bankId': doc.id,
              }))
          .toList();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading banks: $e');
      }
    }
  }
}
