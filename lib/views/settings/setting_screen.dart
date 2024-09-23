import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth để đăng xuất
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/interactive_row_widget.dart';
import 'language_screen.dart';  // Import màn hình lựa chọn ngôn ngữ
import '../../widgets/custom_icon_button.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.13), // Responsive height
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
                            fontSize: constraints.maxWidth * 0.05, // Responsive font size
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      CustomIconButton(
                        icon: Icons.edit,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit button pressed')),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.08, vertical: constraints.maxHeight * 0.02), // Responsive padding
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tùy chọn ngôn ngữ
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
                    SizedBox(height: constraints.maxHeight * 0.03), // Responsive space
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
            );
          },
        ),
      ),
    );
  }
}
