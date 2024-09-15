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
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: Icons.chevron_left,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    AppLocalizations.of(context).translate('Settings'),
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
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
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
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
                const SizedBox(height: 20),
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
      ),
    );
  }
}
