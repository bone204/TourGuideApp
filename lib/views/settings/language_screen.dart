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
    // Update current locale
    _selectedLocale = Localizations.localeOf(context);
  }

  Future<void> _onLocaleChange(Locale locale) async {
    // Show confirmation dialog before changing language
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
                Navigator.of(context).pop(); // Close dialog without action
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).translate('OK')),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog

                // Sign out the user
                await FirebaseAuth.instance.signOut();

                // Change language after signing out
                MyApp.setLocale(context, locale);

                // Reload the app after changing language
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                  (route) => false, // Clear all current screens in stack
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
