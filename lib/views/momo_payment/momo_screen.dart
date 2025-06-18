import 'package:flutter/material.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import '../../widgets/momo_pay_button.dart';

class MomoScreen extends StatelessWidget {
  const MomoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> paymentInfo = {
      'merchantName': 'TTN',
      'appScheme': 'MOMO',
      'merchantCode': 'MOMO',
      'partnerCode': 'MOMO',
      'amount': 60000,
      'orderId': '12321312',
      'orderLabel': 'Gói combo',
      'merchantNameLabel': 'HLGD',
      'fee': 10,
      'description': 'Thanh toán combo',
      'username': '01234567890',
      'partner': 'merchant',
      'extra': '{"key1":"value1","key2":"value2"}',
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: "Thanh toán Momo",
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'THÔNG TIN THANH TOÁN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MomoPayButton(
                      merchantName: paymentInfo['merchantName'] as String,
                      appScheme: paymentInfo['appScheme'] as String,
                      merchantCode: paymentInfo['merchantCode'] as String,
                      partnerCode: paymentInfo['partnerCode'] as String,
                      amount: paymentInfo['amount'] as int,
                      orderId: paymentInfo['orderId'] as String,
                      orderLabel: paymentInfo['orderLabel'] as String,
                      merchantNameLabel: paymentInfo['merchantNameLabel'] as String,
                      fee: paymentInfo['fee'] as int,
                      description: paymentInfo['description'] as String,
                      username: paymentInfo['username'] as String,
                      partner: paymentInfo['partner'] as String,
                      extra: paymentInfo['extra'] as String,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}