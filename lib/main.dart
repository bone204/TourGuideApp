import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/home/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Guide App',
      initialRoute: '/home', // Set the initial route to the login screen
      routes: {
        '/': (context) => LoginScreen(), // Login screen as the initial screen
        '/signup': (context) => SignupScreen(), // Signup screen
        '/home': (context) => MainScreen(), // Home screen
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
