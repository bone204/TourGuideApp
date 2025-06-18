import 'package:flutter/material.dart';

class MomoService {
  static Future<void> sendOptions({
    required String merchantName,
    required String appScheme,
    required String merchantCode,
    required String partnerCode,
    required int amount,
    required String orderId,
    required String orderLabel,
    required String merchantNameLabel,
    required int fee,
    required String description,
    required String username,
    required String partner,
    required String extra,
    required bool isTestMode,
  }) async {
    try {
      // TODO: Implement API call to send options
      debugPrint('Sending options to server...');
      debugPrint('Merchant Name: $merchantName');
      debugPrint('Amount: $amount');
      debugPrint('Order ID: $orderId');
      debugPrint('Description: $description');
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Handle response from server
      debugPrint('Options sent successfully!');
    } catch (e) {
      debugPrint('Error sending options: $e');
      rethrow;
    }
  }
} 