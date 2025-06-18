import 'package:flutter/material.dart';
import 'package:momo_vn/momo_vn.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import '../core/services/momo_service.dart';

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Số điện thoại:', response.phoneNumber.toString()),
                      const Divider(height: 20),
                      _buildInfoRow('Mã giao dịch:', response.token.toString()),
                      const Divider(height: 20),
                      _buildInfoRow('Thông tin thêm:', response.extra ?? 'Không có'),
                      const Divider(height: 20),
                      _buildInfoRow('Thời gian:', DateTime.now().toString().substring(0, 19)),
                      if (!isSuccess) ...[
                        const Divider(height: 20),
                        _buildInfoRow('Mã lỗi:', response.status.toString()),
                        const Divider(height: 20),
                        _buildInfoRow('Thông báo:', response.message.toString()),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? AppColors.primaryColor : AppColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ĐÓNG',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Lỗi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ĐÓNG',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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