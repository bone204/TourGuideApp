import 'package:flutter/material.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/core/utils/currency_formatter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/services/used_services_service.dart';

class UsedServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> service;
  const UsedServiceDetailScreen({super.key, required this.service});

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

  String _getLabel(BuildContext context, String key) {
    final label = AppLocalizations.of(context).translate('used_service.$key');
    return label == 'used_service.$key' ? key : label;
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
    final Map<String, dynamic> additionalData = (service['additionalData'] ?? {}) is Map
        ? Map<String, dynamic>.from(service['additionalData'])
        : {};

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        title: Text('Chi tiết dịch vụ đã sử dụng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            tooltip: 'Xóa dịch vụ',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Xác nhận'),
                  content: Text('Bạn có chắc muốn xóa dịch vụ này?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Xóa', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await UsedServicesService().deleteUsedServiceById(service['id']);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa dịch vụ thành công!')),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xóa thất bại: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Container(
        color: AppColors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Card tổng hợp header + thông tin chính (dùng ScreenUtil và dịch)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.25),
                        blurRadius: 4.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 18.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon dịch vụ lớn, vòng tròn gradient mờ
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 92.w,
                              height: 92.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFB6E0FE), Color(0xFF4F8FFF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 16.r,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(22.w),
                              child: Icon(icon, color: Colors.blue, size: 48.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          serviceName,
                          style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 0.2),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.h),
                        Chip(
                          label: Row(
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
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 14.sp)),
                            ],
                          ),
                          backgroundColor: statusColor.withOpacity(0.13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${AppLocalizations.of(context).translate('used_service.serviceType')}: $serviceType',
                          style: TextStyle(fontSize: 14.sp, color: Colors.black45, fontWeight: FontWeight.w500, letterSpacing: 0.1),
                        ),
                        SizedBox(height: 18.h),
                        const Divider(height: 32, thickness: 1.1),
                        // Thông tin chính
                        Row(
                          children: [
                            Icon(Icons.category, size: 22.sp, color: Colors.blueAccent),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).translate('used_service.serviceType'),
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 14.sp),
                              ),
                            ),
                            Text(serviceType, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 16.sp)),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 22.sp, color: Colors.deepPurple),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).translate('used_service.usedDate'),
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 14.sp),
                              ),
                            ),
                            Text(date, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 16.sp)),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 22.sp, color: Colors.green),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).translate('used_service.amount'),
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 14.sp),
                              ),
                            ),
                            Text(price, style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 16.sp)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Thông tin chi tiết
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thông tin chi tiết', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black87)),
                    const SizedBox(height: 10),
                    ...additionalData.entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withOpacity(0.25),
                            blurRadius: 4.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                        title: Text(
                          _getLabel(context, e.key),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${e.value}',
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
