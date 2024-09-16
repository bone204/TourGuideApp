import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'localization/app_localizations.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/home/main_screen.dart';
import 'views/settings/setting_screen.dart';
import 'viewmodels/profile_viewmodel.dart'; // Import ViewModels

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); // Initialize Firebase before running the app
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Handle Firebase initialization errors if necessary
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();

  static void setLocale(BuildContext context, Locale locale) {
    final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(locale);
  }
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default locale

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()), // Add providers here
        // Add other providers if needed
      ],
      child: MaterialApp(
        title: 'Tour Guide App',
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('vi', ''), // Vietnamese
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        initialRoute: '/', // Ensure this is the intended initial route
        routes: {
          '/': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => MainScreen(),
          '/settings': (context) => SettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
