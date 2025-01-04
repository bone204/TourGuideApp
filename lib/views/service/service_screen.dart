import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/service/rental_vehicle/rental_bill_detail_screen.dart';
import '../../widgets/use_service_card.dart';
import '../../viewmodels/bill_viewmodel.dart';
import '../../viewmodels/rental_vehicle_viewmodel.dart';

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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
                  child: Text(
                    AppLocalizations.of(context).translate('My Services'),
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: bills.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('No services found'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: bills.length,
                          itemBuilder: (context, index) {
                            final bill = bills[index];
                            return FutureBuilder(
                              future: billViewModel
                                  .getVehicleDetails(bill.vehicleRegisterId),
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
                                    final imageUrl = photoSnapshot.data ??
                                        'assets/img/icon-cx3.png';

                                    return UseServiceCard(
                                      vehicleName:
                                          '${vehicle.vehicleBrand} ${vehicle.vehicleModel}',
                                      dateRange:
                                          '${bill.startDate} - ${bill.endDate}',
                                      price: bill.total,
                                      imageUrl: imageUrl,
                                      onDetailPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RentalBillDetailScreen(
                                              model:
                                                  '${vehicle.vehicleBrand} ${vehicle.vehicleModel}',
                                              vehicleId: vehicle.vehicleId,
                                              vehicleRegisterId:
                                                  bill.vehicleRegisterId,
                                              startDate: bill.startDate,
                                              endDate: bill.endDate,
                                              rentOption: bill.rentalType,
                                              price: bill.total,
                                            ),
                                          ),
                                        );
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
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
