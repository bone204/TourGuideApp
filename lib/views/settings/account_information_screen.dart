import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/textfield.dart';
import '../../viewmodels/accountInfo_viewmodel.dart';
import '../../widgets/custom_icon_button.dart';

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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h), // Chiều cao app bar
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context).translate('Account Information'),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp, // Kích thước chữ sử dụng ScreenUtil
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 88.w),
                      ],
                    );
                  },
                ),
              ]
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h), // Padding sử dụng ScreenUtil
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1639628735078-ed2f038a193e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  ),
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
      ),
    );
  }
}
