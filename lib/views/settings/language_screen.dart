import 'package:flutter/material.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/main.dart';
import 'package:tourguideapp/widgets/interactive_row_widget.dart';  // Import InteractiveRowWidget
import '../../widgets/custom_icon_button.dart';  // Import CustomIconButton
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Locale? _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update current locale
    _selectedLocale = Localizations.localeOf(context);
  }

  void _onLocaleChange(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
    MyApp.setLocale(context, locale);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Initialize ScreenUtil

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h), // Responsive height
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
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp, // Responsive font size using ScreenUtil
                    ),
                  ),
                  SizedBox(width: 84.w), // Maintain space for the removed edit button
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w), // Responsive padding
          child: ListView(
            children: [
              InteractiveRowWidget(
                leadingIcon: Icons.language,
                title: AppLocalizations.of(context).translate('English'),
                trailingIcon: Icons.check,
                onTap: () => _onLocaleChange(const Locale('en')),
                isSelected: _selectedLocale?.languageCode == 'en',
              ),
              SizedBox(height: 10.h),
              InteractiveRowWidget(
                leadingIcon: Icons.language,
                title: AppLocalizations.of(context).translate('Vietnamese'),
                trailingIcon: Icons.check,
                onTap: () => _onLocaleChange(const Locale('vi')),
                isSelected: _selectedLocale?.languageCode == 'vi',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
