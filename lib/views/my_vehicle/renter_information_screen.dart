import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/views/my_vehicle/delivery_information_screen.dart';
import 'package:tourguideapp/widgets/custom_icon_button.dart';

class RenterInformationScreen extends StatefulWidget {
  final String vehicleRegisterId;
  final String vehicleStatus;

  const RenterInformationScreen({
    Key? key,
    required this.vehicleRegisterId,
    required this.vehicleStatus,
  }) : super(key: key);

  @override
  State<RenterInformationScreen> createState() =>
      _RenterInformationScreenState();
}

class _RenterInformationScreenState extends State<RenterInformationScreen> {
  Map<String, bool> confirmedBills = {};

  @override
  void initState() {
    super.initState();
    confirmedBills = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    CustomIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('Rental Requests'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<RentalVehicleViewModel>(
        builder: (context, viewModel, child) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: viewModel.getRentalRequests(widget.vehicleRegisterId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate('No rental requests yet'),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 20.h),
                      if (widget.vehicleStatus == "Cho thuê")
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeliveryInformationScreen(
                                  billId: 'new',
                                  vehicleRegisterId: widget.vehicleRegisterId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('Start Delivery'),
                          ),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${request['startDate']} - ${request['endDate']}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildInfoRow(
                              context, 'Người thuê:', request['renterName']),
                          _buildInfoRow(context, 'Số điện thoại:',
                              request['renterPhone']),
                          _buildInfoRow(context, 'Tổng tiền:',
                              '${AppLocalizations.of(context).formatPrice(request['total'])} ₫'),
                          SizedBox(height: 12.h),
                          _buildActionButton(context, request['status'],
                              request['billId'], request['startDate']),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '${AppLocalizations.of(context).translate(label)}: ',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String status, String billId, String startDate) {
    String buttonText;
    VoidCallback? onPressed;

    if (kDebugMode) {
      print('Status: $status');
      print('Start Date: $startDate');
    }

    // Parse startDate từ string sang DateTime
    DateTime? startDateTime;
    try {
      List<String> parts = startDate.split(' ');
      List<String> dateParts = parts[0].split('/');
      List<String> timeParts = parts[1].split(':');

      startDateTime = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      if (kDebugMode) {
        print('Parsed Start DateTime: $startDateTime');
        print('Current DateTime: ${DateTime.now()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
    }

    switch (status) {
      case 'Chờ xác nhận thuê':
        buttonText = 'Cho thuê';
        onPressed = () async {
          try {
            await context
                .read<RentalVehicleViewModel>()
                .updateBillStatus(billId, 'Chờ nhận xe');
            setState(() {
              confirmedBills[billId] = true;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Đã xác nhận cho thuê thành công')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi: $e')),
              );
            }
          }
        };
        break;

      case 'Chờ nhận xe':
        buttonText = 'Vận chuyển';
        if (startDateTime != null && DateTime.now().isAfter(startDateTime)) {
          onPressed = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeliveryInformationScreen(
                  billId: billId,
                  vehicleRegisterId: widget.vehicleRegisterId,
                ),
              ),
            );
          };
        }
        break;

      case 'Chờ duyệt':
        buttonText = 'Chờ duyệt';
        onPressed = null; // Disable nút khi đang chờ duyệt
        break;

      default:
        buttonText = _getButtonText(status);
        onPressed = null;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: Size(100.w, 36.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.6),
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getButtonText(String status) {
    switch (status) {
      case 'Chờ duyệt':
        return 'Chờ duyệt';
      case 'Chờ nhận xe':
        return 'Vận chuyển';
      case 'Chờ hoàn trả':
        return 'Chờ hoàn trả';
      case 'Đã hoàn trả':
        return 'Đã hoàn trả';
      default:
        return 'Cho thuê';
    }
  }
}
