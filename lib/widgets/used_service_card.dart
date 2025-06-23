import 'package:flutter/material.dart';
import 'package:tourguideapp/core/utils/currency_formatter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class UsedServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback? onTap;
  const UsedServiceCard({super.key, required this.service, this.onTap});

  IconData _getServiceIcon(String type) {
    switch (type) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'delivery':
        return Icons.local_shipping;
      case 'bus':
        return Icons.directions_bus;
      case 'car_rental':
        return Icons.directions_car;
      case 'motorbike_rental':
        return Icons.motorcycle;
      default:
        return Icons.miscellaneous_services;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'done':
      case 'thành công':
        return Colors.green;
      case 'pending':
      case 'chờ xử lý':
        return Colors.orange;
      case 'cancelled':
      case 'canceled':
      case 'đã huỷ':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String serviceName = (service['serviceName'] ?? '').toString();
    final String serviceType = (service['serviceType'] ?? '').toString();
    final String status = (service['status'] ?? '').toString();
    final String date = service['usedDate']?.toString().split('T').first ?? '';
    final String price = service['amount'] != null ? CurrencyFormatter.format(double.tryParse(service['amount'].toString()) ?? 0) : '';
    final IconData icon = _getServiceIcon(serviceType);
    final Color statusColor = _getStatusColor(status);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.25),
                blurRadius: 4.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: Colors.blue, size: 32.sp),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.category, size: 16.sp, color: Colors.black26),
                        SizedBox(width: 4.w),
                        Text(
                          serviceType,
                          style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 15.sp, color: Colors.black26),
                        SizedBox(width: 4.w),
                        Text(
                          date,
                          style: TextStyle(fontSize: 13.sp, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 15.sp),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusColor == Colors.green
                              ? Icons.check_circle
                              : statusColor == Colors.orange
                                  ? Icons.hourglass_top
                                  : statusColor == Colors.red
                                      ? Icons.cancel
                                      : Icons.info,
                          color: statusColor,
                          size: 13.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}