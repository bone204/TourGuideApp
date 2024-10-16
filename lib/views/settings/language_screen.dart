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
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update current locale
    _selectedLocale = Localizations.localeOf(context);
  }

  Future<void> _onLocaleChange(Locale locale) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulate language loading time

    setState(() {
      _selectedLocale = locale;
      _isLoading = false;
    });

    MyApp.setLocale(context, locale);
  }

  Future<void> _confirmLanguageChange(Locale locale) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('Confirm Language Change')),
          content: Text(AppLocalizations.of(context).translate('Do you want to change the language?')),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).translate('Cancel')),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).translate('Confirm')),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                _onLocaleChange(locale);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true); // Initialize ScreenUtil

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
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          AppLocalizations.of(context).translate('Select Language'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(), // Show loading indicator while changing language
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h), // Responsive padding
                child: ListView(
                  children: [
                    InteractiveRowWidget(
                      leadingIcon: Icons.language,
                      title: AppLocalizations.of(context).translate('English'),
                      trailingIcon: Icons.check,
                      onTap: () => _confirmLanguageChange(const Locale('en')),
                      isSelected: _selectedLocale?.languageCode == 'en',
                    ),
                    SizedBox(height: 10.h),
                    InteractiveRowWidget(
                      leadingIcon: Icons.language,
                      title: AppLocalizations.of(context).translate('Vietnamese'),
                      trailingIcon: Icons.check,
                      onTap: () => _confirmLanguageChange(const Locale('vi')),
                      isSelected: _selectedLocale?.languageCode == 'vi',
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
