import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale? _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cập nhật locale hiện tại
    _selectedLocale = Localizations.localeOf(context);
  }

  Future<void> _onLocaleChange(Locale locale) async {
    setState(() {
      _selectedLocale = locale;
    });
    MyApp.setLocale(context, locale);

    // Đăng xuất người dùng và reload lại toàn bộ ứng dụng
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
      (route) => false, // Xóa tất cả các màn hình hiện tại trong stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context).translate('English')),
            onTap: () => _onLocaleChange(const Locale('en')),
            selected: _selectedLocale?.languageCode == 'en',
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate('Vietnamese')),
            onTap: () => _onLocaleChange(const Locale('vi')),
            selected: _selectedLocale?.languageCode == 'vi',
          ),
        ],
      ),
    );
  }
}
