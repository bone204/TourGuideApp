import 'package:flutter/material.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';

class ZaloPayButton extends StatelessWidget {

  const ZaloPayButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      onPressed: () => {},
      child: const Text(
        'THANH TOÁN QUA ZALOPAY',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
} 