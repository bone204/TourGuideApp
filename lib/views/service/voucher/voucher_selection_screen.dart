import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/voucher_model.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class VoucherSelectionScreen extends StatefulWidget {
  final double totalAmount;
  final Function(VoucherModel) onVoucherSelected;

  const VoucherSelectionScreen({
    Key? key,
    required this.totalAmount,
    required this.onVoucherSelected,
  }) : super(key: key);

  @override
  State<VoucherSelectionScreen> createState() => _VoucherSelectionScreenState();
}

class _VoucherSelectionScreenState extends State<VoucherSelectionScreen> {
  List<VoucherModel> vouchers = [];
  Timer? _timer;
  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _loadVouchers();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadVouchers() {
    // Trong thực tế sẽ load từ Firestore
    vouchers = VoucherModel.getSampleVouchers();
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  String _formatRemainingTime(int hours) {
    if (hours <= 0) return 'Hết hạn';

    final days = hours ~/ 24;
    final remainingHours = hours % 24;

    if (days > 0) {
      return '${days} ngày ${remainingHours} giờ';
    } else {
      return '${remainingHours} giờ';
    }
  }

  Color _getStatusColor(VoucherModel voucher) {
    if (!voucher.isActive) return Colors.grey;
    if (voucher.remainingCount <= 0) return Colors.red;
    if (voucher.canUse(widget.totalAmount)) return Colors.green;
    return Colors.orange;
  }

  String _getStatusText(VoucherModel voucher) {
    if (!voucher.isActive) return 'Voucher không hoạt động';
    if (voucher.remainingCount <= 0) return 'Đã hết voucher';
    if (voucher.canUse(widget.totalAmount)) return 'Có thể áp dụng';
    return 'Chưa đủ điều kiện sử dụng';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Chọn Voucher',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // Thông tin tổng tiền
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng tiền hóa đơn:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${currencyFormat.format(widget.totalAmount)} ₫',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Danh sách voucher
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                final canUse = voucher.canUse(widget.totalAmount);
                final statusColor = _getStatusColor(voucher);
                final statusText = _getStatusText(voucher);
                final remainingTime =
                    _formatRemainingTime(voucher.getRemainingHours());
                final discountAmount =
                    voucher.calculateDiscount(widget.totalAmount);

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: canUse
                          ? AppColors.primaryColor
                          : Colors.grey.shade300,
                      width: canUse ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header với tên voucher
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: canUse
                              ? AppColors.primaryColor
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'GIẢM ${voucher.value}% HÓA ĐƠN TRÊN ${currencyFormat.format(double.parse(voucher.billingMin))}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: canUse ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            if (canUse)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  'Tiết kiệm ${currencyFormat.format(discountAmount)} ₫',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            // Thanh trạng thái sử dụng
                            Row(
                              children: [
                                Text(
                                  'Sử dụng: ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${voucher.usedCount}/${voucher.number}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${voucher.usedPercentage.toStringAsFixed(0)}% đã sử dụng',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // Progress bar
                            LinearProgressIndicator(
                              value: voucher.usedPercentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                voucher.remainingCount > 0
                                    ? AppColors.primaryColor
                                    : Colors.red,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Trạng thái và thời gian
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      remainingTime,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Nút sử dụng
                            if (canUse) ...[
                              SizedBox(height: 16.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.onVoucherSelected(voucher);
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Sử dụng voucher',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
