import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import '../../viewmodels/personInfo_viewmodel.dart';
import '../../viewmodels/bank_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_combo_box.dart';

class BankingInformationScreen extends StatefulWidget {
  const BankingInformationScreen({super.key});

  @override
  _BankingInformationScreennState createState() => _BankingInformationScreennState();
}

class _BankingInformationScreennState extends State<BankingInformationScreen> {
  @override
  void initState() {
    super.initState();
    // Load danh sách ngân hàng và thông tin ngân hàng của người dùng khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PersonInfoViewModel>(context, listen: false);
      Provider.of<BankViewModel>(context, listen: false).loadBanks();
      // Load thông tin ngân hàng của người dùng
      viewModel.loadBankingInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PersonInfoViewModel>(context);
    final bankViewModel = Provider.of<BankViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate("Banking Information"),
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          TextButton(
            onPressed: () async {
              await viewModel.saveData();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              AppLocalizations.of(context).translate("Done"),
              style: TextStyle(
                color: AppColors.green,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate("Bank Name"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              CustomComboBox(
                hintText: AppLocalizations.of(context).translate("Bank Name"),
                value: viewModel.bankNameController.text,
                items: bankViewModel.banks.map((bank) => bank.bankName).toList(),
                onChanged: (value) {
                  setState(() {
                    viewModel.bankNameController.text = value ?? '';
                  });
                },
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Bank Account Number"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: AppLocalizations.of(context).translate("Bank Account Number"),
                controller: viewModel.bankAccountNumberController,
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).translate("Bank Account Name"),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: AppLocalizations.of(context).translate("Bank Account Name"),
                controller: viewModel.bankAccountNameController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}