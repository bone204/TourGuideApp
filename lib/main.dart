import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart'; 
import 'package:tourguideapp/viewmodels/accountInfo_viewmodel.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/viewmodels/contract_viewmodel.dart';
import 'package:tourguideapp/viewmodels/province_view_model.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'package:tourguideapp/viewmodels/personInfo_viewmodel.dart';
import 'package:tourguideapp/viewmodels/bank_viewmodel.dart';
import 'package:tourguideapp/views/on_boarding/on_boarding_screen.dart';
import 'localization/app_localizations.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/home/main_screen.dart';
import 'views/settings/setting_screen.dart';
import 'viewmodels/profile_viewmodel.dart';

class ImagesPath {
  static const String kOnboarding1 = 'assets/images/img_1.jpg';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); 
  } catch (e) {
    if (kDebugMode) {
      print("Error initializing Firebase: $e");
    }
  }

  runApp(const MyApp(showOnboarding: true));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  const MyApp({Key? key, required this.showOnboarding}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();

  static void setLocale(BuildContext context, Locale locale) {
    final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(locale);
  }
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); 

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProvinceViewModel()),
        ChangeNotifierProvider(create: (_) => FavouriteDestinationsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AccountInfoViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()), 
        ChangeNotifierProvider(create: (_) => PersonInfoViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ContractViewModel()),
        ChangeNotifierProvider(create: (_) => RentalVehicleViewModel()),
        ChangeNotifierProvider(create: (_) => DestinationsViewModel()),
        ChangeNotifierProvider(create: (_) => BankViewModel()),
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
          Locale('en', ''), 
          Locale('vi', ''),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        home: const OnBoardingScreen(), 
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => const MainScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
