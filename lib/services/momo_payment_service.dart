// import 'package:momo_vn/momo_vn.dart';
// import 'package:flutter/material.dart';

// class MomoPaymentService {
//   static final MomoPaymentService _instance = MomoPaymentService._internal();
//   factory MomoPaymentService() => _instance;
//   MomoPaymentService._internal();

//   final _momo = MomoVn.instance;

//   Future<void> initializeMomo() async {
//     await _momo.initialize(
//       partnerCode: 'MOMOIQA420180417',
//       merchantName: 'Tour Guide App',
//       merchantCode: 'MOMOIQA420180417',
//       merchantNameLabel: 'Tour Guide App',
//       appScheme: 'tourguideapp',
//     );
//   }

//   Future<void> requestPayment({
//     required String amount,
//     required String orderId,
//     required String orderLabel,
//     required String orderInfo,
//     required String customerName,
//     required String customerEmail,
//     required String customerPhone,
//     required BuildContext context,
//     required Function(String) onSuccess,
//     required Function(String) onError,
//   }) async {
//     try {
//       await _momo.requestPayment(
//         amount: amount,
//         orderId: orderId,
//         orderLabel: orderLabel,
//         orderInfo: orderInfo,
//         customerName: customerName,
//         customerEmail: customerEmail,
//         customerPhone: customerPhone,
//         onSuccess: onSuccess,
//         onError: onError,
//       );
//     } catch (e) {
//       onError(e.toString());
//     }
//   }
// }
