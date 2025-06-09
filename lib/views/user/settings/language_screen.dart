import 'package:flutter/material.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/main.dart';
import 'package:tourguideapp/widgets/app_bar.dart';
import 'package:tourguideapp/widgets/interactive_row_widget.dart';  // Import InteractiveRowWidget
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:shared_preferences/shared_preferences.dart';

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
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Save language preference first
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', locale.languageCode);
      
      // Then update the app's locale
      if (mounted) {
        MyApp.setLocale(context, locale);
        
        // Force a rebuild of the entire app
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          setState(() {
            _selectedLocale = locale;
            _isLoading = false;
          });
          
          // Navigate back to refresh the app
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmLanguageChange(Locale locale) async {
    if (_selectedLocale?.languageCode == locale.languageCode) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('Confirm Language Change')),
          content: Text(AppLocalizations.of(context).translate('Do you want to change the language?')),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).translate('Cancel')),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).translate('Confirm')),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _onLocaleChange(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: AppLocalizations.of(context).translate('Language'),
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 20.h),
                    Text(
                      AppLocalizations.of(context).translate('Changing language...'),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
