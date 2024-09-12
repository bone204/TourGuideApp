// views/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; // Provider for state management
import 'package:tourguideapp/viewmodels/login_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/social_icon_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, loginViewModel, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 150, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Sign in now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please sign to continue our app',
                  style: TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        hintText: 'Email',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16.0),
                      CustomPasswordField(
                        controller: _passwordController,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(fontSize: 16, color: Color(0xFFFF7029)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          User? user = await loginViewModel.signIn(
                            _emailController.text,
                            _passwordController.text,
                          );

                          if (user != null) {
                            Navigator.pushNamed(context, "/home");
                          } else {
                            if (kDebugMode) {
                              print("Some error occurred");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24BAEC),
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: loginViewModel.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignupScreen()),
                              );
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(fontSize: 16, color: Color(0xFFFF7029)),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Or connect',
                        style: TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIconButton(
                      icon: FontAwesomeIcons.facebook,
                      color: const Color(0xFF4267B2),
                      onPressed: () {
                        // Handle Facebook login
                      },
                    ),
                    const SizedBox(width: 30),
                    SocialIconButton(
                      icon: FontAwesomeIcons.google,
                      color: const Color(0xFFDB4437),
                      onPressed: () {
                        // Handle Google login
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
