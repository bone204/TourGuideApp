import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/disable_textfield.dart';
import '../../viewmodels/accountInfo_viewmodel.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final accountInfoViewModel = Provider.of<AccountInfoViewModel>(context);
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('Account Information'),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h), // Padding sử dụng ScreenUtil
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                  accountInfoViewModel.avatar,
                ),
                onBackgroundImageError: (exception, stackTrace) {
                  AssetImage('assets/img/bg_route_1.png');
                },
              ),
              SizedBox(height: 24.h),
              Text(
                accountInfoViewModel.name,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate('Username'),
                text: accountInfoViewModel.name
              ),
              SizedBox(height: 16.h),
              DisabledTextField(
                labelText: AppLocalizations.of(context).translate('Email'),
                text: accountInfoViewModel.email
              ),
            ],
          ),
        ),
      ),
    );
  }
}
