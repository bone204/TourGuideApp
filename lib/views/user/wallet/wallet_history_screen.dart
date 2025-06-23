import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/core/services/wallet_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  final WalletService _walletService = WalletService();
  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletHistory();
  }

  Future<void> _loadWalletHistory() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final transactions = await _walletService.getWalletHistory(userId);
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải lịch sử: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getTransactionTypeText(String type) {
    switch (type) {
      case 'topup':
        return 'Nạp tiền';
      case 'deduct':
        return 'Thanh toán';
      default:
        return 'Giao dịch';
    }
  }

  Color _getTransactionTypeColor(String type) {
    switch (type) {
      case 'topup':
        return Colors.green;
      case 'deduct':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionTypeIcon(String type) {
    switch (type) {
      case 'topup':
        return Icons.add_circle;
      case 'deduct':
        return Icons.remove_circle;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Lịch sử giao dịch',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Chưa có giao dịch nào',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWalletHistory,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      final type = transaction['type'] as String;
                      final amount = (transaction['amount'] as num).toDouble();
                      final balance =
                          (transaction['balance'] as num).toDouble();
                      final description = transaction['description'] as String;
                      final createdAt = transaction['createdAt'] as DateTime?;
                      final status = transaction['status'] as String;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.w),
                          leading: Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: _getTransactionTypeColor(type)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Icon(
                              _getTransactionTypeIcon(type),
                              color: _getTransactionTypeColor(type),
                              size: 24.sp,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getTransactionTypeText(type),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                type == 'topup' ? '+' : '-',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _getTransactionTypeColor(type),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.h),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Số dư: ${currencyFormat.format(balance)} ₫',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (createdAt != null)
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(createdAt),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${currencyFormat.format(amount)} ₫',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _getTransactionTypeColor(type),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'completed'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  status == 'completed'
                                      ? 'Thành công'
                                      : 'Đang xử lý',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: status == 'completed'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
