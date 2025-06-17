import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/views/service/travel/travel_bloc/travel_bloc.dart'; 
import 'package:tourguideapp/viewmodels/accountInfo_viewmodel.dart';
import 'package:tourguideapp/viewmodels/auth_viewmodel.dart';
import 'package:tourguideapp/viewmodels/contract_viewmodel.dart';
import 'package:tourguideapp/viewmodels/login_viewmodel.dart';
import 'package:tourguideapp/viewmodels/province_view_model.dart';
import 'package:tourguideapp/viewmodels/rental_vehicle_viewmodel.dart';
import 'package:tourguideapp/viewmodels/destinations_viewmodel.dart';
import 'package:tourguideapp/viewmodels/favourite_destinations_viewmodel.dart';
import 'package:tourguideapp/viewmodels/home_viewmodel.dart';
import 'package:tourguideapp/viewmodels/personInfo_viewmodel.dart';
import 'package:tourguideapp/viewmodels/bank_viewmodel.dart';
import 'package:tourguideapp/viewmodels/signup_viewmodel.dart';
import 'package:tourguideapp/views/on_boarding/on_boarding_screen.dart';
import 'package:tourguideapp/views/service/travel/travel_screen.dart';
import 'package:tourguideapp/views/user/settings/person_information_screen.dart';
import 'localization/app_localizations.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/home/main_screen.dart';
import 'views/user/settings/setting_screen.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourguideapp/viewmodels/bill_viewmodel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourguideapp/blocs/auth_bloc.dart';
import 'package:tourguideapp/core/services/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourguideapp/core/services/notification_service.dart';

class ImagesPath {
  static const String kOnboarding1 = 'assets/images/img_1.jpg';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  await dotenv.load(fileName: ".env");

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => TravelBloc(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => LoginViewModel(
              authService: FirebaseAuthService(),
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => SignupViewModel()),
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
          ChangeNotifierProvider(create: (_) => BillViewModel()),
          ChangeNotifierProvider(create: (_) => DestinationsViewModel()),
        ],
        child: const MyApp(showOnboarding: true),
      ),
    ),
  );
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) {
      print("Error initializing Firebase: $e");
    }
  }
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  MyAppState createState() => MyAppState();

  static void setLocale(BuildContext context, Locale locale) {
    final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(locale);
  }
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString('languageCode');
      if (languageCode != null && mounted) {
        setState(() {
          _locale = Locale(languageCode);
        });
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  void setLocale(Locale locale) {
    if (mounted) {
      setState(() {
        _locale = locale;
      });
      
      // Save the language preference
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('languageCode', locale.languageCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MaterialApp(
          navigatorKey: PersonInfoViewModel.navigatorKey,
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
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
          home: const OnBoardingScreen(),
          routes: {
            '/login': (context) => LoginScreen(),
            '/signup': (context) => SignupScreen(),
            '/home': (context) => const MainScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/travel': (context) => TravelScreen(),
            '/personal-info': (context) => PersonInfoScreen()
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
