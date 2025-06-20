import 'package:flutter/material.dart';
import 'package:momo_vn/momo_vn.dart';

class MomoService {
  static final MomoVn _momoPay = MomoVn();

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

  static Future<void> processPayment({
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
    required Function(PaymentResponse) onSuccess,
    required Function(PaymentResponse) onError,
  }) async {
    try {
      // Gửi options lên server
      await sendOptions(
        merchantName: merchantName,
        appScheme: appScheme,
        merchantCode: merchantCode,
        partnerCode: partnerCode,
        amount: amount,
        orderId: orderId,
        orderLabel: orderLabel,
        merchantNameLabel: merchantNameLabel,
        fee: fee,
        description: description,
        username: username,
        partner: partner,
        extra: extra,
        isTestMode: isTestMode,
      );

      // Đăng ký lắng nghe sự kiện từ MoMo
      _momoPay.on(MomoVn.EVENT_PAYMENT_SUCCESS, (PaymentResponse response) {
        debugPrint('MoMo Payment Success: Phone: ${response.phoneNumber}, Token: ${response.token}, Extra: ${response.extra}');
        onSuccess(response);
      });

      _momoPay.on(MomoVn.EVENT_PAYMENT_ERROR, (PaymentResponse response) {
        debugPrint('MoMo Payment Error: Status: ${response.status}, Message: ${response.message}, Extra: ${response.extra}');
        onError(response);
      });

      // Mở cổng thanh toán MoMo
      final options = MomoPaymentInfo(
        merchantName: merchantName,
        appScheme: appScheme,
        merchantCode: merchantCode,
        partnerCode: partnerCode,
        amount: amount,
        orderId: orderId,
        orderLabel: orderLabel,
        merchantNameLabel: merchantNameLabel,
        fee: fee,
        description: description,
        username: username,
        partner: partner,
        extra: extra,
        isTestMode: isTestMode
      );
      
      _momoPay.open(options);
    } catch (e) {
      debugPrint('Error processing payment: $e');
      rethrow;
    }
  }
} 