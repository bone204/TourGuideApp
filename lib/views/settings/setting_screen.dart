import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth để đăng xuất
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/settings/account_information_screen.dart';
import 'package:tourguideapp/views/settings/password_screen.dart';
import 'package:tourguideapp/views/settings/person_information_screen.dart';
import 'package:tourguideapp/views/settings/policy_term_screen.dart';
import 'package:tourguideapp/views/settings/privacy_policy_screen.dart';
import 'package:tourguideapp/widgets/interactive_row_widget.dart';
import 'language_screen.dart'; // Import màn hình lựa chọn ngôn ngữ
import '../../widgets/custom_icon_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h), // Chiều cao app bar
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Center(
              child: LayoutBuilder(
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
                          AppLocalizations.of(context).translate('Settings'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp, // Kích thước chữ sử dụng ScreenUtil
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 84.w),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w), // Padding sử dụng ScreenUtil
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).translate('Account & Security'),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp, // Kích thước chữ sử dụng ScreenUtil
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 16.h),
              InteractiveRowWidget(
                leadingIcon: Icons.person,
                title: AppLocalizations.of(context).translate('Personal Information'),
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PersonInfoScreen()),
                  );
                },
              ),
              SizedBox(height: 16.h), // Responsive space sử dụng ScreenUtil
              InteractiveRowWidget(
                leadingIcon: Icons.account_circle_outlined,
                title: AppLocalizations.of(context).translate('Account Information'),
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountInfoScreen()),
                  );
                },
              ),
              SizedBox(height: 16.h),
              InteractiveRowWidget(
                leadingIcon: Icons.key,
                title: AppLocalizations.of(context).translate('Change Password'),
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordScreen()),
                  );
                },
              ),
              SizedBox(height: 20.h),
              Text(
                AppLocalizations.of(context).translate('Settings'),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp, // Kích thước chữ sử dụng ScreenUtil
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 16.h),
              InteractiveRowWidget(
                leadingIcon: Icons.language,
                title: AppLocalizations.of(context).translate('language'),
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LanguageScreen()),
                  );
                },
              ),
              SizedBox(height: 16.h),
              InteractiveRowWidget(
                leadingIcon: Icons.book,
                title: AppLocalizations.of(context).translate('Policies & Terms'),
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PolicyAndTermScreen()),
                  );
                },
              ),
              SizedBox(height: 16.h),
              InteractiveRowWidget(
                leadingIcon: Icons.lock,
                title: AppLocalizations.of(context).translate('Privacy Policy'),
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                  );
                },
              ),
              SizedBox(height: 16.h), // Responsive space sử dụng ScreenUtil
              // Nút đăng xuất
              InteractiveRowWidget(
                leadingIcon: Icons.logout,
                title: AppLocalizations.of(context).translate('Sign Out'),
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/",
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
