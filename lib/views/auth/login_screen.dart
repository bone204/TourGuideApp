import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tourguideapp/viewmodels/login_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/social_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, loginViewModel, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 150, screenWidth * 0.05, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('Sign in now'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.09),
                ),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  AppLocalizations.of(context).translate('Please sign in to continue using our app'),
                  style: TextStyle(fontSize: screenWidth * 0.04, color: Color(0xFF7D848D)),
                ),
                SizedBox(height: screenWidth * 0.1),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        hintText: AppLocalizations.of(context).translate('Email'),
                        controller: _emailController,
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      CustomPasswordField(
                        controller: _passwordController,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: Text(
                            AppLocalizations.of(context).translate('Forgot Password?'),
                            style: TextStyle(fontSize: screenWidth * 0.02, color: Color(0xFFFF7029)),
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      ElevatedButton(
                        onPressed: loginViewModel.isLoading
                            ? null
                            : () async {
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
                            : Text(
                                AppLocalizations.of(context).translate('Sign In'),
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
                      ),
                      SizedBox(height: screenWidth * 0.1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Don't have an account?"),
                            style: const TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignupScreen()),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context).translate('Sign up'),
                              style: const TextStyle(fontSize: 16, color: Color(0xFFFF7029)),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppLocalizations.of(context).translate('Or connect'),
                        style: const TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.1),
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
                    SizedBox(width: screenWidth * 0.03),
                    SocialIconButton(
                      icon: FontAwesomeIcons.google,
                      color: const Color(0xFFDB4437),
                      onPressed: () async {
                        User? user = await loginViewModel.signInWithGoogle();
                        if (user != null) {
                          Navigator.pushNamed(context, "/home");
                        } else {
                          if (kDebugMode) {
                            print("Google login failed");
                          }
                        }
                      },
                    ),
                  ],
                ),
                if (loginViewModel.errorMessage != null) // Hiển thị thông báo lỗi nếu có
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      loginViewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
