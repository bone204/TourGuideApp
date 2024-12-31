import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/color/colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import '../../widgets/custom_icon_button.dart';
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
    // Load danh sách ngân hàng khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BankViewModel>(context, listen: false).loadBanks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PersonInfoViewModel>(context);
    final bankViewModel = Provider.of<BankViewModel>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40.h,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Center(
                        child: Text(
                          AppLocalizations.of(context).translate('Banking Information'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await viewModel.saveData();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context).translate("Confirm"),
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
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
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate("Bank Name"),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomComboBox(
                  hintText: AppLocalizations.of(context).translate("Bank Name"),
                  value: viewModel.bankName,
                  items: bankViewModel.banks.map((bank) => bank.bankName).toList(),
                  onChanged: (value) {
                    viewModel.bankNameController.text = value ?? '';
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).translate("Bank Account Number"),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
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
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
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
      ),
    );
  }
}