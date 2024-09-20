import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; 
import 'package:tourguideapp/viewmodels/signup_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/social_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart'; // Import localization
import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignupViewModel>(
      create: (_) => SignupViewModel(),
      child: Consumer<SignupViewModel>(
        builder: (context, signupViewModel, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 150, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('Sign up now'), // Lấy chuỗi 'Sign up now' từ localization
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
                ),
                const SizedBox(height: 15),
                Text(
                  AppLocalizations.of(context).translate('Please fill the details and create account'), // Dịch
                  style: const TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        hintText: AppLocalizations.of(context).translate('Fullname'), // Dịch 'Fullname'
                        controller: _usernameController,
                      ),
                      const SizedBox(height: 16.0),
                      CustomTextField(
                        hintText: AppLocalizations.of(context).translate('Email'), // Dịch 'Email'
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16.0),
                      CustomPasswordField(
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context).translate("Password must be at least 8 characters long"), // Dịch
                          style: const TextStyle(fontSize: 14, color: Color(0xFF7D848D)),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      ElevatedButton(
                        onPressed: signupViewModel.isLoading
                            ? null
                            : () async {
                                User? user = await signupViewModel.signUp(
                                  _emailController.text,
                                  _passwordController.text,
                                  _usernameController.text,
                                  '', // Thêm địa chỉ nếu có
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
                        child: signupViewModel.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                AppLocalizations.of(context).translate('Sign Up'), // Dịch 'Sign Up'
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Already have an account?"), // Dịch
                            style: const TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context).translate('Sign in'), // Dịch 'Sign in'
                              style: const TextStyle(fontSize: 16, color: Color(0xFFFF7029)),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppLocalizations.of(context).translate('Or connect'), // Dịch 'Or connect'
                        style: const TextStyle(fontSize: 16, color: Color(0xFF7D848D)),
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
