import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../widgets/use_service_card.dart';
import '../../viewmodels/bill_viewmodel.dart';
import '../../viewmodels/rental_vehicle_viewmodel.dart';
import 'package:intl/intl.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch bills khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillViewModel>().fetchUserBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: Consumer<BillViewModel>(
          builder: (context, billViewModel, child) {
            final bills = billViewModel.userBills;
            
            if (bills.isEmpty) {
              return const Center(
                child: Text('No services found'),
              );
            }

            return ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                return FutureBuilder(
                  future: billViewModel.getVehicleDetails(bill.vehicleRegisterId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final vehicle = snapshot.data!;
                    return FutureBuilder<String>(
                      future: context
                          .read<RentalVehicleViewModel>()
                          .getVehiclePhoto(vehicle.vehicleId),
                      builder: (context, photoSnapshot) {
                        final imageUrl = photoSnapshot.data ?? 'assets/img/icon-cx3.png';
                        
                        return UseServiceCard(
                          vehicleName: '${vehicle.vehicleBrand} ${vehicle.vehicleModel}',
                          dateRange: '${DateFormat('dd/MM/yyyy').format(DateTime.parse(bill.startDate))} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(bill.endDate))}',
                          price: bill.total,
                          imageUrl: imageUrl,
                          onDetailPressed: () {
                            // Xử lý khi nhấn nút Detail
                          },
                          onCancelPressed: () {
                            // Xử lý khi nhấn nút Cancel
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}