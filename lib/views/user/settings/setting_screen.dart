import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/views/user/settings/account_information_screen.dart';
import 'package:tourguideapp/views/user/settings/contact_screen.dart';
import 'package:tourguideapp/views/user/settings/password_screen.dart';
import 'package:tourguideapp/views/user/settings/person_information_screen.dart';
import 'package:tourguideapp/views/user/settings/term_condition_screen.dart';
import 'package:tourguideapp/views/user/settings/privacy_policy_screen.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/interactive_row_widget.dart';
import 'language_screen.dart'; // Import màn hình lựa chọn ngôn ngữ
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/blocs/auth_bloc.dart';
import 'package:tourguideapp/widgets/app_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Khởi tạo ScreenUtil

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('Settings'),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h), // Padding sử dụng ScreenUtil
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).translate('Account & Security'),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
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
                  MaterialPageRoute(builder: (context) => const PersonInfoScreen()),
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
                  MaterialPageRoute(builder: (context) => const AccountInfoScreen()),
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
                  MaterialPageRoute(builder: (context) => const PasswordScreen()),
                );
              },
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).translate('Settings'),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp, // Kích thước chữ sử dụng ScreenUtil
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 16.h),
            InteractiveRowWidget(
              leadingIcon: Icons.language,
              title: AppLocalizations.of(context).translate('Language'),
              trailingIcon: Icons.chevron_right,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguageScreen()),
                );
              },
            ),
            SizedBox(height: 16.h),
            InteractiveRowWidget(
              leadingIcon: Icons.book,
              title: AppLocalizations.of(context).translate('Terms & Conditions'),
              trailingIcon: Icons.chevron_right,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermConditionScreen()),
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
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            SizedBox(height: 16.h), 
            InteractiveRowWidget(
              leadingIcon: Icons.phone,
              title: AppLocalizations.of(context).translate('Contact Us'),
              trailingIcon: Icons.chevron_right,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactScreen()),
                );
              },
            ),
            SizedBox(height: 16.h), 
            InteractiveRowWidget(
              leadingIcon: Icons.logout,
              title: AppLocalizations.of(context).translate('Sign Out'),
              onTap: () async {
                bool shouldLogout = await showAppDialog<bool>(
                  context: context,
                  title: AppLocalizations.of(context).translate('Confirm Logout'),
                  content: AppLocalizations.of(context).translate('Are you sure you want to log out?'),
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(AppLocalizations.of(context).translate('Cancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(AppLocalizations.of(context).translate('Logout')),
                    ),
                  ],
                ) ?? false;
    
                if (shouldLogout) {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
