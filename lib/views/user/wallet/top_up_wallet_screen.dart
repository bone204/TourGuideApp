import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/core/services/wallet_service.dart';
import 'package:tourguideapp/core/services/momo_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tourguideapp/widgets/app_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/viewmodels/profile_viewmodel.dart';
import 'package:tourguideapp/views/user/wallet/wallet_history_screen.dart';

class TopUpWalletScreen extends StatefulWidget {
  const TopUpWalletScreen({Key? key}) : super(key: key);

  @override
  State<TopUpWalletScreen> createState() => _TopUpWalletScreenState();
}

class _TopUpWalletScreenState extends State<TopUpWalletScreen> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  bool isProcessing = false;
  bool isAmountFocused = false;

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(() {
      setState(() {
        isAmountFocused = _amountFocusNode.hasFocus;
      });
    });
  }

  Future<void> _topUpWallet() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Loại bỏ dấu phẩy và dấu chấm trước khi parse
    final cleanAmountText = amountText.replaceAll(',', '').replaceAll('.', '');
    final amount = double.tryParse(cleanAmountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền tối thiểu là 10,000 ₫'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await MomoService.processPayment(
        merchantName: 'TTN',
        appScheme: 'MOMO',
        merchantCode: 'MOMO',
        partnerCode: 'MOMO',
        amount: amount.toInt(),
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        orderLabel: 'Nạp ví tiền',
        merchantNameLabel: 'HLGD',
        fee: 0,
        description: 'Nạp tiền vào ví ứng dụng',
        username: userId,
        partner: 'merchant',
        extra: '{"type":"wallet_topup","amount":"$amount"}',
        isTestMode: true,
        onSuccess: (response) async {
          // Kiểm tra widget còn mounted không
          if (!mounted) return;

          // Nạp tiền vào ví
          final success = await _walletService.topUpWallet(userId, amount);
          if (success) {
            // Kiểm tra mounted trước khi cập nhật UI
            if (!mounted) return;

            // Cập nhật số dư trong ProfileViewModel
            final profileViewModel =
                Provider.of<ProfileViewModel>(context, listen: false);
            final newBalance = await _walletService.getWalletBalance(userId);

            // Kiểm tra mounted trước khi cập nhật UI
            if (!mounted) return;

            profileViewModel.updateWalletBalance(newBalance);

            showAppDialog(
              context: context,
              title: 'Thành công',
              content:
                  'Đã nạp ${currencyFormat.format(amount)} ₫ vào ví thành công!',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          } else {
            if (!mounted) return;
            throw Exception('Không thể cập nhật ví');
          }
        },
        onError: (response) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thanh toán thất bại: ${response.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Nạp ví tiền',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WalletHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profileViewModel, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin số dư hiện tại
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 48.sp,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Số dư hiện tại',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${currencyFormat.format(profileViewModel.walletBalance)} ₫',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Form nạp tiền
                Text(
                  'Nhập số tiền muốn nạp',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 16.h),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: isAmountFocused ? 2.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: isAmountFocused
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập số tiền (VNĐ)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: isAmountFocused
                            ? AppColors.primaryColor
                            : Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                    onChanged: (value) {
                      // Lưu vị trí con trỏ cũ
                      final oldText = _amountController.text;
                      final oldSelection = _amountController.selection;

                      // Lấy số thuần (bỏ dấu phẩy, dấu chấm)
                      final numericValue =
                          value.replaceAll(RegExp(r'[^\d]'), '');

                      if (numericValue.isEmpty) {
                        _amountController.value = TextEditingValue(
                          text: '',
                          selection: TextSelection.collapsed(offset: 0),
                        );
                        return;
                      }

                      final number = double.tryParse(numericValue);
                      if (number != null && number > 0) {
                        final formatted = currencyFormat.format(number);

                        // Tính lại vị trí con trỏ mới
                        int selectionIndex = formatted.length -
                            (oldText.length - oldSelection.baseOffset);
                        if (selectionIndex < 0) selectionIndex = 0;
                        if (selectionIndex > formatted.length)
                          selectionIndex = formatted.length;

                        _amountController.value = TextEditingValue(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: selectionIndex),
                        );
                      }
                    },
                    onEditingComplete: () {
                      // Format khi người dùng hoàn thành nhập
                      final value = _amountController.text.trim();
                      if (value.isNotEmpty) {
                        final numericValue =
                            value.replaceAll(RegExp(r'[^\d]'), '');
                        if (numericValue.isNotEmpty) {
                          final number = double.tryParse(numericValue);
                          if (number != null && number > 0) {
                            final formatted = currencyFormat.format(number);
                            _amountController.text = formatted;
                          }
                        }
                      }
                    },
                  ),
                ),

                SizedBox(height: 8.h),
                Text(
                  'Số tiền tối thiểu: 10,000 ₫',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 32.h),

                // Nút nạp tiền
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _topUpWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    child: isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Đang xử lý...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Nạp tiền qua MoMo',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Thông tin bổ sung
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primaryColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Thông tin nạp tiền',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '• Số tiền sẽ được cộng vào ví ngay sau khi thanh toán thành công\n'
                        '• Có thể sử dụng số tiền trong ví để thanh toán các dịch vụ\n'
                        '• Giao dịch được bảo mật bởi MoMo',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }
}
