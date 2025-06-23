import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy số dư ví tiền của user
  Future<double> getWalletBalance(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('USER')
          .where('uid', isEqualTo: userId)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        return (userData['walletBalance'] ?? 0.0).toDouble();
      }
      return 0.0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting wallet balance: $e');
      }
      return 0.0;
    }
  }

  // Nạp tiền vào ví
  Future<bool> topUpWallet(String userId, double amount) async {
    try {
      await _firestore
          .collection('USER')
          .where('uid', isEqualTo: userId)
          .limit(1)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final docRef = querySnapshot.docs.first.reference;
          return docRef.update({
            'walletBalance': FieldValue.increment(amount),
          });
        }
        throw Exception('User not found');
      });

      // Lưu lịch sử nạp tiền
      await _firestore.collection('WALLET_TRANSACTIONS').add({
        'userId': userId,
        'type': 'topup',
        'amount': amount,
        'balance': await getWalletBalance(userId),
        'description': 'Nạp tiền vào ví',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      if (kDebugMode) {
        print('Wallet topped up successfully: $amount');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error topping up wallet: $e');
      }
      return false;
    }
  }

  // Trừ tiền từ ví
  Future<bool> deductFromWallet(String userId, double amount) async {
    try {
      final currentBalance = await getWalletBalance(userId);
      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }

      await _firestore
          .collection('USER')
          .where('uid', isEqualTo: userId)
          .limit(1)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final docRef = querySnapshot.docs.first.reference;
          return docRef.update({
            'walletBalance': FieldValue.increment(-amount),
          });
        }
        throw Exception('User not found');
      });

      // Lưu lịch sử trừ tiền
      await _firestore.collection('WALLET_TRANSACTIONS').add({
        'userId': userId,
        'type': 'deduct',
        'amount': amount,
        'balance': await getWalletBalance(userId),
        'description': 'Thanh toán dịch vụ',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      if (kDebugMode) {
        print('Wallet deducted successfully: $amount');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deducting from wallet: $e');
      }
      return false;
    }
  }

  // Lấy lịch sử giao dịch ví
  Future<List<Map<String, dynamic>>> getWalletHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('WALLET_TRANSACTIONS')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
                'createdAt': doc.data()['createdAt']?.toDate(),
              })
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting wallet history: $e');
      }
      return [];
    }
  }
} 