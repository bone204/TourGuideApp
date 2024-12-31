import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/use_service_card.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: ListView(
          children: [
            SizedBox(height: 16.h),
            UseServiceCard(
              vehicleName: 'S500 Sedan',
              dateRange: '26/11/2024 - 27/11/2024',
              price: 500000,
              imageUrl: 'assets/img/bg_route_1.png',
              onDetailPressed: () {
                // Xử lý khi nhấn nút Detail
              },
              onCancelPressed: () {
                // Xử lý khi nhấn nút Cancel
              },
            ),
            // Có thể thêm nhiều VehicleServiceCard khác ở đây
          ],
        ),
      ),
    );
  }
}