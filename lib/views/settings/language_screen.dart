import 'package:flutter/material.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.13), // Responsive height
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
                      fontSize: screenWidth * 0.05, // Responsive font size
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
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // Responsive padding
          child: ListView(
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
        ),
      ),
    );
  }
}
