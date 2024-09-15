import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/main.dart';
import 'package:tourguideapp/widgets/interactive_row_widget.dart';  // Import InteractiveRowWidget
import '../../widgets/custom_icon_button.dart';  // Import CustomIconButton

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Locale? _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cập nhật locale hiện tại
    _selectedLocale = Localizations.localeOf(context);
  }

  Future<void> _onLocaleChange(Locale locale) async {
  // Hiển thị hộp thoại xác nhận trước khi đổi ngôn ngữ
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('Confirm')),
          content: Text(AppLocalizations.of(context).translate(
              'This action will log you out and restart the app. Do you want to proceed?')),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).translate('Cancel')),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại mà không làm gì cả
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).translate('OK')),
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng hộp thoại

                // Đăng xuất người dùng
                await FirebaseAuth.instance.signOut();

                // Sau khi đăng xuất, mới đổi ngôn ngữ
                MyApp.setLocale(context, locale);

                // Reload lại ứng dụng sau khi đổi ngôn ngữ
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                  (route) => false, // Xóa tất cả các màn hình hiện tại trong stack
                );
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  AppLocalizations.of(context).translate('Select Language'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          InteractiveRowWidget(
            leadingIcon: Icons.language,
            title: AppLocalizations.of(context).translate('English'),
            trailingIcon: Icons.check,
            onTap: () => _onLocaleChange(const Locale('en')),
            isSelected: _selectedLocale?.languageCode == 'en',
          ),
          const SizedBox(height: 10),
          InteractiveRowWidget(
            leadingIcon: Icons.language,
            title: AppLocalizations.of(context).translate('Vietnamese'),
            trailingIcon: Icons.check,
            onTap: () => _onLocaleChange(const Locale('vi')),
            isSelected: _selectedLocale?.languageCode == 'vi',
          ),
        ],
      ),
    );
  }
}
