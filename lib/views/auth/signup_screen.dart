import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; 
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:tourguideapp/viewmodels/signup_viewmodel.dart';
import 'package:tourguideapp/widgets/custom_text_field.dart';
import 'package:tourguideapp/widgets/social_icon_button.dart';
import 'package:tourguideapp/localization/app_localizations.dart'; 
import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812)); 
    return ChangeNotifierProvider<SignupViewModel>(
      create: (_) => SignupViewModel(),
      child: Consumer<SignupViewModel>(
        builder: (context, signupViewModel, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 90.h, 20.w, 0), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('Sign up now'), 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26.sp), 
                ),
                SizedBox(height: 15.h), 
                Text(
                  AppLocalizations.of(context).translate('Please fill the details and create account'), 
                  style: TextStyle(fontSize: 16.sp, color: const Color(0xFF7D848D)), 
                ),
                SizedBox(height: 40.h), 
                Container(
                  padding: EdgeInsets.all(16.w), 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        hintText: AppLocalizations.of(context).translate('Fullname'), 
                        controller: _usernameController,
                      ),
                      SizedBox(height: 16.h), 
                      CustomTextField(
                        hintText: AppLocalizations.of(context).translate('Email'), 
                        controller: _emailController,
                      ),
                      SizedBox(height: 16.h), 
                      CustomPasswordField(
                        controller: _passwordController,
                      ),
                      SizedBox(height: 16.h), 
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context).translate("Password must be at least 8 characters long"), 
                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)), 
                        ),
                      ),
                      SizedBox(height: 40.h), 
                      ElevatedButton(
                        onPressed: signupViewModel.isLoading
                            ? null
                            : () async {
                                User? user = await signupViewModel.signUp(
                                  _emailController.text,
                                  _passwordController.text,
                                  _usernameController.text,
                                  '',
                                  '',
                                  '',
                                  '',
                                  '',
                                  '' 
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
                          backgroundColor: const Color(0xFF007BFF),
                          minimumSize: Size(double.infinity, 50.h), 
                          padding: EdgeInsets.symmetric(vertical: 16.h), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r), 
                          ),
                        ),
                        child: signupViewModel.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                AppLocalizations.of(context).translate('Sign Up'), 
                                style: TextStyle(fontWeight: FontWeight.bold ,color: Colors.white, fontSize: 16.sp), 
                              ),
                      ),
                      SizedBox(height: 40.h), 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Already have an account?"), 
                            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)), 
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context).translate('Sign in'), 
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFFFF7029)), 
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppLocalizations.of(context).translate('Or connect'), 
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF7D848D)), 
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.h), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIconButton(
                      icon: FontAwesomeIcons.google,
                      label: AppLocalizations.of(context).translate('Google'),
                      color: const Color(0xFFDB4437),
                      onPressed: () {
                        // Handle Google login
                      },
                    ),
                    SizedBox(width: 15.w), 
                    SocialIconButton(
                      icon: FontAwesomeIcons.facebook,
                      label: AppLocalizations.of(context).translate('Facebook'),
                      color: const Color(0xFF4267B2),
                      onPressed: () {
                        // Handle Facebook login
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
