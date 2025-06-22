// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:momo_vn/momo_vn.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import '../core/services/momo_service.dart';
import 'package:tourguideapp/widgets/app_dialog.dart';

class MomoPayButton extends StatelessWidget {
  final String merchantName;
  final String appScheme;
  final String merchantCode;
  final String partnerCode;
  final int amount;
  final String orderId;
  final String orderLabel;
  final String merchantNameLabel;
  final int fee;
  final String description;
  final String username;
  final String partner;
  final String extra;
  final bool isTestMode;

  const MomoPayButton({
    Key? key,
    required this.merchantName,
    required this.appScheme,
    required this.merchantCode,
    required this.partnerCode,
    required this.amount,
    required this.orderId,
    required this.orderLabel,
    required this.merchantNameLabel,
    required this.fee,
    required this.description,
    required this.username,
    required this.partner,
    required this.extra,
    this.isTestMode = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      onPressed: () async {
        try {
          await MomoService.processPayment(
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
            onSuccess: (response) {
              if (context.mounted) {
                _showResultDialog(context, response, true);
              }
            },
            onError: (response) {
              if (context.mounted) {
                _showResultDialog(context, response, false);
              }
            },
          );
        } catch (e) {
          debugPrint(e.toString());
          if (context.mounted) {
            _showErrorDialog(context, e.toString());
          }
        }
      },
      child: const Text(
        'THANH TOÁN QUA MOMO',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, PaymentResponse response, bool isSuccess) {
    showAppDialog(
      context: context,
      title: isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại',
      content: isSuccess
          ? 'Cảm ơn bạn đã sử dụng dịch vụ.'
          : (response.message ?? 'Đã xảy ra lỗi khi thanh toán.'),
      icon: isSuccess ? Icons.check_circle : Icons.error,
      iconColor: isSuccess ? Colors.green : Colors.red,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ĐÓNG'),
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showAppDialog(
      context: context,
      title: 'Lỗi',
      content: error,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ĐÓNG'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
} 